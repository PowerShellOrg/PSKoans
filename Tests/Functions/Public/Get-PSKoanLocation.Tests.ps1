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

Describe 'Get-PSKoanLocation' {

    Context 'Normal Behaviour' {

        BeforeAll {
            Mock 'Get-PSKoanSetting' -ParameterFilter { $Name -eq 'KoanLocation' } -ModuleName 'PSKoans' -MockWith {
                '~/PSKoans'
            }

            $Result = Get-PSKoanLocation
        }

        It 'retrieves the koan library location' {
            $Result | Should -Be '~/PSKoans'
        }

        It 'calls Get-PSKoanSetting with -Name "KoanLocation"' {
            Should -Invoke 'Get-PSKoanSetting' -Scope Context -ModuleName 'PSKoans'
        }
    }

    Context 'No Value Available' {

        BeforeAll {
            Mock 'Get-PSKoanSetting' -ParameterFilter { $Name -eq 'KoanLocation' } -ModuleName 'PSKoans'
        }

        It 'throws an error if no value can be retrieved' {
            { Get-PSKoanLocation } | Should -Throw -ExpectedMessage 'PSKoans folder location has not been defined'
        }
    }
}
