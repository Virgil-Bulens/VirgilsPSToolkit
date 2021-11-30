#
# Create webhook runbook from existing runbook
#
function New-PSRunBookWebhook
{
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
    
    begin
    {
        $ErrorActionPreference = "Stop"
        $RunbookFile = Get-Item -Path $Runbook
        $WebhookFileName = "Invoke-" + ( $RunbookFile.BaseName -replace "-" ) + "FromWebhook.ps1"

        $Content = @"
#
# Parameters
#
Param(
    # WebhookData
    [Parameter(
        Mandatory = `$true,
        Position = 0
    )]
    [object]
    `$WebhookData
)


#
# Variables
#
`$ErrorActionPreference = "Stop"
`$RunbookName = <RunbookNamePlaceholder>


#
# WebhookData
#
`$WebhookParameters = @(
    <ParametersPlaceholder>
)

`$Body = ConvertFrom-Json -InputObject `$WebhookData.RequestBody

`$ChildRunbookParameters = @{}

foreach (`$Parameter in $`WebhookParameters)
{
    `$Variable = New-Variable -Name `$Parameter ``
                              -Value `$Body.`$Parameter ``
                              -PassThru
    `$ChildRunbookParameters.Add(`$Variable.Name, `$Variable.Value)
}


#
# Authentication
#
# Az
Connect-AzAccount -Identity | Out-Null


#
# Metadata
#
`$AutomationMetaData = @{}

`$JobId = `$PSPrivateMetadata.JobId.Guid
`$AutomationAccounts = Get-AzResource -ResourceType Microsoft.Automation/AutomationAccounts

foreach (`$AutomationAccount in `$AutomationAccounts)
{
    `$Job = Get-AzAutomationJob -Id `$JobId ``
                                -ResourceGroupName `$AutomationAccount.ResourceGroupName ``
                                -AutomationAccountName `$AutomationAccount.Name ``
                                -ErrorAction SilentlyContinue

    if (!([string]::IsNullOrEmpty(`$Job)))
    {
        `$AutomationMetaData.Add("SubscriptionId", `$AutomationAccount.SubscriptionId)
        `$AutomationMetaData.Add("Location", `$AutomationAccount.Location)
        `$AutomationMetaData.Add("ResourceGroupName", `$Job.ResourceGroupName)
        `$AutomationMetaData.Add("AutomationAccountName", `$Job.AutomationAccountName)
        `$AutomationMetaData.Add("RunbookName", `$Job.RunbookName)
        `$AutomationMetaData.Add("JobId", `$Job.JobId.Guid)
        break;
    }
}

`$RunbookResourceGroupName = `$AutomationMetaData.ResourceGroupName
`$RunbookAutomationAccountName = `$AutomationMetaData.AutomationAccountName

`$RunbookParameters = @{
    'Name'                  = `$RunbookName
    'Wait'                  = `$true
    'AutomationAccountName' = `$RunbookAutomationAccountName
    'ResourceGroupName'     = `$RunbookResourceGroupName

}

#
# Main
#
if ( `$ChildRunbookParameters.Count -gt 0 )
{
    `$RunbookParameters.Add('Parameters', `$ChildRunbookParameters)
}
Start-AzAutomationRunbook @RunbookParameters
"@
    }
    
    process
    {
        # Get runbook's parameters
        $Command = Get-Command $Runbook
        try
        {
            [array]$Parameters = $Command.ParameterSets.Parameters | `
                Where-Object { ($_.Attributes.TypeId.Name -eq "ArgumentTypeConverterAttribute") -or ( $_.ParameterType.Name -eq "Object" ) } | `
                ForEach-Object Name
        }
        catch
        {
            [array]$Parameters = @()
        }

        $ParametersToInsert = @()

        foreach ($Parameter in $Parameters)
        {
            $ParametersToInsert += "`"$Parameter`","
        }

        $ParametersToInsert = ($ParametersToInsert | Out-String).Trim() -replace ".$"

        # Replace content
        $Content = $Content -replace "<RunbookNamePlaceholder>", "`"$($RunbookFile.BaseName)`"" -replace "<ParametersPlaceholder>", $ParametersToInsert

    }
    
    end
    {
        # Write file
        New-Item -Path $WebhookFileName `
            -ItemType File `
            -Value $Content `
            -Force
    }
}