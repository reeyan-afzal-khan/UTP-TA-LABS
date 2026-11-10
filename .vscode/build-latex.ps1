[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$MainFile)

$ErrorActionPreference = 'Stop'
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$mainPath = (Resolve-Path -LiteralPath $MainFile).Path
$courseDir = Split-Path -Parent $mainPath
if ((Split-Path -Leaf $mainPath) -ne 'main.tex' -or
    (Split-Path -Parent $courseDir) -ne $workspaceRoot -or
    (Split-Path -Leaf $courseDir).StartsWith('.')) {
    throw 'Select main.tex in one of the top-level course folders.'
}

# Use existing installations. Only this build process receives the extra PATH.
$toolDirs = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\MiKTeX\miktex\bin\x64'),
    (Join-Path $env:ProgramFiles 'MiKTeX\miktex\bin\x64'),
    (Join-Path $env:ProgramFiles 'Git\usr\bin'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Git\usr\bin')
) | Where-Object { Test-Path -LiteralPath $_ -PathType Container }
$env:Path = ($toolDirs -join [IO.Path]::PathSeparator) + [IO.Path]::PathSeparator + $env:Path
$latexmk = Get-Command latexmk.exe -ErrorAction Stop
$null = Get-Command perl.exe -ErrorAction Stop

$outputDir = Join-Path (Join-Path $workspaceRoot '.build') (Split-Path -Leaf $courseDir)
$null = New-Item -ItemType Directory -Force -Path $outputDir
Write-Host "Course: $(Split-Path -Leaf $courseDir)"
Write-Host "PDF: $(Join-Path $outputDir 'main.pdf')"

# Course-relative input paths resolve correctly even when VS Code opens the repo root.
# latexmk retains dependency state and only repeats passes when references need it.
Push-Location -LiteralPath $courseDir
try {
    & $latexmk.Source '-pdf' '-synctex=1' '-interaction=nonstopmode' '-file-line-error' '-halt-on-error' '-no-shell-escape' "-outdir=$outputDir" 'main.tex'
    $buildExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $buildExitCode
