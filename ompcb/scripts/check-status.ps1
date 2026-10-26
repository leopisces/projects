$ErrorActionPreference = 'Continue'
$url = 'http://localhost:4000/api/health'
try {
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    Write-Output "HEALTH_STATUS=$($r.StatusCode)"
    Write-Output "HEALTH_BODY=$($r.Content)"
} catch {
    Write-Output "HEALTH_FAIL=$($_.Exception.Message)"
}

$t = Get-ScheduledTask -TaskName 'OMPCB' -ErrorAction SilentlyContinue
if ($t) {
    Write-Output "TASK_STATE=$($t.State)"
    $i = Get-ScheduledTaskInfo -TaskName 'OMPCB'
    Write-Output "TASK_LAST_RESULT=$($i.LastTaskResult)"
} else {
    Write-Output 'TASK_MISSING'
}

$conn = Get-NetTCPConnection -LocalPort 4000 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($conn) {
    $p = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
    Write-Output "PORT4000_PID=$($conn.OwningProcess) PROCESS=$($p.ProcessName)"
} else {
    Write-Output 'PORT4000_NOT_LISTENING'
}
