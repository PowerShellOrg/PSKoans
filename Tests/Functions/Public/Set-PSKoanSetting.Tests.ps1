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

Describe 'Set-PSKoanSetting' {

    BeforeAll {
        InModuleScope 'PSKoans' {
            $script:OldConfigPath = $script:ConfigPath
        }
    }

    AfterAll {
        InModuleScope 'PSKoans' {
            $script:ConfigPath = $script:OldConfigPath
        }
    }

    Context 'Settings file Exists' {

        Describe 'Setting values with -Name and -Value' {

            BeforeAll {
                $NewConfigPath = InModuleScope 'PSKoans' {
                    ($script:ConfigPath = "$TestDrive/config.json")
                }

                if (-not (Test-Path $TestDrive)) {
                    New-Item -ItemType File -Path "$TestDrive/config.json"
                }

                [PSCustomObject]@{
                    LibraryFolder = "$TestDrive/PSKoans"
                    Editor        = 'code'
                } |
                    ConvertTo-Json |
                    Set-Content -Path $NewConfigPath
            }

            AfterAll {
                Remove-Item -Path $NewConfigPath -Force
            }

            It 'should add a new setting: <Name> = <Value>' -TestCases @(
                @{ Name = 'TestSetting1'; Value = 'TestValue1' }
                @{ Name = 'LibraryFolder'; Value = "TestDrive:/PSKoans" }
                @{ Name = 'Editor'; Value = 'code-insiders' }
            ) {
                Set-PSKoanSetting -Name $Name -Value $Value

                Get-PSKoanSetting -Name $Name | Should -BeExactly $Value
                Get-Content -Path $NewConfigPath |
                    ConvertFrom-Json |
                    Select-Object -ExpandProperty $Name |
                    Should -BeExactly $Value
            }
        }

        Context 'Setting values with -Settings Hashtable' {

            BeforeAll {
                $NewConfigPath = InModuleScope 'PSKoans' {
                    ($script:ConfigPath = "$TestDrive/config.json")
                }

                if (-not (Test-Path $TestDrive)) {
                    New-Item -ItemType File -Path "$TestDrive/config.json"
                }

                [PSCustomObject]@{
                    LibraryFolder = "$TestDrive/PSKoans"
                    Editor        = 'code'
                } |
                    ConvertTo-Json |
                    Set-Content -Path $NewConfigPath
            }

            AfterAll {
                Remove-Item -Path $NewConfigPath -Force
            }

            It 'should add or overwrite multiple new settings' {
                $NewSettings = @{
                    TestSetting2  = "TestValue2"
                    LibraryFolder = "$TestDrive/PSKoans"
                }

                Set-PSKoanSetting -Settings $NewSettings
                $Settings = Get-PSKoanSetting

                $Settings.TestSetting2 | Should -BeExactly $NewSettings.TestSetting2
                $Settings.Editor | Should -BeExactly 'code'
                $Settings.LibraryFolder | Should -BeExactly $NewSettings.LibraryFolder
            }
        }
    }

    Context 'Settings file does not exist' {

        Describe 'Setting values with -Name and -Value' {

            BeforeAll {
                $NewConfigPath = InModuleScope 'PSKoans' {
                    ($script:ConfigPath = "$TestDrive/config.json")
                }

                $DefaultSettings = InModuleScope 'PSKoans' { $script:DefaultSettings }
            }

            BeforeEach {
                if (Test-Path -Path $NewConfigPath) {
                    Remove-Item -Path $NewConfigPath
                }
            }

            It 'correctly adds the setting: <Name> = <Value>' -TestCases @(
                @{ Name = 'TestSetting1' ; Value = 'TestValue1' }
                @{ Name = 'Editor'; Value = 'TestEditor' }
                @{ Name = 'LibraryFolder'; Value = "$env:TEMP/TestFolder" }
            ) {
                $NewConfigPath | Should -Not -Exist
                Set-PSKoanSetting -Name $Name -Value $Value
                $NewConfigPath | Should -Exist

                $NewSettings = Get-PSKoanSetting
                $NewSettings.$Name | Should -BeExactly $Value

                # Other settings should remain as their defaults
                $DefaultSettings.Keys.Where{ $_ -ne $Name }.ForEach{
                    $NewSettings.$_ | Should -BeExactly $DefaultSettings.$_
                }
            }
        }

        Context 'Setting values with -Settings Hashtable' {

            BeforeAll {
                $NewConfigPath = InModuleScope 'PSKoans' {
                    ($script:ConfigPath = "$TestDrive/config.json")
                }

                $DefaultSettings = InModuleScope 'PSKoans' { $script:DefaultSettings }
            }

            BeforeEach {
                if (Test-Path -Path $NewConfigPath) {
                    Remove-Item -Path $NewConfigPath
                }
            }

            It 'adds and replaces values: <Settings>' -TestCases @(
                @{ Settings = @{ TestSetting1 = 'TestValue1'; Editor = 'TestEditor' } }
                @{ Settings = @{ LibraryFolder = "$TestDrive/TestFolder"; TestSetting2 = 'TestValue2' } }
            ) {
                $NewConfigPath | Should -Not -Exist
                Set-PSKoanSetting -Settings $Settings
                $NewConfigPath | Should -Exist

                $NewSettings = Get-PSKoanSetting
                $Settings.Keys.ForEach{
                    $NewSettings.$_ | Should -BeExactly $Settings.$_
                }
                $NewSettings.Keys.Where{ $_ -notin $Settings.Keys }.ForEach{
                    $NewSettings.$_ | Should -BeExactly $DefaultSettings.$_
                }
            }
        }
    }
}
