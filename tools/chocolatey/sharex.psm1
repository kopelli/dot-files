function Test-IsInstalled() {
    Get-Command "$env:ProgramFiles\ShareX\ShareX.exe" -ErrorAction SilentlyContinue
}

function Get-PackageName() {
    "sharex"
}
