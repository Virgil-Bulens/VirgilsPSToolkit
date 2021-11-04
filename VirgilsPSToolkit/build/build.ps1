$ManifestPath = "$PSScriptRoot\..\VirgilsPSToolkit.psd1"

# Update version in manifest file
$ManifestContent = Get-Content -Path $ManifestPath -Raw 
$ManifestContent = $ManifestContent.Replace("<ModuleVersion>", "1." + $env:GITHUB_RUN_NUMBER)


# Update functions to export in manifest file
$FunctionsFolderPath = "$PSScriptRoot\..\functions"
if ((Test-Path -Path $FunctionsFolderPath) -and ($FunctionNames = Get-ChildItem -Path $FunctionsFolderPath -Filter '*.ps1' | Select-Object -ExpandProperty BaseName))
{
    $FunctionStrings = $FunctionNames -join "','"
}
else
{
    $FunctionStrings = $null
}
$ManifestContent = $ManifestContent.Replace("<FunctionsToExport>", $FunctionStrings)

# Set new content of manifest file
Set-Content -Path $ManifestPath -Value $ManifestContent -Force