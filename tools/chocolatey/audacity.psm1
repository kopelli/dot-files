function Test-IsInstalled() {
  Get-Command "C:\Program Files (x86)\Audacity\audacity" -ErrorAction SilentlyContinue
}

function Get-PackageName() {
  "audacity"
}
