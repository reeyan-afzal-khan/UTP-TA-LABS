[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot 'Environment.ps1')
Initialize-LatexEnvironment
$failures = @()
foreach ($name in @('pdflatex.exe', 'latexmk.exe', 'perl.exe', 'synctex.exe', 'kpsewhich.exe')) {
    try {
        $tool = Get-RequiredTool $name
        Write-Host "OK  $name : $tool"
        if ($name -eq 'latexmk.exe') {
            $version = & $tool '-v' 2>&1
            if ($LASTEXITCODE -ne 0) { throw ($version -join "`n") }
            $version | Select-Object -First 3 | Write-Host
        }
    } catch { $failures += $_.Exception.Message }
}
$code = Get-Command code.cmd -ErrorAction SilentlyContinue
if ($code) {
    $extensions = & $code.Source --list-extensions
    if ($extensions -contains 'James-Yu.latex-workshop') { Write-Host 'OK  LaTeX Workshop installed' }
    else { $failures += 'Install LaTeX Workshop: code --install-extension James-Yu.latex-workshop' }
} else { $failures += 'VS Code CLI not found. Install VS Code and reopen the terminal.' }
$kpse = Get-Command kpsewhich.exe -ErrorAction SilentlyContinue
if ($kpse) {
    foreach ($file in @('sourcesanspro.sty', 'sourcecodepro.sty', 'SourceSansThree.map', 'tcolorbox.sty', 'pgfplots.sty', 'listings.sty', 'fontawesome5.sty', 'algorithm.sty', 'algpseudocode.sty', 'pdflscape.sty')) {
        $found = & $kpse.Source $file
        if (-not $found) { $failures += "Missing $file; install its package in MiKTeX Console." }
    }
}
$settings = Get-Content -LiteralPath (Join-Path $RepositoryRoot '.vscode/settings.json') -Raw | ConvertFrom-Json
$tasks = Get-Content -LiteralPath (Join-Path $RepositoryRoot '.vscode/tasks.json') -Raw | ConvertFrom-Json
$courses = @(Get-CourseMainFiles | ForEach-Object { Split-Path -Leaf (Split-Path -Parent $_) })
$picker = @($tasks.inputs | Where-Object id -eq 'course' | ForEach-Object options)
if (@(Compare-Object $courses $picker).Count) { $failures += 'VS Code course picker differs from the top-level main.tex files.' }
Write-Host "Courses: $($courses.Count); auto build: $($settings.'latex-workshop.latex.autoBuild.run')"
if ($failures.Count) { $failures | ForEach-Object { Write-Host "CHECK  $_" }; exit 1 }
Write-Host 'Setup checks passed. Run Build.ps1 for a complete compilation check.'
