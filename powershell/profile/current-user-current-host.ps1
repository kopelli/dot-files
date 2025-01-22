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

Function Resolve-RealPath() {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $Path
    )
    $linkTarget = Get-Item -Path $Path | Select-Object -ExpandProperty Target
    if (-Not($linkTarget)) {
        return $Path
    }

    if ([System.IO.path]::IsPathRooted($linkTarget)) {
        return $linkTarget
    }

    return Resolve-Path -Path $(Join-Path -Path $PSScriptRoot -ChildPath $linkTarget)
}

Function Resolve-ParentPath() {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $Path
    )
    return Split-Path -Path $Path
}

Function ImportModule {
    param(
        [string] $path
    )

    if (Test-Path($path)) {
        Import-Module $path -Global
    }
}

$realPath = $PSCommandPath | Resolve-RealPath | Resolve-ParentPath
$asyncModules = @(
    {
        ImportModule -path "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
        $global:asyncModulesLoaded += 1
        if ($global:asyncModulesLoaded -eq $asyncModules.Length) { [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen() }
    },
    {
        ImportModule -path "$PSScriptRoot\okta-aws-cli.psm1"
        $global:asyncModulesLoaded += 1
        if ($global:asyncModulesLoaded -eq $asyncModules.Length) { [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen() }
    },
    {
        ImportModule -path "$realPath\..\modules\dot-files\dot-files.psm1"
        $global:asyncModulesLoaded += 1
        if ($global:asyncModulesLoaded -eq $asyncModules.Length) { [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen() }
    },
    {
        Import-Module posh-sshell
        Start-SshAgent -Quiet -Scope User
        Add-SshAlias
        $global:asyncModulesLoaded += 1
        if ($global:asyncModulesLoaded -eq $asyncModules.Length) { [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen() }
    },
    {
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
        $global:asyncModulesLoaded += 1
        if ($global:asyncModulesLoaded -eq $asyncModules.Length) { [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen() }
    }
)

#This strategy is based on https://matt.kotsenas.com/posts/pwsh-profiling-async-startup
$asyncModules | ForEach-Object `
    -Begin { $global:asyncModulesLoaded = 0 } `
    -Process {
        Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PSEngineEvent]::OnIdle) -MaxTriggerCount 1 -Action $_ | Out-Null
    } 
#$InformationPreference = 'Continue'
#$VerbosePreference = 'Continue'
#$WarningPreference = 'Continue'
#$DebugPreference = 'Continue'


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
        + "] [async init: $($asyncModulesLoaded)/$($asyncModules.Length)]`n" `
        + $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}
