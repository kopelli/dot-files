if ($null -eq $env:XDG_DATA_HOME) {
    $env:XDG_DATA_HOME = (Join-Path (Resolve-Path ~) ".local" "share")
}
$TargetPath = (Join-Path $env:XDG_DATA_HOME "cloned-repos" "diff-so-fancy" "third_party" "build_fatpack" )
$TargetFile = (Join-Path $TargetPath "diff-so-fancy")
$Script:ProgramDataBin = (Join-Path $env:ProgramData "bin") 
if (-not (Test-Path $Script:ProgramDataBin)) {
    New-Item -ItemType Directory -Path $Script:ProgramDataBin | Out-Null
}

if (Test-Path $TargetPath) {
    $SymbolicFile = (Join-Path $env:ProgramData "bin" "diff-so-fancy")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null
}