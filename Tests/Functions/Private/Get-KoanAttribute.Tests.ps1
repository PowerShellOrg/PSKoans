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

Describe 'Get-KoanAttribute' {

    BeforeAll {
        $filePath = @{
            Path = Join-Path $TestDrive  -ChildPath 'AboutSomething.Koans.ps1'
        }
    }

    Context 'Content has no errors' {

        BeforeAll {
            Mock 'Get-KoanAst' -ModuleName 'PSKoans' {
                {
                    [Koan(Position = 1)]
                    param()

                    Describe 'About something' {

                        It 'Has examples' {
                            $true | Should -BeTrue
                        }
                    }
                }.Ast
            }
        }

        It 'gets the position argument from the Koan attribute' {
            $attributeInfo = InModuleScope 'PSKoans' -Parameters $filePath {
                param($Path)
                Get-KoanAttribute $Path
            }

            $attributeInfo | Should -Not -BeNullOrEmpty
            $attributeInfo.Position | Should -Be 1
        }

        It 'uses a default value for Module when it is not set' {
            $attributeInfo = InModuleScope 'PSKoans' -Parameters $filePath {
                param($Path)
                Get-KoanAttribute $Path
            }

            $attributeInfo | Should -Not -BeNullOrEmpty
            $attributeInfo.Module | Should -Be ([KoanAttribute]::new().Module)
        }
    }

    Context 'Module declared' {

        BeforeAll {
            Mock 'Get-KoanAst' -ModuleName 'PSKoans' {
                {
                    [Koan(Position = 1, Module = 'Name')]
                    param()

                    Describe 'About something' {

                        It 'has examples' {
                            $true | Should -BeTrue
                        }
                    }
                }.Ast
            }
        }

        It 'retrieves the value for the module when it is set' {
            $attributeInfo = InModuleScope 'PSKoans' -Parameters $filePath {
                param($Path)
                Get-KoanAttribute $Path
            }

            $attributeInfo | Should -Not -BeNullOrEmpty
            $attributeInfo.Position | Should -Be 1
            $attributeInfo.Module | Should -Be 'Name'
        }
    }

    Context 'Full attribute name used' {

        BeforeAll {
            Mock 'Get-KoanAst' -ModuleName 'PSKoans' {
                {
                    [KoanAttribute(Position = 1)]
                    param( )

                    Describe 'About something' {
                        It 'Has examples' {
                            $true | Should -BeTrue
                        }
                    }
                }.Ast
            }
        }

        It 'still returns attribute information when the full name is used' {
            $attributeInfo = InModuleScope 'PSKoans' -Parameters $filePath {
                param($Path)
                Get-KoanAttribute $Path
            }

            $attributeInfo | Should -Not -BeNullOrEmpty
            $attributeInfo.Position | Should -Be 1
        }
    }

    Context 'Content has errors' {

        BeforeAll {
            Set-Content @filePath -Value @'
                [Koan(Position = 1)]
                param()

                Describe 'About something' {
                    It 'has examples' {
                        -not ____ | Should -BeTrue
                    }
                }
'@
        }

        It 'retrieves the Koan attribute even if the file has syntax errors' {
            $attributeInfo = InModuleScope 'PSKoans' -Parameters $filePath {
                param($Path)
                Get-KoanAttribute $Path
            }

            $attributeInfo | Should -Not -BeNullOrEmpty
            $attributeInfo.Position | Should -Be 1
        }
    }

    Context 'Attribute is missing' {

        BeforeAll {
            Mock 'Get-KoanAst' -ModuleName 'PSKoans' {
                {
                    param()

                    Describe 'About something' {
                        It 'Has examples' {
                            $true | Should -BeTrue
                        }
                    }
                }.Ast
            }
        }

        It 'When the Koan attribute is missing, returns nothing' {
            $attributeInfo = InModuleScope 'PSKoans' -Parameters $filePath {
                param($Path)
                Get-KoanAttribute $Path
            }

            $attributeInfo | Should -BeNullOrEmpty
        }
    }
}
