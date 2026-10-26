# 把「每日数据库备份」注册为计划任务。
#
# 为什么不写在服务进程里：备份要能在服务挂掉/被误删之后依然按天跑，
# 所以交给计划任务；服务启动时另有 serve.ps1 里的一次性备份兜底。
#
# 安装：  powershell -ExecutionPolicy Bypass -File scripts\install-backup-task.ps1
# 卸载：  powershell -ExecutionPolicy Bypass -File scripts\install-backup-task.ps1 -Uninstall
# 查看：  Get-ScheduledTask -TaskName OMPCB-Backup
# 手动跑：npm run backup

param(
    [switch]$Uninstall,
    [string]$TaskName = 'OMPCB-Backup',
    [string]$Time = '12:00'
)

$ErrorActionPreference = 'Stop'

$root   = Split-Path -Parent $PSScriptRoot
$script = Join-Path $PSScriptRoot 'backup-db.mjs'

if ($Uninstall) {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "[ompcb] 已移除计划任务 '$TaskName'" -ForegroundColor Yellow
    } else {
        Write-Host "[ompcb] 计划任务 '$TaskName' 不存在，无需移除"
    }
    return
}

if (-not (Test-Path -LiteralPath $script)) { throw "找不到 $script" }

$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) { throw '找不到 node，请先安装 Node.js 20+ 并加入 PATH' }

# 直接调 node 执行备份脚本，不经 powershell：少一层进程，失败码也更干净
$action = New-ScheduledTaskAction `
    -Execute $node `
    -Argument ('"' + $script + '"') `
    -WorkingDirectory $root

$trigger = New-ScheduledTaskTrigger -Daily -At $Time

# 笔记本可能用电池/休眠：备份必须能在电池下启动，错过时间点也要补跑。
# 备份是短任务，给 30 分钟上限防止卡死占住任务。
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask `
    -TaskName    $TaskName `
    -Action      $action `
    -Trigger     $trigger `
    -Settings    $settings `
    -Description "OMPCB 物料管理 - 每日数据库备份 ($Time，保留最近 14 份到 data\backups)" | Out-Null

Write-Host "[ompcb] 已注册计划任务 '$TaskName'（每日 $Time 备份）" -ForegroundColor Green
Write-Host "[ompcb] 立即试跑： Start-ScheduledTask -TaskName $TaskName"
Write-Host "[ompcb] 手动备份： npm run backup"
