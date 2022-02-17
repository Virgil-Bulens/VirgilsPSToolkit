function New-BicepTemplate
{
    param (
        # Name of the template
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [string]
        $Name = "azuredeploy",

        # Path to write the file
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string]
        $Path = "./"
    )
    
    #
    # Variables
    #
    $FileName = $Name + ".bicep"
    $Value = @"
//
// Parameters
//
param location string = resourceGroup().location


//
// Resources
//

"@


    #
    # Main
    #
    New-Item -ItemType File `
        -Name $FileName `
        -Value $Value `
        -Path $Path `
        -Force

}