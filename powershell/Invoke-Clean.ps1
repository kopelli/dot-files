<#
.SYNOPSIS
    Performs the appropriate clean operation on the current directory
#>
[CmdletBinding(
    SupportsShouldProcess = $true,
    ConfirmImpact = 'Medium'
)] param(
    [switch]
    $Force,

    [switch]
    $IgnoredFilesOnly
)
begin {
    $script:WhatIfPreference = $WhatIfPreference
    $script:ConfirmPreference = $ConfirmPreference
    # Capture the actual preference before we force it...
    $script:VerbosePreference = $VerbosePreference
    $Confirm = $PSCmdlet.MyInvocation.BoundParameters["Confirm"].IsPresent ?? $false
    $yesToAll = $false
    $noToAll = $false

    if ($WhatIfPreference -and $Confirm) {
        Write-Error -Message "Cannot specify 'Confirm' and 'WhatIf' parameters together"
	exit 1
    }

    $isGitAvailable = $true
    Get-Command -Name "git" -ErrorAction SilentlyContinue -ErrorVariable GitCommandDoesNotExist | Out-Null
    if ($GitCommandDoesNotExist -ne $null) {
        $isGitAvailable = $false
    }

    if ($Force) {
       $yesToAll = $true
    }
    if ($Force -and -not $Confirm) {
       Write-Verbose -Message "Forcing without Confirm. Setting the ConfirmPreference to 'None'"
       $ConfirmPreference = 'None'
    }
}
process {
    function IgnoreWhatIf {
        param(
	    $commandToExecute
	)

	$WhatIfPreference = $false
	$ConfirmPreference = "High"
	& $commandToExecute
	$WhatIfPreference = $script:WhatIfPreference
	$ConfirmPreference = $script:ConfirmPreference
    }
    if ($isGitAvailable) {
        Write-Verbose -Message "Testing if we are in a git repository"

	$gitRootDirectory = IgnoreWhatIf { git rev-parse --show-toplevel 2>nul }
        # usage: git clean [-d] [-f] [-i] [-n] [-q] [-e <pattern>] [-x | -X] [--] [<pathspec>...]
        #     -q, --quiet               do not print names of files removed
        #     -n, --dry-run             dry run
        #     -f, --force               force
        #     -i, --interactive         interactive cleaning
        #     -d                        remove whole directories
        #     -e, --exclude <pattern>   add <pattern> to ignore rules
        #     -x                        remove ignored files, too
        #     -X                        remove only ignored files
	if ($gitRootDirectory) {
	   $exclusionPatterns = @("*.tfvars", ".env")
	   $parameters = @("-d") # We always want to remove whole directories
	   $parameters = $parameters + $(if ($WhatIfPreference) { @("--dry-run") } else { $null })
	   $parameters = $parameters + $(if ($Force) { @("--force") } else { $null })
	   $parameters = $parameters + $(if ($ConfirmPreference -eq "Low") { @("--interactive") } else { $null })
	   $parameters = $parameters + $(if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent ?? $true) { $null } else { @("--quiet") })
	   $parameters = $parameters + ("--exclude " + ($exclusionPatterns -join "#--exclude ")) -Split "#"
	   $parameters = $parameters + $(if ($IgnoredFilesOnly) { @("-X") } else { @("-x") })
	   $parameters = ($parameters | Where-Object { $_.length -gt 0 })
	   $command = (@("git","clean")+($parameters | Sort-Object)) -join " "
	   if (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($PWD, $command)) {
	       Invoke-Expression -Command $command
	   } else {
              if ($WhatIfPreference) {
	         Invoke-Expression -Command $command
	      } else {
	          Write-Debug "No action to perform based on combination of parameters"
	      }
	   }
	}
    }
}
