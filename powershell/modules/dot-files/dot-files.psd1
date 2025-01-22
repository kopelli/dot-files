@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'dot-files.psm1'

    # Version number of this module
    ModuleVersion = '0.1.0'

    # ID used to uniquely identify this module
    GUID = '...'

    # Author(s)
    Author = 'Steven Evans'

    #Copyright statement for module
    Copyright = '(c) 2025'

    # Description
    Description = "Custom module"

    # Minimum version of Powershell Engine
    PowerShellVersion = '7.0'

    # Funcs
    FunctionsToExport = @(
        'QuitReplacement',
        'Start-Solution'
    )

    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @(
        ':q',
        'quit',
        'sln'
    )
    PrivateData = @{
        PSData = @{
            Tags = @()
            LicenseUri = ''
            ProjectUri = ''
            ReleaseNotes = ''
            Prerelease = ''
        }
    }
}