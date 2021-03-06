function Edit-MediaWikiPage {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Page,
    [Parameter(Mandatory = $true)]
    [string]$Text,
    [Parameter(Mandatory = $false)]
    [string]$Summary,
    [Parameter(Mandatory = $false)]
    [string]$TextManipulationOption
  )
  
  BEGIN {
    switch($TextManipulationOption) {
      'append' {
        $TextManipulationOption = 'appendtext'
      }
      'replace' {
        $TextManipulationOption = 'text'
      }
      default {
        $TextManipulationOption = 'prependtext'
      }
    }
  }
  
  PROCESS {
    $MediaWikiCsrfToken = $(Get-MediaWikiCsrfToken)
    if($MediaWikiCsrfToken -eq '+\') {
      Throw 'Bad Token.'
    }
    $Parameter = 'action=edit&format=json&bot=1&title=', $Page, '&', $TextManipulationOption, '=', [System.Web.HttpUtility]::UrlEncode($Text) -join ''
    if($Summary) {
      $Parameter = $Parameter, '&summary=', [System.Web.HttpUtility]::UrlEncode($Summary) -join ''
    }
    $Body = 'token=', [System.Web.HttpUtility]::UrlEncode($MediaWikiCsrfToken) -join ''
    $RequestUri = $Script:_PSMediaWikiUrl, $Parameter -join '/api.php?'
    $RestResponse = Invoke-RestMethod -Method POST -Uri $RequestUri -WebSession $Script:_PSMediaWikiSession -Body $Body
    #Export-Clixml -InputObject $RestResponse -Path $(Join-Path -Path $Env:tmp -ChildPath 'PSMediaWikiTempFile_Edit.txt')
  }
  
  END {
    if($RestResponse.edit.result -ne 'Success') {
      $LoginResult = $RestResponse.edit.result
      $LoginReason = $RestResponse.edit.reason
      Write-Error  "$LoginResult - $LoginReason"
      Throw 'Error editing page.'
    }
  }
}