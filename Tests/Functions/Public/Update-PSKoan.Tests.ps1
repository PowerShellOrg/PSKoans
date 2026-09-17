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

Describe 'Update-PSKoan' {

    Context 'Mocked Commands' {

        BeforeAll {
            Mock 'Remove-Item' -ModuleName 'PSKoans'
            Mock 'Copy-Item' -ModuleName 'PSKoans'
            Mock 'New-Item' -ModuleName 'PSKoans'
            Mock 'Move-Item' -ModuleName 'PSKoans'
            Mock 'Update-PSKoanFile' -ModuleName 'PSKoans'

            Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'Module' } -ModuleName 'PSKoans' -MockWith {
                [PSCustomObject]@{
                    Topic = 'Missing'
                    Path  = 'Module\Group\AboutSomethingMissing.Koans.ps1'
                }
                [PSCustomObject]@{
                    Topic = 'IncorrectPath'
                    Path  = 'Module\Group\AboutSomethingIncorrectPath.Koans.ps1'
                }
                [PSCustomObject]@{
                    Topic = 'Existing'
                    Path  = 'Module\Group\AboutSomethingExisting.Koans.ps1'
                }
            }

            Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'User' } -ModuleName 'PSKoans' -MockWith {
                [PSCustomObject]@{
                    Topic = 'IncorrectPath'
                    Path  = 'Module\RetiredGroup\AboutSomethingIncorrectPath.Koans.ps1'
                }
                [PSCustomObject]@{
                    Topic = 'RetiredTopic'
                    Path  = 'Module\RetiredGroup\AboutSomethingRetiredTopic.Koans.ps1'
                }
                [PSCustomObject]@{
                    Topic = 'Existing'
                    Path  = 'Module\Group\AboutSomethingExisting.Koans.ps1'
                }
            }
        }

        It 'should not produce output' {
            Update-PSKoan -Confirm:$false | Should -BeNullOrEmpty
        }

        It 'should copy missing topic files' {
            Should -Invoke 'Copy-Item' -Times 1 -Scope Context -ModuleName 'PSKoans'
        }

        It 'should move incorrectly placed topics' {
            Should -Invoke 'Remove-Item' -Times 1 -Scope Context -ModuleName 'PSKoans'
        }

        It 'should remove discarded topics' {
            Should -Invoke 'Remove-Item' -Times 1 -Scope Context -ModuleName 'PSKoans'
        }

        It 'should update topics which exist in module and koan path' {
            Should -Invoke 'Update-PSKoanFile' -ModuleName 'PSKoans' -Times 2 -Scope Context
        }
    }

    Context 'Practical Tests with TestDrive' {

        BeforeAll {
            $koanLocation = Join-Path -Path $TestDrive -ChildPath 'PSKoans'
            Mock 'Get-PSKoanLocation' -ModuleName 'PSKoans' { $koanLocation }

            New-Item -Path $koanLocation -ItemType Directory
            Update-PSKoan -Confirm:$false

            $file = Get-ChildItem -Path $koanLocation -Filter *.koans.ps1 -File -Recurse |
                Select-Object -First 1
        }

        It 'should copy missing topic files' {
            $file | Remove-Item
            $file.FullName | Should -Not -Exist

            Update-PSKoan -Confirm:$false

            $file.FullName | Should -Exist
        }

        It 'should move incorrectly placed topics' {
            $directory = New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'PSKoans\Wrong') -ItemType Directory
            $file | Move-Item -Destination $directory.FullName
            $file.FullName | Should -Not -Exist

            Update-PSKoan -Confirm:$false

            $file.FullName | Should -Exist
        }

        It 'should remove discarded topics' {
            $oldTopicPath = Join-Path $TestDrive 'PSKoans\Foundations\OldTopic.koans.ps1'
            $file | Copy-Item -Destination $oldTopicPath
            $oldTopicPath | Should -Exist

            Update-PSKoan -Confirm:$false

            $oldTopicPath | Should -Not -Exist
        }
    }
}
