function Test-IsInstalled() {
    Get-Command "vim" -ErrorAction SilentlyContinue
}

function Get-PackageName() {
    "vim"
}

