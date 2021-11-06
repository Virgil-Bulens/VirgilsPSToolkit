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