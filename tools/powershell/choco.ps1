Get-Command choco -ErrorVariable ChocoError -ErrorAction SilentlyContinue | Out-Null
if ($ChocoError) {
    # Chocolatey is not installed (or at least can't be found), so install it
    $Script:CurrentExecutionPolicy = Get-ExecutionPolicy
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Set-ExecutionPolicy $Script:CurrentExecutionPolicy -Scope Process -Force
} else {
    & choco upgrade all --yes
}