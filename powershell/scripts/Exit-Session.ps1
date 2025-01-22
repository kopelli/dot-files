Function QuitReplacement {
       Invoke-Command -ScriptBlock { exit }
}
Set-Alias -Name Quit -Value QuitReplacement
Set-Alias -Name ":q" -Value QuitReplacement
