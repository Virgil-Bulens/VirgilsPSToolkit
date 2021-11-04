#
# Quickstart git project
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