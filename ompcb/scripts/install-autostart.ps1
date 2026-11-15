# 把 OMPCB 注册为自动启动的计划任务。
#
# 两种启动时机，按权限区分：
#   默认（无需管理员）  -AtLogOn   ：当前用户登录后自动启动
#   -AtStartup（需管理员）：开机即启动（不登录也跑），同时保留登录启动
#
# 为什么默认用计划任务而不是 Windows 服务：注册服务需要管理员权限，
# 日常会话往往不是管理员。计划任务在当前用户下注册无需提权，够内网自用。
#
# 安装：  powershell -ExecutionPolicy Bypass -File scripts\install-autostart.ps1
# 开机启动（管理员 PowerShell）：
#         powershell -ExecutionPolicy Bypass -File scripts\install-autostart.ps1 -AtStartup
# 卸载：  powershell -ExecutionPolicy Bypass -File scripts\install-autostart.ps1 -Uninstall
#
# 注意：项目目录搬过家之后必须重新跑本脚本。计划任务里存的是绝对路径，
# 旧路径会让任务以 0x8007010B（ERROR_DIRECTORY）静默失败。

param(
    [switch]$Uninstall,
    [switch]$AtStartup,
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

$triggers = @()

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -DontStopOnIdleEnd `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -MultipleInstances IgnoreNew

if ($AtStartup) {
    # 开机启动 = 任务以系统账户在「无人登录」状态下运行，注册时必须提权。
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw '注册「开机启动」需要管理员权限：请用管理员 PowerShell 重跑本脚本，或去掉 -AtStartup 只做「登录时启动」。'
    }

    $boot = New-ScheduledTaskTrigger -AtStartup
    # 开机瞬间磁盘/网络还没就绪，等一下再起服务，省得 SQLite 建库抢文件
    try { $boot.Delay = 'PT20S' } catch { }
    $triggers += $boot
    # 登录触发放一份：SYSTEM 实例已在跑时由 MultipleInstances=IgnoreNew 挡掉
    $triggers += New-ScheduledTaskTrigger -AtLogOn

    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
} else {
    $triggers += New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $principal = $null
}

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

$registerArgs = @{
    TaskName    = $TaskName
    Action      = $action
    Trigger     = $triggers
    Settings    = $settings
    Description = 'OMPCB 物料管理 - Express 生产服务 (localhost:4000)'
}
if ($principal) { $registerArgs['Principal'] = $principal }

Register-ScheduledTask @registerArgs | Out-Null

# 注册完把实际落盘的动作打出来：路径过期是这套自启动最常见的失效原因，
# 换目录后一眼就能看出任务还指着旧位置。
$saved = Get-ScheduledTask -TaskName $TaskName
$mode = if ($AtStartup) { '开机即启动（SYSTEM，无需登录）+ 登录时启动' } else { '登录时自动启动' }
Write-Host "[ompcb] 已注册计划任务 '$TaskName'（$mode）" -ForegroundColor Green
Write-Host "[ompcb] 执行动作： $($saved.Actions.Execute) $($saved.Actions.Arguments)"
Write-Host "[ompcb] 工作目录： $($saved.Actions.WorkingDirectory)"
Write-Host "[ompcb] 立即启动： Start-ScheduledTask -TaskName $TaskName"
Write-Host "[ompcb] 查看状态： Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo"
Write-Host "[ompcb] 停止服务： Stop-ScheduledTask -TaskName $TaskName"
Write-Host "[ompcb] 运行日志： $(Join-Path $root 'data\logs\serve.log')"
