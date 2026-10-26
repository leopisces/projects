# 把 OMPCB 注册为「登录时自动启动」的计划任务。
#
# 用计划任务而不是 Windows 服务：注册服务需要管理员权限，而这台机器
# 当前会话不是管理员。计划任务在当前用户下注册无需提权，够内网自用。
#
# 安装：  powershell -ExecutionPolicy Bypass -File scripts\install-autostart.ps1
# 卸载：  powershell -ExecutionPolicy Bypass -File scripts\install-autostart.ps1 -Uninstall

param(
    [switch]$Uninstall,
    [string]$TaskName = 'OMPCB'
)

$ErrorActionPreference = 'Stop'

$root  = Split-Path -Parent $PSScriptRoot
$serve = Join-Path $PSScriptRoot 'serve.ps1'

if ($Uninstall) {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "[ompcb] 已移除计划任务 '$TaskName'" -ForegroundColor Yellow
    } else {
        Write-Host "[ompcb] 计划任务 '$TaskName' 不存在，无需移除"
    }
    return
}

if (-not (Test-Path -LiteralPath $serve)) { throw "找不到 $serve" }

# -WindowStyle Hidden 让 node 在后台跑，不弹黑框
$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$serve`"" `
    -WorkingDirectory $root

$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

# 内网自用场景：断网/拔电源都不该把服务停掉，所以关掉电源相关的限制。
# ExecutionTimeLimit 0 = 不限时长（默认 3 天会被强杀）。
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -DontStopOnIdleEnd `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask `
    -TaskName    $TaskName `
    -Action      $action `
    -Trigger     $trigger `
    -Settings    $settings `
    -Description 'OMPCB 物料管理 - Express 生产服务 (localhost:4000)' | Out-Null

Write-Host "[ompcb] 已注册计划任务 '$TaskName'（登录时自动启动）" -ForegroundColor Green
Write-Host "[ompcb] 立即启动： Start-ScheduledTask -TaskName $TaskName"
Write-Host "[ompcb] 查看状态： Get-ScheduledTask -TaskName $TaskName"
Write-Host "[ompcb] 停止服务： Stop-ScheduledTask -TaskName $TaskName"
