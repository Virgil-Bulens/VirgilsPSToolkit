function Get-Uninstallers
{
    #
    # Parameters
    #
    Param (
        # Search String
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [string]
        $SearchString = "*"
    )

    #
    # Variables
    #
    $ErrorActionPreference = "Stop"
    $Paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
        "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKU:\*\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

    )
    $List = @()
    

    
    #
    # Main
    #
    New-PSDrive -Name HKU `
        -PSProvider Registry `
        -Root HKEY_USERS `
        -ErrorAction SilentlyContinue | `
        Out-Null

    foreach ( $Path in $Paths )
    {
        $List += Get-ChildItem -Path $Path `
            -ErrorAction SilentlyContinue | `
            Get-ItemProperty | `
            Select-Object DisplayName, UninstallString, QuietUninstallString | `
            Where-Object DisplayName -Like "*$($SearchString)*" | `
            Where-Object { ( ( -not ( [string]::IsNullOrEmpty($_.UninstallString) ) ) -or ( -not ( [string]::IsNullOrEmpty($_.QuietUninstallString) ) ) ) }
    }

    $List | `
        Sort-Object -Property DisplayName
        

}