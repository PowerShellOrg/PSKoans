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

Describe 'Move-PSKoanLibrary' {

    Context 'Unit Tests with Mocks' {

        BeforeAll {
            $OriginalPath = New-Item -Path 'TestDrive:/PSKoans' -ItemType Directory |
                Select-Object -ExpandProperty FullName
            $TestPath = New-Item -ItemType Directory -Path 'TestDrive:/TestPath' | Join-Path -ChildPath 'Koans'

            Mock 'Get-PSKoanLocation' { $OriginalPath } -ModuleName 'PSKoans'
            Mock 'Set-PSKoanLocation' -ParameterFilter { $Path -eq $TestPath } -ModuleName 'PSKoans'
            Mock 'Move-Item' -ParameterFilter { $Path -eq $OriginalPath } -MockWith { $Destination } -ModuleName 'PSKoans'
        }

        It 'should output the new location' {
            Move-PSKoanLibrary -Path $TestPath | Should -BeExactly $TestPath
        }

        It 'should call Get-PSKoanLocation' {
            Should -Invoke 'Get-PSKoanLocation' -Scope Context -ModuleName 'PSKoans'
        }

        It 'should call Move-Item' {
            Should -Invoke 'Move-Item' -Scope Context -ModuleName 'PSKoans'
        }

        It 'should call Set-PSKoanLocation' {
            Should -Invoke 'Set-PSKoanLocation' -Scope Context -ModuleName 'PSKoans'
        }
    }

    Context 'Integration Tests' {

        BeforeAll {
            $OldLocation = Get-PSKoanLocation

            Set-PSKoanLocation -Path 'TestDrive:/PSKoans'
            Update-PSKoan -Confirm:$false

            $NewLocation = 'TestDrive:/NewLocation/PSKoans'
            New-Item -Path ($NewLocation | Split-Path -Parent) -ItemType Directory
        }

        AfterAll {
            Set-PSKoanLocation $OldLocation
        }

        It 'should move the folder to the new location' {
            Move-PSKoanLibrary -Path $NewLocation
            Test-Path $NewLocation -PathType Container | Should -BeTrue
        }

        It 'should update the KoanLocation' {
            Get-PSKoanLocation | Should -BeExactly (Get-Item -Path $NewLocation).FullName
        }

        It 'should copy all files intact to the new location' {
            $OriginalFileHashes = Get-PSKoanLocation |
                Get-ChildItem -Recurse -File |
                Get-FileHash |
                ForEach-Object {
                    @{
                        File = ($_.Path -split [regex]::Escape([IO.Path]::DirectorySeparatorChar))[-2, -1] -join ':'
                        Hash = $_.Hash
                    }
                }

            $finalLocation = 'TestDrive:/FinalLocation/PSKoans'
            New-Item -Path ($finalLocation | Split-Path -Parent) -ItemType Directory
            Move-PSKoanLibrary -Path $finalLocation

            $newFileHashes = @{}
            Get-ChildItem -Path $finalLocation -Recurse -File -PipelineVariable Item |
                Get-FileHash |
                ForEach-Object {
                    $newFileHashes[$Item.Name] = $_.Hash
                }

            foreach ($File in $OriginalFileHashes) {
                $FileName = ($File.File -split ':')[-1]
                $reason = "the hash of $($File.File) should match the new file hash"
                $newFileHashes[$FileName] | Should -BeExactly $File.Hash -Because $reason
            }
        }
    }

}
