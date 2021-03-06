# Get public and private function files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
Foreach($import in @($Public + $Private)){
  Try {
    . $import.fullname
  }Catch {
    Write-Error -Message 'Failed to import function $($import.fullname): $_'
  }
}

# Load web assembly
Add-Type -AssemblyName System.Web

# Define script variables
$Script:_PSMediaWikiSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$Script:_PSMediaWikiUrl = $false
$Script:_PSMediaWikiTempFile = Join-Path -Path $Env:tmp -ChildPath 'PSMediaWikiTempFile.txt'

# Export variables and public functions
Export-ModuleMember -Variable *
Export-ModuleMember -Function $Public.Basename
