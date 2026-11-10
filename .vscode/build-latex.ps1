# Compatibility entry point; implementation lives in .latex-setup.
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$MainFile)
& (Join-Path (Split-Path -Parent $PSScriptRoot) '.latex-setup/Build.ps1') -MainFile $MainFile
exit $LASTEXITCODE
