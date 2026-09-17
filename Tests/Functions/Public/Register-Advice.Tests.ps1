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

Describe "Register-Advice" {

    Context "Profile Folder/File Missing" {

        BeforeAll {
            Mock New-Item -Verifiable -ModuleName 'PSKoans'
            Mock Test-Path { $false } -Verifiable -ModuleName 'PSKoans'
            Mock Set-Content -ParameterFilter { $Value -eq "Show-Advice" } -Verifiable -ModuleName 'PSKoans'
        }

        It 'should create the $profile if it does not exist' {
            Register-Advice
            Should -InvokeVerifiable
        }
    }

    Context "Profile Already Exists" {

        BeforeAll {
            Mock 'Test-Path' { $true } -Verifiable -ModuleName 'PSKoans'
            Mock 'Select-String' { $false } -Verifiable -ModuleName 'PSKoans'
            Mock 'Add-Content' -Verifiable -ModuleName 'PSKoans'
        }

        It "adds content to the profile if it already exists (Get|Set)-Advice" {
            Register-Advice
            Should -InvokeVerifiable
        }
    }

    Context "Parameter Validation" {

        BeforeAll {
            Mock Test-Path { $false } -ModuleName 'PSKoans'
            Mock New-Item -ModuleName 'PSKoans'
            Mock Select-String { $false } -ModuleName 'PSKoans'
            Mock Add-Content -ModuleName 'PSKoans'
            Mock Set-Content -ParameterFilter { $Value -eq "Show-Advice" } -ModuleName 'PSKoans'
        }

        It "throws if an invalid value is supplied for -TargetProfile" {
            { Register-Advice -TargetProfile "Invalidvalue" } | Should -Throw
        }

        It "works correctly with the <ProfilePath> profile" -TestCases @(
            @{ ProfilePath = 'AllUsersAllHosts' }
            @{ ProfilePath = 'AllUsersCurrentHost' }
            @{ ProfilePath = 'CurrentUserAllHosts' }
            @{ ProfilePath = 'CurrentUserCurrentHost' }
        ) {
            try {
                Register-Advice $ProfilePath | Should -BeNullOrEmpty
            }
            catch [UnauthorizedAccessException] {
                # Current user doesn't have access to the profile path. This can be normal for the 'AllUsers' paths.
                if ($ProfilePath -notmatch '^AllUsers') {
                    throw $_
                }
            }
        }
    }
}
