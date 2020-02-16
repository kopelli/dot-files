function Test-IsInstalled() {
    Get-Command "7z" -ErrorAction SilentlyContinue
}

function Get-PackageName() {
    "7zip.install"
}