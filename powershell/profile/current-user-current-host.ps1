$Script:ProgramDataBin=(Join-Path $env:ProgramData "bin")
$env:PATH="$Script:ProgramDataBin;$env:PATH"