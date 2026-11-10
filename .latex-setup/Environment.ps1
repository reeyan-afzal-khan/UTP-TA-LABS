# Common Windows tool discovery. No persistent PATH or registry changes.
$ErrorActionPreference = 'Stop'
$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
function Initialize-LatexEnvironment {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64",
        "$env:ProgramFiles\MiKTeX\miktex\bin\x64",
        "$env:ProgramFiles\Git\usr\bin", "$env:LOCALAPPDATA\Programs\Git\usr\bin",
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin", "$env:ProgramFiles\Microsoft VS Code\bin"
    ) | Where-Object { Test-Path -LiteralPath $_ -PathType Container }
    $env:Path = $env:Path + [IO.Path]::PathSeparator + ($candidates -join [IO.Path]::PathSeparator)
}
function Get-CourseMainFiles {
    Get-ChildItem -LiteralPath $RepositoryRoot -Directory |
        Where-Object { -not $_.Name.StartsWith('.') } |
        ForEach-Object { Join-Path $_.FullName 'main.tex' } |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Sort-Object
}
function Resolve-CourseMain([string]$MainFile) {
    if (-not [IO.Path]::IsPathRooted($MainFile)) { $MainFile = Join-Path $RepositoryRoot $MainFile }
    $resolved = (Resolve-Path -LiteralPath $MainFile).Path
    if ($resolved -notin @(Get-CourseMainFiles)) { throw 'Select main.tex inside a top-level course folder.' }
    return $resolved
}
function Get-RequiredTool([string]$Name) {
    $tool = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $tool) { throw "Missing $Name. See .latex-setup/README.md, then run Check.ps1." }
    return $tool.Source
}
