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

#region Discovery
$SkipTests = $PSVersionTable.PSEdition -ne 'Desktop' -or $PSVersionTable.Platform -ne 'Win32NT'
#endregion Discovery

Describe 'Assert-UnblockedFile' -Skip:$SkipTests {

    BeforeAll {
        $defaultParams = @{
            FileInfo = [System.IO.FileInfo](Join-Path -Path $TestDrive -ChildPath 'AboutSomething.Koans.ps1')
            PassThru = $true
        }
    }

    BeforeEach {
        Set-Content -Path $defaultParams.FileInfo.FullName -Value @'
            using module PSKoans
            [Koan(Position = 1)]
            param()

            Describe 'About something' {

                It 'Has examples' {
                    $true | Should -BeTrue
                }
            }
'@
    }

    AfterEach {
        Remove-Item -Path $defaultParams.FileInfo.FullName
    }

    Context 'File With External Zone Identifier' {

        BeforeEach {
            Set-Content -Path $defaultParams.FileInfo.FullName -Stream Zone.Identifier -Value @'
                [ZoneTransfer]
                ZoneId=3
                ReferrerUrl=C:\Downloads\File.zip
'@
        }

        It 'should throw a terminating error if the file is blocked' {
            {
                InModuleScope 'PSKoans' -Parameters @{ Params = $defaultParams } {
                    param($Params)
                    Assert-UnblockedFile @Params
                }
            } | Should -Throw -ErrorId 'PSKoans.KoanFileIsBlocked'
        }
    }

    Context 'File Without Zone Identifier' {

        It 'returns the original object with -PassThru if the file is not blocked' {
            InModuleScope 'PSKoans' -Parameters @{ Params = $defaultParams } {
                param($Params)
                Assert-UnblockedFile @Params
            } | Should -BeOfType [System.IO.FileInfo]
        }
    }
}
