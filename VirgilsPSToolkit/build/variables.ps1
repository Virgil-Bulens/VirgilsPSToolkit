$ManifestPath = "$PSScriptRoot\..\VirgilsPSToolkit.psd1"

# Update version in manifest file
$ManifestContent = Get-Content -Path $ManifestPath -Raw 
$ManifestContent.Replace("<ModuleVersion>", "1." + $env:GITHUB_RUN_NUMBER)


# Update functions to export in manifest file

# Set new content of manifest file
Set-Content -Path $ManifestPath -Value $ManifestContent -Force