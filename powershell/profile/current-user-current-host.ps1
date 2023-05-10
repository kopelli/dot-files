Function DirectoryIsInPath {
	param(
		[string] $path
	)

	if ( (Test-Path($path)) -and -not ($env:PATH -match [regex]::Escape($path))) {
		$env:PATH="$path;$env:PATH"
	}
}

DirectoryIsInPath(Join-Path $env:ProgramData "bin")
DirectoryIsInPath(Join-Path $env:LocalAppData "Keybase")
Remove-Item -Path Function:DirectoryIsInPath

$Script:ChocolatelyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($Script:ChocolatelyProfile)) {
    Import-Module $Script:ChocolatelyProfile
}

# Define the custom prompt
Function prompt {
    $ESC = [char]27
    $color_reset = "$ESC[m"
    $color_red = "$ESC[1;31m"
    $color_green = "$ESC[1;32m"
    $color_yellow = "$ESC[1;33m"
    $color_blue = "$ESC[1;34m"
    $color_cyan = "$ESC[1;36m"
    $color_white = "$ESC[1;37m"
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity

    $prepend = ""
    if (Test-Path variable:/PSDebugContext) {
        $prepend = "$color_green[DBG]: $color_reset"
    } elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        $prepend = "$color_red[ADMIN]: $color_reset"
    }

    # Final prompt output
    $prepend `
    + $color_blue + $env:USERNAME + $color_reset `
    + "@" `
    + $color_cyan + $env:COMPUTERNAME + $color_reset `
    + " [" `
    + $color_green + $(Get-Location) + $color_reset `
    + "]`n" `
    + $(if ($NestedPromptLevel -ge 1) { ">>" }) + "> "
}

Get-Command -ErrorAction SilentlyContinue -ErrorVariable StarshipExists starship | Out-Null
if ("$StarshipExists" -eq "") {
    Invoke-Expression (&starship init powershell)
}