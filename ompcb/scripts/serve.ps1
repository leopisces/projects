# OMPCB 生产模式启动脚本（内网自用）
#
# Express 单进程同时托管前端 dist/ 与 /api，无需 IIS。
# 数据库固定在仓库的 data/ompcb.db，不随工作目录漂移。
#
# 手动跑：  powershell -ExecutionPolicy Bypass -File scripts\serve.ps1
# 自启动：  见 scripts\install-autostart.ps1

$ErrorActionPreference = 'Stop'

# 脚本在 scripts/ 下，项目根是上一级。用脚本自身位置定位，
# 这样计划任务以任意工作目录拉起时都不会找错路径。
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

$env:NODE_ENV = 'production'
if (-not $env:PORT) { $env:PORT = '4000' }

# 数据库固定用仓库内的 data\ompcb.db。
# 默认值本来就是「相对模块目录」的 data/ompcb.db，这里显式钉住是为了：
#   1) 计划任务以登录用户身份拉起时，外层环境不会把 OMPCB_DB 带偏到别处；
#   2) 备份脚本 scripts\backup-db.mjs 读的是同一个变量，两边必须一致；
#   3) 启动日志里能把实际用的库文件打出来，换机器时一眼能核对。
if (-not $env:OMPCB_DB) { $env:OMPCB_DB = Join-Path $root 'data\ompcb.db' }

# 隐藏窗口启动时 console 输出直接消失，失败等于无迹可查
# （曾因计划任务路径过期静默失败，只能靠 LastTaskResult 猜）。
# 全程转录到 data\logs\serve.log，超过 2MB 滚一份 .1。
$logDir = Join-Path $root 'data\logs'
$logFile = Join-Path $logDir 'serve.log'
$transcribing = $false
try {
    if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    if ((Test-Path -LiteralPath $logFile) -and ((Get-Item -LiteralPath $logFile).Length -gt 2MB)) {
        Move-Item -LiteralPath $logFile -Destination "$logFile.1" -Force
    }
    Start-Transcript -Path $logFile -Append | Out-Null
    $transcribing = $true
} catch {
    Write-Host "[ompcb] 日志转录未启用（$($_.Exception.Message)），继续" -ForegroundColor Yellow
}

# dist/ 不存在时 server.js 只会提供 API，页面直接 404 —— 与其让用户
# 对着空白页猜，不如在这里先构建。
if (-not (Test-Path -LiteralPath (Join-Path $root 'dist\index.html'))) {
    Write-Host '[ompcb] dist/ 缺失，先执行 npm run build ...' -ForegroundColor Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "构建失败（exit $LASTEXITCODE）" }
}

# 启动前先备一份一致性快照：库跑在 WAL 模式，单拷 .db 会拿到残缺数据，
# 交给 scripts/backup-db.mjs 用 SQLite 在线备份 API 合并 WAL。
# 备份失败只告警不退出——备份不该成为服务启动的单点故障。
Write-Host '[ompcb] 备份数据库 ...' -ForegroundColor Gray
try {
    node scripts/backup-db.mjs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ompcb] 备份退出码 $LASTEXITCODE，继续启动" -ForegroundColor Yellow
    }
} catch {
    Write-Host '[ompcb] 备份失败，继续启动' -ForegroundColor Yellow
}

Write-Host "[ompcb] 数据库文件: $($env:OMPCB_DB)" -ForegroundColor Gray
Write-Host "[ompcb] 启动中 -> http://localhost:$($env:PORT)" -ForegroundColor Cyan
try {
    node server/server.js
} finally {
    if ($transcribing) { try { Stop-Transcript | Out-Null } catch { } }
}
