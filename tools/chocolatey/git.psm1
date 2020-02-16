function Test-IsInstalled() {
    Get-Command "git" -ErrorAction SilentlyContinue
}

function Get-PackageName() {
    "git"
}
