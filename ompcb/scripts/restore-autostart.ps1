# 恢复 OMPCB 服务（项目路径已变更 / 换机器后的首次启用）
#
# 用途：注册登录自启计划任务，然后交由 deploy.ps1 完成
#       「装依赖 → 构建 → 起服务 → 健康检查」的完整发布流程。
#
# 运行（Windows PowerShell，无需管理员）：
#   cd D:\projects\ompcb
#   powershell -ExecutionPolicy Bypass -File scripts\restore-autostart.ps1
#
# 与 deploy.ps1 的分工：
#   - 本脚本只负责「计划任务不存在时注册它」，然后调用 deploy.ps1
#   - 日常改代码后更新服务，直接跑 scripts\deploy-quick.bat 即可

param(
    [string]$TaskName = 'OMPCB',
    [int]$Port = 4000,
    [switch]$SkipInstall
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root
Write-Host "[ompcb] 项目根：$root" -ForegroundColor Cyan

# ---- 1. 前置检查 ----------------------------------------------------------
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) { throw '找不到 node，请先安装 Node.js 20+ 并加入 PATH' }

$nodeVersion = (& node -v).TrimStart('v')
if ([int]($nodeVersion -split '\.')[0] -lt 20) {
    throw "Node 版本过低：$nodeVersion（要求 >= 20）"
}
Write-Host "[ompcb] Node $nodeVersion" -ForegroundColor Gray

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw '找不到 npm，请检查 Node.js 安装' }

# ---- 2. 注册计划任务 ------------------------------------------------------
# install-autostart.ps1 按自身位置定位 serve.ps1，因此换文件夹后重新注册
# 就能自动指向新路径，不会残留旧路径。
# 无论是否存在都重新注册：目录搬过家后旧任务的 Action 仍指向旧路径，
# 重新注册会覆盖为当前路径。
$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "[ompcb] 计划任务 '$TaskName' 已存在，按当前路径重新注册 ..." -ForegroundColor Yellow
} else {
    Write-Host "[ompcb] 注册计划任务 '$TaskName' ..." -ForegroundColor Yellow
}
& (Join-Path $PSScriptRoot 'install-autostart.ps1') -TaskName $TaskName

# ---- 3. 交给 deploy.ps1 完成发布 ------------------------------------------
# deploy.ps1 会：停旧服务 → npm install（除 -SkipInstall）→ 强制构建
#              → 启动任务 → 轮询 /api/health → 打印本机与内网地址
$deployArgs = @{ TaskName = $TaskName; Port = $Port }
if ($SkipInstall) { $deployArgs['SkipInstall'] = $true }

& (Join-Path $PSScriptRoot 'deploy.ps1') @deployArgs
