#
# Create webhook runbook from existing runbook
#
function New-PSRunBookWebhook {
    [CmdletBinding()]
    param (
        # Path to the runbook to create webhook from
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Runbook
    )
    
    begin {
        $ErrorActionPreference = "Stop"
        $RunbookFile = Get-Item -Path $Runbook
    }
    
    process {
        
    }
    
    end {
        
    }
}