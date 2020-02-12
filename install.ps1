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
Write-Host "Hello!"