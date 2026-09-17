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

Describe 'Measure-Koan' -Skip {

    BeforeAll {
        Set-Content -Path 'TestDrive:\TestCases.Koans.ps1' -Value @'
            Describe 'Test cases param' {
                It 'first <TestCase>' -TestCases @(
                    @{ TestCase = 1 }
                    @{ TestCase = 2 }
                    @{ TestCase = 3 }
                ) {
                    param($TestCase)

                    $TestCase | Should -BeOfType int
                }
            }
'@

        Set-Content -Path 'TestDrive:\JustIt.Koans.ps1' -Value @'
            Describe 'Just it' {
                It 'first' {
                    $true | Should -BeTrue
                }

                It 'second' {
                    $true | Should -BeTrue
                }
            }
'@

        Set-Content -Path TestDrive:\Mixed.Koans.ps1 -Value @'
            Describe 'Mixed' {
                It 'first' {
                    $true | Should -BeTrue
                }

                It 'second <TestCase>' -TestCases @(
                    @{ TestCase = 1 }
                    @{ TestCase = 2 }
                ) {
                    param($TestCase)

                    $TestCase | Should -BeOfType int
                }
            }
'@

        Set-Content -Path TestDrive:\MutlipleTestCases.Koans.ps1 -Value @'
            Describe 'Test cases param' {
                It 'first <TestCase>' -TestCases @(
                    @{ TestCase = 1 }
                    @{ TestCase = 2 }
                    @{ TestCase = 3 }
                ) {
                    param($TestCase)

                    $TestCase | Should -BeOfType int
                }

                It 'second <TestCase>' -TestCases @(
                    @{ TestCase = 1 }
                    @{ TestCase = 2 }
                    @{ TestCase = 3 }
                ) {
                    param($TestCase)

                    $TestCase | Should -BeOfType int
                }
            }
'@
    }

    It 'correctly counts the number of tests in <Path>, including -TestCases' -TestCases @(
        @{ Path = 'TestDrive:\TestCases.Koans.ps1'; ExpectedValue = 3 }
        @{ Path = 'TestDrive:\JustIt.Koans.ps1'; ExpectedValue = 2 }
        @{ Path = 'TestDrive:\Mixed.Koans.ps1'; ExpectedValue = 3 }
        @{ Path = 'TestDrive:\MutlipleTestCases.Koans.ps1'; ExpectedValue = 6 }
    ) {
        $koanInfo = [PSCustomObject]@{
            Path       = $Path
            PSTypeName = 'PSKoans.KoanInfo'
        }

        InModuleScope 'PSKoans' -Parameters @{ Koan = $koanInfo } {
            param($Koan)
            Measure-Koan $Koan
        } | Should -Be $ExpectedValue
    }
}
