Each Chocolatey package to be installed must exist in a `.psm1` file.
The use of the modules it to allow a consistent export of two known functions for each utility: `Get-PackageName` and `Test-IsInstalled`.

Get-PackageName
===============

This function simply returns the Chocolatey package name to be installed.
This could be the bare package name, or a ".install" or ".portable" variation.

Test-IsInstalled
================

This function will determine if the package is already installed.
Usually, a specific executable will be available in the environment when the utility is installed.
Thus, most implementations are as simple as using the `Get-Command` action to test for existence.
It is important to include the "-ErrorAction SilentlyContinue" parameter so the overall script does not stop should the utility not be installed yet.