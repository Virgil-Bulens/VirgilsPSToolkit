#
# Functions
#
function New-GitProject
{
    [CmdletBinding()]
    param (
        # Name
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Name
    )
    
    begin
    {
        #
        # Variables
        #
        $LicenseUrl = "https://www.gnu.org/licenses/gpl-3.0.md"
        $Params = @{
            'ItemType' = 'File'
            'Force'    = $true
        }
    }
    
    process
    {
        # Create LICENSE.md
        $Content = Invoke-RestMethod -Uri $LicenseUrl
        New-Item @Params -Name "LICENSE.md" -Value $Content

        # Create README.md
        $Content = "# $Name"
        New-Item @Params -Name "README.md" -Value $Content

        # Create .gitignore
        New-Item @Params -Name ".gitignore"

        # Git init, add and first commit
        git init
        git add --all
        git commit -m "first commit"
    }
    
    end
    {
        
    }
}

function New-PSModule
{
    [CmdletBinding()]
    param (
        # Name of the module
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Name,

        # Author of the module
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string]
        $Author
    )
    
    begin
    {
        $ManifestPath = ".\" + $Name + ".psd1"
        $ModulePath = $ManifestPath.Replace(".psd1", ".psm1")

        $Params = @{
            'Author'                 = $Author
            'ModuleVersion'          = "0.1"
            'PowerShellVersion'      = $PSVersionTable.PSVersion
            'DotNetFrameworkVersion' = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty  -Name Version -ErrorAction SilentlyContinue | Where-Object PSPath -Like "*\Full" | ForEach-Object Version
            'ProcessorArchitecture'  = $env:PROCESSOR_ARCHITECTURE
            'CompatiblePSEditions'   = "Desktop", "Core"
            'Path'                   = $ManifestPath
        }
    }
    
    process
    {
        New-ModuleManifest @Params
        New-Item -Path $ModulePath -ItemType File
    }
    
    end
    {
        
    }
}

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
    New-Variable -Name `$Variable -Value ( Get-AutomationVariable -Name `$Variable )
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
        New-Item -Path $Path -Name $Name -ItemType File -Value $Content -Force
    }
    
    end
    {
        
    }
}