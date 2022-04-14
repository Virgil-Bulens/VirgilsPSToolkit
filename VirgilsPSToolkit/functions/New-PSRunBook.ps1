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


#
# Authentication
#
# Az
if ( -not ( Get-AzContext -ErrorAction SilentlyContinue ) )
{
Connect-AzAccount -Identity | `
    Out-Null
}

# Azure AD
`$Context = Get-AzContext 

`$ConnectionParameters = @{
    'AadAccessToken' = Get-AzAccessToken -ResourceTypeName AadGraph | `
        ForEach-Object token
    'AccountId'      = `$Context.Account
    'TenantId'       = `$Context.Tenant
    'MsAccessToken'  = Get-AzAccessToken -ResourceTypeName MSGraph | `
        ForEach-Object token
}

Connect-AzureAD @ConnectionParameters | `
    Out-Null


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