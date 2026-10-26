# OMPCB 更新发布脚本（内网自用）
#
# 改完代码跑这一个脚本即可：停服务 → 装依赖 → 构建 → 起服务 → 健康检查。
#
#   powershell -ExecutionPolicy Bypass -File scripts\deploy.ps1
#
# 可选参数：
#   -SkipInstall   跳过 npm install（只改了前端/后端源码时可用，快几十秒）
#   -Pull          先执行 git pull（从远端拉更新时用）

param(
    [switch]$SkipInstall,
    [switch]$Pull,
    [string]$TaskName = 'OMPCB',
    [int]$Port = 4000
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

function Step($msg) { Write-Host "[ompcb] $msg" -ForegroundColor Cyan }

# --- 1. 拉取（可选）-------------------------------------------------------
if ($Pull) {
    Step 'git pull ...'
    git pull
    if ($LASTEXITCODE -ne 0) { throw "git pull 失败（exit $LASTEXITCODE）" }
}

# --- 2. 停服务 -------------------------------------------------------------
# 必须先停：Windows 上 better-sqlite3 会锁住 .node 文件，运行中执行
# npm install 会因文件占用而失败。
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($task) {
    Step "停止 $TaskName ..."
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    # Stop-ScheduledTask 只杀 powershell 宿主，node 子进程可能残留，
    # 端口不释放新实例就起不来 —— 按端口精确清理。
    Start-Sleep -Seconds 1
    $owners = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue |
              Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($procId in $owners) {
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        Write-Host "        清理占用 $Port 的进程 PID=$procId" -ForegroundColor DarkGray
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "[ompcb] 计划任务 '$TaskName' 不存在，跳过停止" -ForegroundColor Yellow
}

# --- 3. 依赖 ---------------------------------------------------------------
if (-not $SkipInstall) {
    Step 'npm install ...'
    npm install
    if ($LASTEXITCODE -ne 0) { throw "npm install 失败（exit $LASTEXITCODE）" }
}

# --- 4. 构建 ---------------------------------------------------------------
# 无条件重建：serve.ps1 只在 dist/ 缺失时才构建，改了前端代码但 dist/
# 还在的话它不会重建，页面就还是旧的。发布必须强制。
Step 'npm run build ...'
npm run build
if ($LASTEXITCODE -ne 0) { throw "构建失败（exit $LASTEXITCODE）" }

# --- 5. 起服务 -------------------------------------------------------------
if ($task) {
    Step "启动 $TaskName ..."
    Start-ScheduledTask -TaskName $TaskName
} else {
    Step '未注册计划任务，请先跑 scripts\install-autostart.ps1'
    return
}

# --- 6. 健康检查 -----------------------------------------------------------
# 不做这步就不算发布完成：构建成功不等于服务起得来
# （原生模块 ABI 不匹配、端口被占、数据库迁移抛错都在这里暴露）。
Step '健康检查 ...'
$ok = $false
foreach ($i in 1..15) {
    Start-Sleep -Seconds 1
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:$Port/api/health" -UseBasicParsing -TimeoutSec 3
        if ($r.StatusCode -eq 200) { $ok = $true; break }
    } catch { }
}

if ($ok) {
    Write-Host ''
    Write-Host "[ompcb] 发布完成" -ForegroundColor Green
    Write-Host "         本机   http://localhost:$Port"
    $lan = Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
           Select-Object -ExpandProperty IPAddress
    foreach ($ip in $lan) { Write-Host "         内网   http://${ip}:$Port" }
} else {
    throw "服务启动后 15 秒内未响应 /api/health，请手动执行 scripts\serve.ps1 查看报错"
}
