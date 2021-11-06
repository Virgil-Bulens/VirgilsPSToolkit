Set-StrictMode -Version Latest
# Get public and private function definition files.

$Functions = @(Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files.
foreach ($Function in $Functions)
{
    try
    {
        Write-Verbose "Importing $($Function.FullName)"
        . $Function.FullName
    }
    catch
    {
        Write-Error "Failed to import function $($Function.FullName): $_"
    }

    Export-ModuleMember -Function $Function.BaseName
}
