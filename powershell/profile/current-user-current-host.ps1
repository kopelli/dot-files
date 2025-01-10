Function DirectoryIsInPath {
    param(
        [string] $path
    )

    if ( (Test-Path($path)) -and -not ($env:PATH -match [regex]::Escape($path))) {
        $env:PATH = "$path$([System.IO.Path]::PathSeparator)$env:PATH"
    }
}

DirectoryIsInPath(Join-Path $env:ProgramData 'bin')
DirectoryIsInPath(Join-Path $env:LocalAppData 'Keybase')
Remove-Item -Path Function:DirectoryIsInPath

$Script:ChocolatelyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($Script:ChocolatelyProfile)) {
    Import-Module $Script:ChocolatelyProfile
}

$Script:OktaAwsCliProfile = "$PSScriptRoot\okta-aws-cli.psm1"
if (Test-Path($Script:OktaAwsCliProfile)) {
    Import-Module $Script:OktaAwsCliProfile
}

# TODO: Should probably check that 'aws' and 'aws_completer' are available commands...
Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)

    $env:COMP_LINE = $wordToComplete
    if ($env:COMP_LINE.length -lt $cursorPosition) {
        $env:COMP_LINE = $env:COMP_LINE + ' '
    }
    $env:COMP_POINT = $cursorPosition
    aws_completer.exe | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
    Remove-Item Env:\COMP_LINE
    Remove-Item Env:\COMP_POINT
}

# Configure XDG variables...mainly for nvim
$env:XDG_CONFIG_HOME = (Join-Path $env:USERPROFILE '.config')
$env:XDG_DATA_HOME = $env:LOCALAPPDATA
# XDG_RUNTIME_DIR is fine to stay in TMP
$env:XDG_STATE_HOME = $env:LOCALAPPDATA

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

    $prepend = ''
    if (Test-Path variable:/PSDebugContext) {
        $prepend = "$color_green[DBG]: $color_reset"
    }
    elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        $prepend = "$color_red[ADMIN]: $color_reset"
    }

    # Final prompt output
    $prepend `
        + $color_blue + $env:USERNAME + $color_reset `
        + '@' `
        + $color_cyan + $env:COMPUTERNAME + $color_reset `
        + ' [' `
        + $color_green + $(Get-Location) + $color_reset `
        + "]`n" `
        + $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}

Get-Command -ErrorAction SilentlyContinue -ErrorVariable StarshipExists starship | Out-Null
if ("$StarshipExists" -eq '') {
    Invoke-Expression (&starship init powershell)
    function Invoke-Starship-PreCommand {
        $loc = $executionContext.SessionState.Path.CurrentLocation
        $prompt = "$([char]27)]9;12$([char]7)"
        if ($loc.Provider.Name -eq 'FileSystem') {
            $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
        }
        $host.ui.Write($prompt)
    }
}
Function Start-Solution() {
       param()

       $private:SolutionFiles = Get-ChildItem -Path . -Recurse -Depth 3 *.sln
       if ($private:SolutionFiles -is [array]) {
               $private:Choices = $private:SolutionFiles | ForEach-Object -Begin { $private:index = 65 } -Process {
                       $private:file = $_
                       $choice = New-Object System.Management.Automation.Host.ChoiceDescription "&$([char]$private:index) - $(Resolve-Path -Path $private:file -Relative)", $private:file.FullName
                       $choice | Add-Member -MemberType NoteProperty -Name FullName -Value ${private:file}.FullName -Force
                       $private:index += 1
                       $choice
               }
               $private:selection = $host.ui.PromptForChoice("", "Which of these files do you want to open?", $private:choices, -1)
               Start-Process -FilePath $private:choices[$private:selection].FullName
       } else {
               Start-Process -FilePath $private:SolutionFiles
       }
}

Set-Alias -Name sln -Value Start-Solution

Function QuitReplacement {
       Invoke-Command -ScriptBlock { exit }
}
Set-Alias -Name Quit -Value QuitReplacement


Import-Module posh-sshell
Start-SshAgent -Quiet
Add-SshAlias