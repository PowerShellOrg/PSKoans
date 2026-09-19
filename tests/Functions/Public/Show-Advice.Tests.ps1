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

Describe "Show-Advice" {

    BeforeAll {
        Mock 'Write-ConsoleLine' -ModuleName 'PSKoans'
    }

    Context "Behaviour of Parameter-less Calls" {

        BeforeAll {
            $script:result = Show-Advice
        }

        It "calls Write-ConsoleLine with Parameter -Title" {
            Should -Invoke 'Write-ConsoleLine' -ModuleName 'PSKoans' -ParameterFilter { $null -eq $Title } -Scope Context
        }

        It "calls Write-ConsoleLine with only the display string" {
            Should -Invoke 'Write-ConsoleLine' -ModuleName 'PSKoans' -ParameterFilter { $null -ne $Title } -Scope Context
        }

        It "outputs nothing to the pipeline" {
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Behaviour with -Name Parameter" {

        BeforeAll {
            Show-Advice -Name "Profile"
        }

        It "should call Write-ConsoleLine with normal parameters" {
            Should -Invoke 'Write-ConsoleLine' -ParameterFilter { $null -ne $Title } -ModuleName 'PSKoans' -Scope Context
        }

        It "should call Write-ConsoleLine without parameters" {
            Should -Invoke 'Write-ConsoleLine' -ParameterFilter { $null -eq $Title } -ModuleName 'PSKoans' -Scope Context
        }

        It "should throw an error if the requested file cannot be found" {
            $message = "Could not find any Advice files matching the specified Name: ThisDoesntExist."
            { Show-Advice -name "ThisDoesntExist" -ErrorAction Stop } | Should -Throw -ExpectedMessage $Message
        }
    }

    Context 'Behaviour with malformed advice files' {

        BeforeAll {
            $script:GetContentResult = [string]::Empty

            Mock Get-Content -MockWith { $script:GetContentResult } -Verifiable -ModuleName 'PSKoans'
            Mock Get-ChildItem -MockWith { [PSCustomObject]@{ PSPath = "DummyPath" } } -Verifiable -ModuleName 'PSKoans'
        }

        It "should throw an error if the requested file's format is not correct" -TestCases @(
            @{
                Json = @{
                    NotTitle   = "Fake title"
                    NotContent = @(1..4 | ForEach-Object { "Fake line $_" })
                } | ConvertTo-Json
            }
            @{
                Json = @{
                    Content = @(1..4 | ForEach-Object { "Fake line $_" })
                } | ConvertTo-Json
            }
            @{
                Json = @{
                    Title = "Fake title"
                } | ConvertTo-Json
            }
        ) {
            $script:GetContentResult = $Json
            $AdviceName = "TestAdvice"
            $Message = "Could not find Title and/or Content elements for Advice file: {0}" -f $AdviceName
            { Show-Advice -name $AdviceName -ErrorAction Stop } | Should -Throw -ExpectedMessage $Message
            Should -InvokeVerifiable
        }
    }
}
