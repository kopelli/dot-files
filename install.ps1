param (
    [Parameter(Mandatory=$true)][Int32]$PSMajorVersion,
    [Parameter(Mandatory=$true)][Int32]$PSMinorVersion,
    [Parameter(Mandatory=$true)][Int32]$PSBuildVersion
)

# Ensure we're running on the version we expect
$ExpectedVersion = [version]::new($PSMajorVersion, $PSMinorVersion, $PSBuildVersion)
If ($PSVersionTable.PSVersion -ne $ExpectedVersion) {
    Write-Error -Message "Expected version $($ExpectedVersion.ToString()), but we are running on $($PSVersionTable.PSVersion.ToString())"
    exit 1
}

Function Get-MenuMultipleChoice() {
    PARAM (
        [string] $caption,
        [string] $message,
        [System.Management.Automation.Host.ChoiceDescription[]] $choices
    )
    PROCESS {
        if ($choices.Length -eq 0) {
            throw "No choices available to prompt for"
        }

        $modifiedChoices = $choices | ForEach-Object {
            $choice = $_.PsObject.Copy()
            if ($choice.Label.IndexOf("&") -ge 0) {
                $hotkey = $choice.Label.Substring($choice.Label.IndexOf("&") + 1, 1).ToUpper()
            } else {
                $hotkey = $null
            }

            $label = $choice.Label.Replace("&", "")
            $choice | Add-Member -NotePropertyMembers @{ HotKey = $hotkey; DisplayLabel = $label; Selected = $true } -Force
            Write-Output $choice
        }
        
        Write-Host $caption -ForegroundColor White
        Write-Host (New-Object string("-", $caption.Length))
        if ($choices.Length -gt 1) {
            Write-Host $message
            Write-Host
            $menuLinePosition = $host.UI.RawUi.CursorPosition

            $maxDisplayLabel = ($modifiedChoices | Select-Object -ExpandProperty DisplayLabel | Measure-Object -Property Length -Maximum).Maximum
            $selectionCompleted = $false
            While ($selectionCompleted -eq $false) {
                $host.UI.RawUI.CursorPosition = $menuLinePosition
                $modifiedChoices | ForEach-Object {
                    if ($_.Selected) {
                        $selectedText = "X"
                    } else {
                        $selectedText = " "
                    }

                    $output = "`t[$selectedText] "
                    if ($_.HotKey) {
                        $output += "[$($_.HotKey)] "
                    }
                    
                    $output += $_.DisplayLabel.PadRight($maxDisplayLabel, ' ')
                    if ($_.HelpMessage) {
                        $output += " - $($_.HelpMessage)"
                    }

                    Write-Output $output
                } | Write-Host

                Write-Host (New-Object string(" ", 80))
                $choiceLinePosition = $host.UI.RawUI.CursorPosition
                $host.UI.RawUI.CursorPosition = $choiceLinePosition
                Write-Host (New-Object string(" ", 80))
                Write-Host (New-Object string(" ", 80))
                $host.UI.RawUI.CursorPosition = $choiceLinePosition
                Write-Host "Toggle Component (No value to continue)? " -NoNewline -ForegroundColor Cyan
                $userInput = Read-Host
                $selectedChoice = $modifiedChoices | Where-Object { $_.HotKey -eq $userInput -or $_.DisplayLabel -eq $userInput }
                if ($null -eq $selectedChoice) {
                    $selectionCompleted = $true
                } else {
                    $selectedChoice.Selected = !$selectedChoice.Selected
                }
            }
        } else {
            Write-Host -NoNewline "Automatically choosing the only option of `"" -ForegroundColor Cyan
            Write-Host -NoNewline $modifiedChoices[0].DisplayLabel -ForegroundColor White
            Write-Host "`"" -ForegroundColor Cyan
        }

        Write-Host

        Write-Output $modifiedChoices | Where-Object { $_.Selected -eq $true }
    }
}

Function Install-Bash() {
}

Function Install-Git() {
}

Function Install-Tmux() {
}

Function Install-Vim() {
}

Function Install-GitRepo() {
}

Function Is-In-Git-Repo() {
    Write-Output $true
}
#==============================================================================
# Menu configuration
#==============================================================================
$Menu_Text = "Select all that you would like to install"
$Menu_Message = "Press [Enter] to continue installation"
$Option_Bash = New-Object System.Management.Automation.Host.ChoiceDescription '&Bash', 'Configuration & supporting artifacts'
$Option_Git = New-Object System.Management.Automation.Host.ChoiceDescription '&Git', 'User-level Configuration'
$Option_Tmux = New-Object System.Management.Automation.Host.ChoiceDescription '&TMUX', 'Configuration'
$Option_Vim = New-Object System.Management.Automation.Host.ChoiceDescription '&Vim', 'Configuration & Plugins'
$Option_GitRepo = New-Object System.Management.Automation.Host.ChoiceDescription 'Git &Repos', 'Direct Git repositories'

$options = [System.Management.Automation.Host.ChoiceDescription[]](
    $Option_Bash,
    $Option_Git,
    $Option_Tmux,
    $Option_Vim,
    $Option_GitRepo)
$userChoices = Get-MenuMultipleChoice -caption $Menu_Text -message $Menu_Message -choices $options
# Should the user clear all the checkboxes, there's nothing else for us to do.
# So bail early
if ($userChoices.Length -eq 0) {
    exit 0
}

if (Is-In-Git-Repo -eq $true) {
    Write-Host "We're in a git repo, so assume this is the install directory"
    #TODO: Loop through remotes and make sure one of the matches
    #TODO: Find the root of the git repo
    $Install_Dir = $PWD
} else {
    Write-Host "Where do you want to download the repo to?"
    Write-Host "The 'dot-files' directory will be created automatically"
    #TODO: Prompt for directory
    $Install_Dir = $PWD
}

#==============================================================================
# Perform installs
#==============================================================================

#TODO: Use $($PSVersionTable.OS) to determine
Write-Host "Install directory is `"$Install_Dir`""

switch ($($userChoices | Select-Object -ExpandProperty Label)) {
    $Option_Bash.Label {
        Install-Bash
    }
    $Option_Git.Label {
        Install-Git
    }
    $Option_Tmux.Label {
        Install-Tmux
    }
    $Option_Vim.Label {
        Install-Vim
    }
    $Option_GitRepo.Label {
        Install-GitRepo
    }
    default {
        Write-Host "I have no idea what to do with `"$_`""
    }
}