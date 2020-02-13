$Script:ProgramDataBin=(Join-Path $env:ProgramData "bin")
$env:PATH="$Script:ProgramDataBin;$env:PATH"

$Script:ChocolatelyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($Script:ChocolatelyProfile)) {
    Import-Module $Script:ChocolatelyProfile
}