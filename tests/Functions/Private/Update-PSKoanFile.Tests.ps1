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

Describe 'Update-PSKoanFile' {

    BeforeAll {
        $koanLocation = Join-Path -Path $TestDrive -ChildPath 'Koans'
        $koanRelativePath = 'Group/AboutSomething.ps1'
        $moduleKoanPath = Join-Path -Path $TestDrive -ChildPath 'Module/Group/AboutSomething.ps1'

        Mock 'Get-PSKoanLocation' -ModuleName 'PSKoans' { $koanLocation }
        Mock 'Get-PSKoan' -ModuleName 'PSKoans' {
            [PSCustomObject]@{
                Topic        = 'AboutSomething'
                Path         = $moduleKoanPath
                RelativePath = $koanRelativePath
            }
        }

        New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'Koans/Group') -ItemType Directory
        New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'Module/Group') -ItemType Directory

        Set-Content -Path $moduleKoanPath -Value @'
            Describe 'AboutSomething' {
                It 'koan 1' {
                    __ | Should -Be 1
                }

                It 'koan 2' {
                    __ | Should -Be 2
                }

                Context 'first' {
                    It 'koan 3' {
                        __ | Should -Be 3
                    }
                }

                Context 'second' {
                    It 'koan 4' {
                        __ | Should -Be 4
                    }
                }
            }
'@

        $userFilePath = Join-Path -Path $koanLocation -ChildPath $koanRelativePath
    }

    BeforeEach {
        Set-Content -Path $userFilePath -Value @'
            Describe 'AboutSomething' {
                It 'koan 1' {
                    1 | Should -Be 1
                }

                It 'koan 2' {
                    __ | Should -Be 2
                }

                Context 'second' {
                    It 'koan 4' {
                        4 | Should -Be 4
                    }
                }
            }
'@
    }

    It 'should replay completed koans' {
        InModuleScope 'PSKoans' { Update-PSKoanFile -Topic AboutSomething -Confirm:$false }

        $userFilePath | Should -FileContentMatch '1 | Should -Be 1'
        $userFilePath | Should -FileContentMatch '__ | Should -Be 2'
        $userFilePath | Should -FileContentMatch '4 | Should -Be 4'
    }

    It 'should should allow new koans to be inserted' {
        InModuleScope 'PSKoans' { Update-PSKoanFile -Topic AboutSomething -Confirm:$false }

        $userFilePath | Should -FileContentMatch 'koan 3'
    }
}
