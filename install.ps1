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

Function Install-Chocolatey() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )
    $CHOCO_DIR = (Join-Path $install_dir "tools" "chocolatey")
    Write-Verbose "CHOCO_DIR = $CHOCO_DIR"
    Write-Host "Looping through Chocolatey packages..."
    if (Test-Path $CHOCO_DIR) {
        Write-Verbose "Packages: $packages"
        $packages = Get-ChildItem -Path (Join-Path $CHOCO_DIR "*") -Include *.psm1 | ForEach-Object {
            $ImportedModule = Import-Module -Name (Get-Item $_).FullName -PassThru
            $result = [PSCustomObject]@{ PackageName = Get-PackageName }
            Write-Verbose "Package Name: $($result.PackageName)"
            if (Test-IsInstalled) {
                $result | Add-Member -NotePropertyMembers @{Status="Installed"} -PassThru
            } else {
                $result | Add-Member -NotePropertyMembers @{Status="NotInstalled"} -PassThru
            }
            $ImportedModule | Remove-Module
        }
        $installedPackageNames = $packages | Where-Object { $_.Status -eq "Installed" } | Select-Object -ExpandProperty PackageName
        if ($installedPackageNames.Length -gt 0) {
            & choco upgrade $installedPackageNames --yes
        }
        $notinstalledPackageNames = $packages | Where-Object { $_.Status -eq "NotInstalled" } | Select-Object -ExpandProperty PackageName
        if ($notinstalledPackageNames.Length -gt 0) {
            & choco install $notinstalledPackageNames --yes
        }
    }
}
Function Install-Bash() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )
    $SymbolicFile = (Join-Path (Resolve-Path ~) ".bashrc")
    $TargetFile = (Join-Path $install_dir ".bash" "bashrc")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null
}

Function Install-Git() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )
    $SymbolicFile = (Join-Path (Resolve-Path ~) ".gitconfig")
    $TargetFile = (Join-Path $install_dir ".git-config" "config")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null

    $SymbolicFile = (Join-Path (Resolve-Path ~) ".git-config")
    $TargetFile = (Join-Path $install_dir ".git-config")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null
}

Function Install-Powershell() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )
    $SymbolicFile = $PROFILE.CurrentUserCurrentHost
    $TargetFile = (Join-Path $install_dir "powershell" "profile" "current-user-current-host.ps1")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null
}

Function Install-PowershellInstallers() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )

    $VerbosePreference = "Continue"
    $POWERSHELL_DIR = (Join-Path $install_dir "tools" "powershell")
    Write-Verbose "POWERSHELL_DIR = $POWERSHELL_DIR"
    if (Test-Path $POWERSHELL_DIR) {
        Write-Host "Executing Powershell script installers..."
        Get-ChildItem -Path (Join-Path $POWERSHELL_DIR "*") -Include *.ps1 | ForEach-Object {
            $FILE = (Resolve-Path $_)
            Write-Host "Executing `"$FILE`""
            & $FILE
        }
    }
}

Function Install-Tmux() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )
    $SymbolicFile = (Join-Path (Resolve-Path ~) ".tmux.conf")
    $TargetFile = (Join-Path $install_dir "_tmux.conf")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null
}

Function Install-Vim() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )
    $SymbolicFile = (Join-Path (Resolve-Path ~) ".vimrc")
    $TargetFile = (Join-Path $install_dir ".vim" "_vimrc")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null

    $SymbolicFile = (Join-Path (Resolve-Path ~) ".vim")
    $TargetFile = (Join-Path $install_dir ".vim")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null

    # Windows requires the plugins to be in ~/vimfiles and not ~/.vim
    # So symlink both...
    $SymbolicFile = (Join-Path (Resolve-Path ~) "vimfiles")
    $TargetFile = (Join-Path $install_dir ".vim")
    Write-Host "Installing $SymbolicFile ==> $TargetFile"
    New-Item -ItemType SymbolicLink -Force -Path $SymbolicFile -Target $TargetFile | Out-Null

    Write-Host "Installing vim plugins"
    vim +PlugInstall +qall
}

Function Install-GitRepo() {
    Param (
        [Parameter(Mandatory = $true)][string]$install_dir
    )
    $VerbosePreference = "Continue"
    if ($null -eq $env:XDG_DATA_HOME) {
        $env:XDG_DATA_HOME = (Join-Path (Resolve-Path ~) ".local" "share")
    }
    $GIT_REPO_DIR = (Join-Path $install_dir "tools" "git")
    Write-Verbose "GIT_REPO_DIR = $GIT_REPO_DIR"
    Write-Host "Starting to clone git repos..."
    if (Test-Path $GIT_REPO_DIR) {
        Get-ChildItem -Path (Join-Path $GIT_REPO_DIR "*") -Include *.clone | ForEach-Object {
            $FILE = (Get-Item $_)
            $REPO_FILE_NAME = $FILE.Basename
            $CLONE_PATH = (Join-Path $env:XDG_DATA_HOME "cloned-repos" $REPO_FILE_NAME)
            if (-not (Test-Path $CLONE_PATH)) {
                Write-Host "Need to make the git clone directory `"$CLONE_PATH`""
                New-Item -ItemType Directory -Path $CLONE_PATH | Out-Null
                & git -C "$CLONE_PATH" init -q
                & git -C "$CLONE_PATH" config remote.origin.url "$(Get-Content $FILE)"
                & git -C "$CLONE_PATH" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
                & git -C "$CLONE_PATH" config core.autocrlf "false"
            } else {
                Write-Host "Updating $REPO_FILE_NAME"
            }
            Write-Host "git -C `"$CLONE_PATH`" fetch origin master:origin/master --tags --force"
            & git -C "$CLONE_PATH" fetch origin master:origin/master --tags --force
            & git -C "$CLONE_PATH" reset --hard "origin/master"

            Write-Host ">>$GIT_REPO_DIR\$REPO_FILE_NAME`.install.ps1"
            & (Join-Path $GIT_REPO_DIR $REPO_FILE_NAME".install.ps1")
            Write-Host "          ...DONE"

        }
    }
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
$Option_Powershell = New-Object System.Management.Automation.Host.ChoiceDescription '&Powershell', 'User-level Configuration'
$Option_Tmux = New-Object System.Management.Automation.Host.ChoiceDescription '&TMUX', 'Configuration'
$Option_Vim = New-Object System.Management.Automation.Host.ChoiceDescription '&Vim', 'Configuration & Plugins'
$Option_GitRepo = New-Object System.Management.Automation.Host.ChoiceDescription 'Git &Repos', 'Direct Git repositories'
$Option_PowershellInstallers = New-Object System.Management.Automation.Host.ChoiceDescription 'P&owershell Installs', 'Installations from pure Powershell scripts'
$Option_Chocolatey = New-Object System.Management.Automation.Host.ChoiceDescription '&Chocolatey', 'Chocolatey packages'

$options = [System.Management.Automation.Host.ChoiceDescription[]](
    $Option_Bash,
    $Option_Git,
    $Option_Powershell,
    $Option_Tmux,
    $Option_Vim,
    $Option_PowershellInstallers,
    $Option_GitRepo,
    $Option_Chocolatey)
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
        Install-Bash $Install_Dir
    }
    $Option_Git.Label {
        Install-Git $Install_Dir
    }
    $Option_Tmux.Label {
        Install-Tmux $Install_Dir
    }
    $Option_Vim.Label {
        Install-Vim $Install_Dir
    }
    $Option_GitRepo.Label {
        Install-GitRepo $Install_Dir
    }
    $Option_Powershell.Label {
        Install-Powershell $Install_Dir
    }
    $Option_PowershellInstallers.Label {
        Install-PowershellInstallers $Install_Dir
    }
    $Option_Chocolatey.Label {
        Install-Chocolatey $Install_Dir
    }
    default {
        Write-Host "I have no idea what to do with `"$_`""
    }
}
