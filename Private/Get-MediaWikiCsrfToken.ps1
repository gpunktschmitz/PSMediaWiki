function Get-MediaWikiCsrfToken {
  BEGIN {}
  PROCESS {
    $Parameter = 'action=query&meta=tokens&format=json'
    $RequestUri = $Script:_PSMediaWikiUrl, $Parameter -join '/api.php?'
    $RestResponse = Invoke-RestMethod -Method GET -Uri $RequestUri -WebSession $Script:_PSMediaWikiSession
    
    if($RestResponse.query.tokens.csrftoken -ne '+\') {
      $MediaWikiCsrfToken = $RestResponse.query.tokens.csrftoken
    } else {
      Throw 'csrftoken appears to be empty/not set. make sure you are logged in.'
    }
    
    return $MediaWikiCsrfToken
  }
  END{}
}