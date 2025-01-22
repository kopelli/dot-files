. $PSScriptRoot\..\..\scripts\Start-Solution.ps1
. $PSScriptRoot\..\..\scripts\Exit-Session.ps1

Write-Warning -Message "Importing Dot Files"

# TODO: Should probably check that 'aws' and 'aws_completer' are available commands...
if (Get-Command -Name "aws" -ErrorAction SilentlyContinue) {
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
}

$moduleData = Import-PowerShellDataFile $PSScriptRoot\dot-files.psd1
Export-ModuleMember -Function $moduleData.FunctionsToExport -Alias $moduleData.AliasesToExport