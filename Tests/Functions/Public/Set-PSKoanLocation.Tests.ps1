#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeDiscovery {
    if ($null -eq $env:BHProjectName) {
        .\build.ps1 -Task Build
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

Describe 'Set-PSKoanLocation' {

    BeforeAll {
        Mock 'Set-PSKoanSetting' -ParameterFilter { $Name -eq 'KoanLocation' } -ModuleName 'PSKoans'
    }

    It 'outputs no data by default' {
        Set-PSKoanLocation -Path 'TestDrive:/PSKoans/' | Should -BeNullOrEmpty
    }

    It 'sets the KoanLocation setting' {
        Should -Invoke 'Set-PSKoanSetting' -Scope Describe -ModuleName 'PSKoans'
    }

    It 'returns the input -Path value back to the pipeline with -PassThru' {
        $ResolvedPath = Resolve-Path -Path '~' | Join-Path -ChildPath '/PSKoans/'
        Set-PSKoanLocation -Path '~/PSKoans/' -PassThru | Should -BeExactly $ResolvedPath
    }
}
