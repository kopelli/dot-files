function Test-IsInstalled() {
  Get-Command "C:\Program Files (x86)\mRemoteNG\mRemoteNG" -ErrorAction SilentlyContinue
}

function Get-PackageName() {
  "mRemoteNG"
}
