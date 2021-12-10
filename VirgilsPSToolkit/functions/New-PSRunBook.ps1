#
# Quickstart PS Runbook from template
#
function New-PSRunbook
{
    [CmdletBinding()]
    param (
        # Name of the runbook
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Name,

        # Path
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string]
        $Path = ".\"
    )
    
    begin
    {
        $Name = $Name + ".ps1"

        $Content = @"
#
# Parameters
#
Param(

)


#
# Variables
#
`$ErrorActionPreference = "Stop"
`$AutomationVariables = @(

)

foreach (`$Variable in `$AutomationVariables)
{
    Set-Variable -Name `$Variable ``
        -Value ( Get-AutomationVariable -Name `$Variable )
}


#
# Authentication
#
# Az
Connect-AzAccount -Identity | Out-Null

# Azure AD
`$Context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
`$AADToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(`$Context.Account, `$Context.Environment, `$Context.Tenant.Id.ToString(), `$null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, `$null, "https://graph.windows.net").AccessToken
`$TenantId = `$Context.Tenant.Id

`$ConnectionParameters = @{
    'AadAccessToken' = `$AADToken
    'AccountId'      = `$Context.Account.Id 
    'TenantId'       = `$TenantId
}

Connect-AzureAD @ConnectionParameters | Out-Null


#
# Main
#

"@
    }
    
    process
    {
        New-Item -Path $Path `
            -Name $Name `
            -ItemType File `
            -Value $Content `
            -Force
    }
    
    end
    {
        
    }
}