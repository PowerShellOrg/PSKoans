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

Describe Reset-PSKoan {

    BeforeAll {
        $script:defaultParams = @{
            Confirm = $false
        }

        $koanLocation = Join-Path -Path $TestDrive -ChildPath 'PSKoans'
        $moduleKoanPath = Join-Path -Path $TestDrive -ChildPath 'Module\Group\AboutSomething.Koans.ps1'

        Mock 'Get-PSKoanLocation' -ModuleName 'PSKoans' { $koanLocation }

        Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'Module' } -ModuleName 'PSKoans' -MockWith {
            [PSCustomObject]@{
                Topic        = 'AboutSomething'
                Path         = $moduleKoanPath
                RelativePath = 'Group\AboutSomething.Koans.ps1'
            }
        }

        Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'User' } -ModuleName 'PSKoans' -MockWith {
            [PSCustomObject]@{
                Topic        = 'AboutSomething'
                Path         = $userFilePath
                RelativePath = 'Group\AboutSomething.Koans.ps1'
            }
        }

        New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'Module\Group') -ItemType Directory
        New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'PSKoans\Group') -ItemType Directory

        $userFilePath = Join-Path -Path $koanLocation -ChildPath 'Group\AboutSomething.Koans.ps1'

        Set-Content -Path $moduleKoanPath, $userFilePath -Value @'
            using module PSKoans
            [Koan(Position = 1)]
            param ( )

            Describe 'AboutSomething' {
                It 'existing content' {
                    __ | Should -Be 1
                }

                It 'reset content' {
                    __ | Should -Be 2
                }

                Context 'first' {
                    It 'nested reset content' {
                        __ | Should -Be 3
                    }
                }

                Context 'second' {
                    It 'nested reset content' {
                        __ | Should -Be 4
                    }
                }
            }
'@
    }

    Context 'User file exists, It block exists' {

        BeforeAll {
            Mock 'Set-Content' -ModuleName 'PSKoans'
            Mock 'Copy-Item' -ModuleName 'PSKoans'
        }

        It 'updates an existing user file when -Name is supplied' {
            Reset-PSKoan -Name 'existing content' @defaultParams

            Should -Invoke 'Set-Content' -Times 1 -ModuleName 'PSKoans'
            Should -Invoke 'Copy-Item' -Times 0 -ModuleName 'PSKoans'
        }

        It 'updates an existing user file when -Context is supplied' {
            Reset-PSKoan -Context 'first' @defaultParams

            Should -Invoke 'Set-Content' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Copy-Item' -Times 0 -ModuleName 'PSKoans'
        }

        It 'updates an existing user file when -Name and -Context are supplied' {
            Reset-PSKoan -Name 'nested reset content' -Context 'first' @defaultParams

            Should -Invoke 'Set-Content' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Copy-Item' -Times 0 -ModuleName 'PSKoans'
        }

        It 'copies a koan file from the module when -Name and -Context are not supplied' {
            Reset-PSKoan @defaultParams

            Should -Invoke 'Set-Content' -Times 0 -ModuleName 'PSKoans'
            Should -Invoke 'Copy-Item' -Times 1 -Exactly -ModuleName 'PSKoans'
        }
    }

    Context 'User file exists, It block does not exist' {

        It 'writes a non-terminating error when the user file does not include the specified Koan' {
            $realGetKoanIt = InModuleScope 'PSKoans' { Get-Item -Path 'Function:\Get-KoanIt' }
            Mock 'Get-KoanIt' -ModuleName 'PSKoans' -MockWith { & $realGetKoanIt @args }
            Mock 'Get-KoanIt' -ParameterFilter { $Path -match 'PSKoans' } -ModuleName 'PSKoans'

            { Reset-PSKoan -Topic AboutSomething -Name 'existing content' -ErrorAction Stop @defaultParams } |
                Should -Throw -ErrorId 'PSKoans.UserItNotFound,Reset-PSKoan'
        }
    }

    Context 'User file does not exist' {

        BeforeAll {
            New-Item "$TestDrive/DoesNotExist.Koans.ps1" -ItemType File > $null

            Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'User' } -Verifiable -ModuleName 'PSKoans'
            Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'Module' } -Verifiable -ModuleName 'PSKoans' -MockWith {
                [PSCustomObject]@{
                    Topic        = $Topic
                    Module       = '_powershell'
                    Position     = 101
                    Path         = "$TestDrive/DoesNotExist.Koans.ps1"
                    RelativePath = 'DoesNotExist.Koans.ps1'
                    PSTypeName   = 'PSKoans.KoanInfo'
                }
            }

            Mock 'Update-PSKoan' -ModuleName 'PSKoans'
        }

        It 'calls Update-PSKoan when the topic does not exist in the user location' {
            Reset-PSKoan -Topic DoesNotExist -ErrorAction Stop @defaultParams

            Should -InvokeVerifiable
            Should -Invoke Update-PSKoan -Times 1 -Exactly -ModuleName 'PSKoans'
        }
    }

    Context 'Module file does not exist' {

        BeforeAll {
            Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'Module' } -ModuleName 'PSKoans'
            Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'User' } -ModuleName 'PSKoans'
        }

        It 'throws a terminating error when no topics are found in the module' {
            { Reset-PSKoan -Topic DoesNotExist @defaultParams } |
                Should -Throw -ErrorId 'PSKoans.ModuleTopicNotFound,Reset-PSKoan'

            Should -Invoke 'Get-PSKoan' -Times 1 -Exactly -ParameterFilter { $Scope -eq 'Module' } -ModuleName 'PSKoans'
        }
    }

    Context 'Practical tests' {

        BeforeEach {
            Set-Content -Path $userFilePath -Value @'
                using module PSKoans
                [Koan(Position = 1)]
                param ( )

                Describe 'AboutSomething' {
                    It 'existing content' {
                        1 | Should -Be 1
                    }

                    It 'reset content' {
                        1 | Should -Be 2
                    }

                    Context 'first' {
                        It 'nested reset content' {
                            3 | Should -Be 3
                        }
                    }

                    Context 'second' {
                        It 'nested reset content' {
                            4 | Should -Be 4
                        }
                    }
                }
'@
        }

        It 'should reset all koans in a file when Name is not specified' {
            $userFilePath | Should -FileContentMatch '__ | Should -Be 1'
            $userFilePath | Should -FileContentMatch '__ | Should -Be 2'
            $userFilePath | Should -FileContentMatch '__ | Should -Be 3'
            $userFilePath | Should -FileContentMatch '__ | Should -Be 4'
        }

        It 'should reset the state of a single koan without affecting others when Name is specified' {
            Reset-PSKoan -Topic AboutSomething -Name 'reset content' @defaultParams

            $userFilePath | Should -FileContentMatch '1 | Should -Be 1'
            $userFilePath | Should -FileContentMatch '__ | Should -Be 2'
        }

        It 'supports context based searching' {
            Reset-PSKoan -Topic AboutSomething -Name "nested reset content" -Context 'first' @defaultParams

            $userFilePath | Should -FileContentMatch '__ | Should -Be 3'
            $userFilePath | Should -FileContentMatch '4 | Should -Be 4'
        }

        It 'allows koans of a given name to be reset across all contexts' {
            Reset-PSKoan -Topic AboutSomething -Name "nested reset content" @defaultParams

            $userFilePath | Should -FileContentMatch '__ | Should -Be 3'
            $userFilePath | Should -FileContentMatch '__ | Should -Be 4'
        }

        It 'supports wildcard patterns when matching name' {
            Reset-PSKoan -Topic AboutSomething -Name "*content" @defaultParams

            $userFilePath | Should -FileContentMatch '__ | Should -Be 1'
            $userFilePath | Should -FileContentMatch '__ | Should -Be 2'
        }
    }
}
