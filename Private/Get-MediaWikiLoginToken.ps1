function Get-MediaWikiLoginToken {
  BEGIN {}
  PROCESS {
    $Parameter = 'action=query&meta=tokens&type=login&format=json'
    $RequestUri = $Script:_PSMediaWikiUrl, $Parameter -join '/api.php?'
    $RestResponse = Invoke-RestMethod -Method GET -Uri $RequestUri -WebSession $Script:_PSMediaWikiSession
    
    $MediaWikiLoginToken = $RestResponse.query.tokens.logintoken
    return $MediaWikiLoginToken
  }
  END{}
}