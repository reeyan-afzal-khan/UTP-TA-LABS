[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$MainFile,
    [ValidateSet('Full', 'Preview')][string]$Mode = 'Full',
    [switch]$Rebuild
)
. (Join-Path $PSScriptRoot 'Environment.ps1')
Initialize-LatexEnvironment
$mainPath = Resolve-CourseMain $MainFile
$courseDir = Split-Path -Parent $mainPath
$course = Split-Path -Leaf $courseDir
$outputDir = Join-Path (Join-Path $RepositoryRoot '.build') $course
$null = New-Item -ItemType Directory -Force -Path $outputDir
$latexmk = Get-RequiredTool 'latexmk.exe'
$null = Get-RequiredTool 'perl.exe'
$pdflatex = Get-RequiredTool 'pdflatex.exe'
# Prevent simultaneous builds from corrupting a course's auxiliary files.
try { $lock = [IO.File]::Open((Join-Path $outputDir 'build.lock'), 'OpenOrCreate', 'ReadWrite', 'None') }
catch { throw "A build is already running for $course. Wait for it to finish and save again." }
$timer = [Diagnostics.Stopwatch]::StartNew()
$exitCode = 1
Push-Location -LiteralPath $courseDir
try {
    Write-Host "[$Mode] $course"
    $common = @('-synctex=1', '-interaction=nonstopmode', '-file-line-error', '-halt-on-error', '-no-shell-escape')
    $hasState = (Test-Path -LiteralPath (Join-Path $outputDir 'main.aux')) -and
                (Test-Path -LiteralPath (Join-Path $outputDir 'main.toc'))
    if ($Mode -eq 'Preview' -and $hasState -and -not $Rebuild) {
        Write-Host 'One pass only: references and contents may need a Full build.'
        & $pdflatex @common '-interaction=batchmode' '-recorder' "-output-directory=$outputDir" 'main.tex'
    } else {
        if ($Mode -eq 'Preview') { Write-Host 'Initializing or rebuilding references with a Full build.' }
        $options = @('-pdf', '-quiet') + $common + @("-outdir=$outputDir")
        if ($Rebuild) { $options += '-g' }
        & $latexmk @options 'main.tex'
    }
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        $log = Join-Path $outputDir 'main.log'
        if (Test-Path -LiteralPath $log) { Get-Content -LiteralPath $log -Tail 65 | Write-Host }
        Write-Host "Build failed. See $log"
    } else { Write-Host "PDF: $(Join-Path $outputDir 'main.pdf')" }
} finally {
    Pop-Location
    $timer.Stop()
    $lock.Dispose()
    Write-Host ('Elapsed: {0:N2} seconds' -f $timer.Elapsed.TotalSeconds)
}
exit $exitCode
