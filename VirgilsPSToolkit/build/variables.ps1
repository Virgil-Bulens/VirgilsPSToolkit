$ManifestContent = Get-Content -Path $PSScriptRoot\..\VirgilsPSToolkit.psd1 -Raw 
$ManifestContent.Replace("<ModuleVersion>", "1.0")
Set-Content -Path $PSScriptRoot\..\VirgilsPSToolkit.psd1 -Value $ManifestContent -Force