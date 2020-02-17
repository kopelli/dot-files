function Test-IsInstalled() {
    Get-Command "balenaEtcher" -ErrorAction SilentlyContinue
}

function Get-PackageName() {
    "etcher"
}
