function New-MediaWikiSession {
  BEGIN {}
  PROCESS {
    return New-Object Microsoft.PowerShell.Commands.WebRequestSession
  }
  END {}
}