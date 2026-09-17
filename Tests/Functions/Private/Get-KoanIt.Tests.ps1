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

Describe 'Get-KoanIt' {

    BeforeAll {
        $defaultParams = @{
            Path = Join-Path $TestDrive 'AboutSomething.Koans.ps1'
        }
    }

    Context 'Content has no errors' {

        BeforeAll {
            Mock 'Get-KoanAst' -ModuleName 'PSKoans' {
                {
                    [Koan(Position = 1)]
                    param( )

                    Describe 'About something' {
                        It 'first' {
                            $true | Should -BeTrue
                        }

                        It 'second' {
                            $true | Should -BeTrue
                        }
                    }
                }.Ast
            }
        }

        It 'returns all information about all It blocks' {
            $ItCommands = InModuleScope 'PSKoans' -Parameters $defaultParams {
                param($Path)
                Get-KoanIt $Path
            }

            $ItCommands | Should -Not -BeNullOrEmpty
            $ItCommands.Count | Should -Be 2
        }
    }

    Context 'Content has errors' {

        BeforeAll {
            Set-Content @defaultParams -Value @'
                    [Koan(Position = 1)]
                    param( )

                    Describe 'About something' {
                        It 'first' {
                            -not ____ | Should -BeTrue
                        }

                        It 'second' {
                            $true | Should -BeTrue
                        }
                    }
'@
        }

        It 'Retrieves all It blocks when the file has syntax errors' {
            $ItCommands = InModuleScope 'PSKoans' -Parameters $defaultParams {
                param($Path)
                Get-KoanIt $Path
            }

            $ItCommands | Should -Not -BeNullOrEmpty
            $ItCommands.Count | Should -Be 2
        }
    }
}
