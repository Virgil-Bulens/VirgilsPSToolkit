Install-Module -Name PSScriptAnalyzer -Force

Describe 'Module-level tests' {
    It 'the module imports successfully' {
        { Import-Module "$PSScriptRoot\..\VirgilsPSToolkit.psm1" -ErrorAction Stop } | Should -Not -Throw
    }

    It 'the module has an associated manifest' {
        Test-Path "$PSScriptRoot\..\VirgilsPSToolkit.psm1" | Should -Be $true
    }

    It 'passes all default PSScriptAnalyzer rules' {
        Invoke-ScriptAnalyzer -Path "$PSScriptRoot\..\VirgilsPSToolkit.psm1" | Should -BeNullOrEmpty
    }
}