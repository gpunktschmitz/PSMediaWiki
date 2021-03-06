function New-MediaWikiLogin {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [Parameter(Mandatory = $false)]
    [string]$Credential
  )
  
  BEGIN {
    if(-not $Credential) {
      $Credential = $(Get-Credential)
    }
    
    $Username = $Credential.UserName
    $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))
    
    $MediaWikiUrlLastCharacter = $MediaWikiUrl.Substring($MediaWikiUrl.Length-1)
    if($MediaWikiUrlLastCharacter -eq '/') {
      $Script:_PSMediaWikiUrl = $MediaWikiUrl.Substring(0,$MediaWikiUrl.Length-1)
    } else {
      $Script:_PSMediaWikiUrl = $MediaWikiUrl
    }
    
    $MediaWikiHttpStatusCode = $(Invoke-WebRequest -Uri $MediaWikiUrl).StatusCode
    if($MediaWikiHttpStatusCode -ne 200) {
      Write-Error """$MediaWikiUrl"" seems not to be ""200/OK"". (it is ""$MediaWikiHttpStatusCode"")"
      Throw "Please check the Url you entered."
    }
  }
  
  PROCESS {
    $MediaWikiLoginToken = Get-MediaWikiLoginToken
    $Parameter = 'action=login&format=json&lgname=', [System.Web.HttpUtility]::UrlEncode($MediaWikiUser), '&lgpassword=', [System.Web.HttpUtility]::UrlEncode($PlainTextPassword), '&lgtoken=', [System.Web.HttpUtility]::UrlEncode($MediaWikiLoginToken) -join ''
    $RequestUri = $Script:_PSMediaWikiUrl, $Parameter -join '/api.php?'
    $RestResponse = Invoke-RestMethod -Method POST -Uri $RequestUri -WebSession $Script:_PSMediaWikiSession
    #Export-Clixml -InputObject $RestResponse -Path $(Join-Path -Path $Env:tmp -ChildPath 'PSMediaWikiTempFile_Login.txt')
  }
  
  END {
    if($RestResponse.login.result -ne 'Success') {
      $LoginResult = $RestResponse.login.result
      $LoginReason = $RestResponse.login.reason
      Write-Error  "$LoginResult - $LoginReason"
      Throw 'Login to MediaWiki failed. Review your settings.'
    }
  }
}