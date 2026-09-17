#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeDiscovery {
    if ($null -eq $env:BHProjectName) {
        # Run the build in a child process -- build.ps1 calls `exit` on completion, which
        # would otherwise terminate the host process running this test file.
        & pwsh -NoProfile -File '.\build.ps1' -Task Build
        if ($LASTEXITCODE -ne 0) {
            throw 'Failed to build PSKoans before running tests.'
        }
        Set-BuildEnvironment -Force
    }
    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
    $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"
    $env:PSModulePath = $outputModDir + [IO.Path]::PathSeparator + $env:PSModulePath

    # Remove all versions of the module from the session. Pester can't handle multiple versions.
    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
}

Describe 'Get-Blank' {

    It 'should not produce output' {
        Get-Blank | Should -BeNullOrEmpty
    }

    It 'should be usable in the middle of a pipeline' {
        { Get-Variable | Get-Blank | Write-Output } | Should -Not -Throw
    }

    It 'should quietly ignore parameters' {
        { Get-Blank -Param1 Value1 -Param2 Value2 } | Should -Not -Throw
    }
}
