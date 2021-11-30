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
        $WebhookFileName = "Invoke-" + ( $RunbookFile.BaseName -replace "-" ) + "FromWebhook.ps1"
    }
    
    process {
        New-Item -Path $WebhookFileName `
                 -ItemType File `
                 -Value $Content `
                 -Force
    }
    
    end {
        
    }
}