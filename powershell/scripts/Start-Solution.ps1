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
