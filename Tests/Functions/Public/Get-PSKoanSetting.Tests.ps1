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

Describe 'Get-PSKoanSetting' {

    BeforeAll {
        $configFilePath = 'TestDrive:/config.json'
        InModuleScope 'PSKoans' -Parameters @{ Path = $configFilePath } {
            param($Path)
            $script:OldConfigPath = $script:ConfigPath
            $script:ConfigPath = $Path
        }

        ${/} = [IO.Path]::DirectorySeparatorChar
    }

    AfterAll {
        InModuleScope 'PSKoans' {
            $script:ConfigPath = $script:OldConfigPath
        }
    }

    Context 'Settings file does not exist' {

        BeforeAll {
            Mock 'Set-PSKoanSetting' -ParameterFilter { $Settings -is [hashtable] } -ModuleName 'PSKoans'
            $DefaultSettings = InModuleScope 'PSKoans' { $script:DefaultSettings }
        }
`
        It 'returns the default settings' {
            $Result = Get-PSKoanSetting
            $Result | Should -BeOfType [PSCustomObject]
            $Result.KoanLocation | Should -BeExactly "$HOME${/}PSKoans"
            $Result.Editor | Should -BeExactly 'code'
        }

        It 'calls Set-PSKoanSetting to set the default settings' {
            Should -Invoke 'Set-PSKoanSetting' -Scope Context -ModuleName 'PSKoans'
        }
    }

    Context 'Settings file does exist' {

        BeforeAll {
            [PSCustomObject]@{
                KoanLocation = "TestLocation"
                Editor       = "TestEditor"
            } |
                ConvertTo-Json |
                Set-Content -Path $configFilePath
        }

        It 'returns all settings if none are specified' {
            $Result = Get-PSKoanSetting
            $Result.KoanLocation | Should -BeExactly 'TestLocation'
            $Result.Editor | Should -BeExactly 'TestEditor'
        }

        It 'returns only the specified setting with -Name <Name>' -TestCases @(
            @{ Name = 'KoanLocation'; Expected = 'TestLocation' }
            @{ Name = 'Editor'; Expected = 'TestEditor' }
        ) {
            Get-PSKoanSetting -Name $Name | Should -BeExactly $Expected
        }
    }
}
