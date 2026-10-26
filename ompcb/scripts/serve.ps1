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

# dist/ 不存在时 server.js 只会提供 API，页面直接 404 —— 与其让用户
# 对着空白页猜，不如在这里先构建。
if (-not (Test-Path -LiteralPath (Join-Path $root 'dist\index.html'))) {
    Write-Host '[ompcb] dist/ 缺失，先执行 npm run build ...' -ForegroundColor Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "构建失败（exit $LASTEXITCODE）" }
}

Write-Host "[ompcb] 启动中 -> http://localhost:$($env:PORT)" -ForegroundColor Cyan
node server/server.js
