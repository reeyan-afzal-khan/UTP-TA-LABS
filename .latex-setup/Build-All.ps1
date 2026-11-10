[CmdletBinding()]
param([switch]$Rebuild)
. (Join-Path $PSScriptRoot 'Environment.ps1')
$failed = @()
foreach ($main in Get-CourseMainFiles) {
    $arguments = @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File',
        (Join-Path $PSScriptRoot 'Build.ps1'), '-MainFile', $main)
    if ($Rebuild) { $arguments += '-Rebuild' }
    & powershell.exe @arguments
    if ($LASTEXITCODE -ne 0) { $failed += $main }
}
if ($failed.Count) { Write-Host "Failed courses:`n$($failed -join "`n")"; exit 1 }
Write-Host 'All course builds passed.'
