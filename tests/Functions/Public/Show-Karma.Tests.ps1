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

Describe 'Show-Karma' {

    BeforeAll {
        $koanLocation = "$TestDrive/Koans"
        Mock 'Get-PSKoanLocation' -ModuleName 'PSKoans' { $koanLocation }

        $script:EditorSetting = Get-PSKoanSetting -Name Editor

        Reset-PSKoan -Confirm:$false
    }

    AfterAll {
        Set-PSKoanSetting -Name Editor -Value $EditorSetting
    }

    Context 'Default Behaviour' {

        BeforeAll {
            Mock 'Out-Host' -ModuleName 'PSKoans'
            Mock 'Get-Karma' -ModuleName 'PSKoans' {
                [PSCustomObject]@{
                    PSTypeName   = 'PSKoans.Result'
                    Meditation   = 'TestMeditation'
                    KoansPassed  = 0
                    TotalKoans   = 400
                    Describe     = 'TestDescribe'
                    Expectation  = 'ExpectedTest'
                    It           = 'TestIt'
                    CurrentTopic = [PSCustomObject]@{
                        Name        = 'TestTopic"'
                        Completed   = 0
                        Total       = 4
                        CurrentLine = 1
                    }
                }
            }
        }

        It 'should not produce output' {
            Show-Karma | Should -BeNullOrEmpty
        }

        It 'should write the formatted output to host' {
            Should -Invoke 'Out-Host' -Scope Context -ModuleName 'PSKoans'
        }

        It 'should call Get-Karma to examine the koans' {
            Should -Invoke 'Get-Karma' -Scope Context -ModuleName 'PSKoans'
        }
    }

    Context 'With All Koans Completed' {

        BeforeAll {
            Mock 'Out-Host' -Verifiable -ModuleName 'PSKoans'
            Mock 'Get-Karma' -Verifiable -ModuleName 'PSKoans' {
                [PSCustomObject]@{
                    PSTypeName     = 'PSKoans.CompleteResult'
                    KoansPassed    = 10
                    TotalKoans     = 10
                    RequestedTopci = $null
                    Complete       = $true
                }
            }
        }

        It 'should not throw errors' {
            { Show-Karma } | Should -Not -Throw
            Should -InvokeVerifiable
        }
    }

    Context 'With -ClearScreen Switch' {

        BeforeAll {
            Mock 'Clear-Host' -ModuleName 'PSKoans'
            Mock 'Out-Host' -ModuleName 'PSKoans'
            Mock 'Get-Karma' -ModuleName 'PSKoans' {
                [PSCustomObject]@{
                    PSTypeName   = 'PSKoans.Result'
                    Meditation   = 'TestMeditation'
                    KoansPassed  = 0
                    TotalKoans   = 400
                    Describe     = 'TestDescribe'
                    Expectation  = 'ExpectedTest'
                    It           = 'TestIt'
                    CurrentTopic = [PSCustomObject]@{
                        Name        = 'TestTopic"'
                        Completed   = 0
                        Total       = 4
                        CurrentLine = 1
                    }
                }
            }
        }

        It 'should not produce output' {
            Show-Karma -ClearScreen | Should -Be $null
        }

        It 'should clear the screen' {
            Should -Invoke 'Clear-Host' -Scope Context -Times 1 -Exactly -ModuleName 'PSKoans'
        }

        It 'should display the rendered output' {
            Should -Invoke 'Out-Host' -Scope Context -ModuleName 'PSKoans'
        }

        It 'should use Get-Karma to retrieve koan results' {
            Should -Invoke 'Get-Karma' -Scope Context -Times 1 -Exactly -ModuleName 'PSKoans'
        }
    }

    Context 'With Nonexistent Koans Folder / No Koans Found' {

        BeforeAll {
            Mock 'Write-Host' -ModuleName 'PSKoans'
            Mock 'Get-PSKoan' -ModuleName 'PSKoans'
            Mock 'Update-PSKoan' { throw 'Prevent recursion' } -ModuleName 'PSKoans'
            Mock 'Write-Warning' -ModuleName 'PSKoans'
            Mock 'Test-Path' { $false } -ModuleName 'PSKoans'
            Mock 'Invoke-Item' -ModuleName 'PSKoans'
            Mock 'Measure-Koan' -ModuleName 'PSKoans'
        }

        BeforeEach {
            InModuleScope 'PSKoans' { $script:CurrentTopic = $null }
        }

        It 'should attempt to populate koans and then recurse to reassess' {
            { Show-Karma } | Should -Throw -ExpectedMessage 'Prevent recursion'
        }

        It 'should display a warning before initiating a reset' {
            Should -Invoke 'Write-Warning' -Scope Context -Times 1 -Exactly -ModuleName 'PSKoans'
        }

        It 'throws an error if a Topic is specified that matches nothing' {
            { Show-Karma -Topic 'AboutAbsolutelyNothing' } | Should -Throw -ErrorId 'PSKoans.TopicNotFound,Show-Karma'
        }

        It 'should create PSKoans directory with -Library' {
            { Show-Karma -Library } | Should -Throw -ExpectedMessage 'Prevent recursion'

            Should -Invoke 'Test-Path' -ModuleName 'PSKoans'
            Should -Invoke 'Update-PSKoan' -Times 1 -Exactly -ModuleName 'PSKoans'
        }

        It 'should call Get-PSKoan to retrieve the correct file -Contemplate' {
            { Show-Karma -Contemplate } | Should -Throw -ExpectedMessage 'Prevent recursion'

            Should -Invoke 'Get-PSKoan' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Update-PSKoan' -Times 1 -Exactly -ModuleName 'PSKoans'
        }
    }

    Context 'With -ListTopics Parameter' {

        BeforeAll {
            Mock 'Get-PSKoan' -ModuleName 'PSKoans'
        }

        It 'should list all the koan topics' {
            Show-Karma -ListTopics
            Should -Invoke 'Get-PSKoan' -Times 1 -Exactly -ModuleName 'PSKoans'
        }
    }

    Context 'With -Topic Parameter' {

        BeforeAll {
            Mock 'Out-Host' -Verifiable -ModuleName 'PSKoans'
            Mock 'Get-Karma' -ParameterFilter { $Topic -eq 'TestTopic' } -Verifiable -ModuleName 'PSKoans' -MockWith {
                [PSCustomObject]@{
                    PSTypeName     = 'PSKoans.Result'
                    Meditation     = 'TestMeditation'
                    KoansPassed    = 0
                    TotalKoans     = 400
                    Describe       = 'TestDescribe'
                    Expectation    = 'ExpectedTest'
                    It             = 'TestIt'
                    CurrentTopic   = [PSCustomObject]@{
                        Name        = 'TestTopic"'
                        Completed   = 0
                        Total       = 4
                        CurrentLine = 1
                    }
                    RequestedTopic = $Topic
                }
            }
        }

        It 'should call Get-Karma on the selected topic' {
            Show-Karma -Topic TestTopic
            Should -InvokeVerifiable
        }
    }

    Context 'With All Koans in a Single Topic Completed' {

        BeforeAll {
            Mock 'Format-Custom' -Verifiable -ModuleName 'PSKoans' { $null }
            Mock 'Out-Host' -Verifiable -ModuleName 'PSKoans'
            Mock 'Get-Karma' -Verifiable -ModuleName 'PSKoans' {
                [PSCustomObject]@{
                    PSTypeName     = 'PSKoans.CompleteResult'
                    KoansPassed    = 10
                    TotalKoans     = 10
                    RequestedTopic = 'TestTopic'
                    Complete       = $true
                }
            }
        }

        It 'should not throw errors' {
            { Show-Karma } | Should -Not -Throw
            Should -InvokeVerifiable
        }
    }

    Context 'With -Contemplate Switch' {

        BeforeAll {
            $TestFile = New-TemporaryFile

            Mock 'Invoke-Item' { $Path } -ModuleName 'PSKoans'
            Mock 'Get-Command' { $true } -ParameterFilter { $Name -ne "missing_editor" } -ModuleName 'PSKoans'
            Mock 'Get-Command' { $false } -ParameterFilter { $Name -eq "missing_editor" } -ModuleName 'PSKoans'
            Mock 'Start-Process' -ModuleName 'PSKoans' {
                @{ Editor = $FilePath; Arguments = $ArgumentList; NoNewWindow = $NoNewWindow }
            }

            Mock 'Get-Karma' -ModuleName 'PSKoans' {
                $currentTopic = @{
                    Name        = 'TestTopic'
                    Completed   = 0
                    Total       = 4
                    CurrentLine = 1
                }

                [PSCustomObject]@{
                    PSTypeName   = 'PSKoans.Result'
                    Meditation   = 'TestMeditation'
                    KoansPassed  = 0
                    TotalKoans   = 400
                    Describe     = 'TestDescribe'
                    Expectation  = 'ExpectedTest'
                    It           = 'TestIt'
                    CurrentTopic = [PSCustomObject]$currentTopic
                }

                InModuleScope 'PSKoans' -Parameters @{ Topic = $currentTopic } {
                    param($Topic)
                    $script:CurrentTopic = $Topic
                }
            }

            Mock 'Get-PSKoan' -ParameterFilter { $Scope -eq 'User' } -ModuleName 'PSKoans' {
                [PSCustomObject]@{ Path = $TestFile.FullName }
            }
        }

        AfterAll {
            $TestFile | Remove-Item
        }

        It 'invokes VS Code with "code" set as Editor with proper arguments' {
            Set-PSKoanSetting -Name Editor -Value 'code'
            $Result = Show-Karma -Contemplate

            $Result.Editor | Should -BeExactly 'code'
            $Result.Arguments[0] | Should -BeExactly '--goto'
            $Result.Arguments[1] | Should -MatchExactly '"[^"]+":\d+'
            $Result.Arguments[2] | Should -BeExactly '--reuse-window'
            $Result.NoNewWindow | Should -BeTrue

            # Resolve-Path doesn't like embedded quotes
            $Path = ($Result.Arguments[1] -split '(?<="):')[0] -replace '"'
            $Path | Should -BeExactly (Resolve-Path -Path $Path).Path

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Start-Process' -Times 1 -Exactly -ModuleName 'PSKoans'

            InModuleScope 'PSKoans' { $script:CurrentTopic } | Should -BeNullOrEmpty
        }


        $moduleCases = @(
            @{ ModuleName = 'ActiveDirectory' }
            @{ ModuleName = 'dbatools' }
        )
        It 'opens the selected editor targeting koans for the <ModuleName> module' -TestCases $moduleCases {
            Set-PSKoanSetting -Name Editor -Value 'code'
            $Result = Show-Karma -Contemplate -Module $ModuleName

            $Result.Editor | Should -BeExactly 'code'
            $Result.Arguments[0] | Should -BeExactly '--goto'
            $Result.Arguments[1] | Should -MatchExactly '"[^"]+":\d+'
            $Result.Arguments[2] | Should -BeExactly '--reuse-window'
            $Result.NoNewWindow | Should -BeTrue

            # Resolve-Path doesn't like embedded quotes
            $Path = ($Result.Arguments[1] -split '(?<="):')[0] -replace '"'
            $Path | Should -BeExactly (Resolve-Path -Path $Path).Path

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Start-Process' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Get-Karma' -ParameterFilter { $Module -eq $ModuleName } -ModuleName 'PSKoans'
            Should -Invoke 'Get-PSKoan' -ParameterFilter { $IncludeModule -eq $ModuleName } -ModuleName 'PSKoans'

            InModuleScope 'PSKoans' { $script:CurrentTopic } | Should -BeNullOrEmpty
        }

        It 'opens the specified -Topic in the selected editor' {
            Set-PSKoanSetting -Name Editor -Value 'code'

            $Result = Show-Karma -Contemplate -Topic TestTopic
            $Result.Arguments[1] | Should -MatchExactly ([regex]::Escape($TestFile.FullName))

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Start-Process' -Times 1 -Exactly -ModuleName 'PSKoans'

            InModuleScope 'PSKoans' { $script:CurrentTopic } | Should -BeNullOrEmpty
        }

        It 'invokes the set editor with unknown editor chosen' {
            Set-PSKoanSetting -Name Editor -Value 'vim'

            $Result = Show-Karma -Contemplate
            $Result.Editor | Should -BeExactly 'vim'
            $Result.Arguments | Should -MatchExactly '"[^"]+"'

            # Resolve-Path doesn't like embedded quotes
            $Path = $Result.Arguments -replace '"'
            $Path | Should -BeExactly (Resolve-Path -Path $Path).Path

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Start-Process' -Times 1 -Exactly -ModuleName 'PSKoans'

            InModuleScope 'PSKoans' { $script:CurrentTopic } | Should -BeNullOrEmpty
        }

        It 'opens the file directly when selected editor is unavailable' {
            Set-PSKoanSetting -name Editor -Value "missing_editor"

            Show-Karma -Contemplate | Should -BeExactly $TestFile.FullName

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ParameterFilter { $Name -eq "missing_editor" } -ModuleName 'PSKoans'
            Should -Invoke 'Invoke-Item' -Times 1 -Exactly -ModuleName 'PSKoans'

            InModuleScope 'PSKoans' { $script:CurrentTopic } | Should -BeNullOrEmpty
        }
    }

    Context 'With -Library Switch' {

        BeforeAll {
            Mock 'Get-Command' { $true } -ParameterFilter { $Name -ne "missing_editor" } -ModuleName 'PSKoans'
            Mock 'Get-Command' { $false } -ParameterFilter { $Name -eq "missing_editor" } -ModuleName 'PSKoans'
            Mock 'Start-Process' -ModuleName 'PSKoans' {
                @{ Editor = $FilePath; Arguments = $ArgumentList }
            }
            Mock 'Invoke-Item' { $Path } -ModuleName 'PSKoans'
        }

        It 'invokes VS Code with "code" set as Editor with proper arguments' {
            Set-PSKoanSetting -Name Editor -Value 'code'

            $Result = Show-Karma -Library
            $Result.Editor | Should -BeExactly 'code'

            # Resolve-Path doesn't like embedded quotes
            $Path = $Result.Arguments -replace '"'
            $Path | Should -BeExactly (Resolve-Path -Path $Path).Path

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Start-Process' -Times 1 -Exactly -ModuleName 'PSKoans'
        }

        It 'invokes the set editor with unknown editor chosen' {
            Set-PSKoanSetting -Name Editor -Value 'vim'

            $Result = Show-Karma -Library
            $Result.Editor | Should -BeExactly 'vim'

            # Resolve-Path doesn't like embedded quotes
            $Path = $Result.Arguments -replace '"'
            $Path | Should -BeExactly (Resolve-Path -Path $Path).Path

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ModuleName 'PSKoans'
            Should -Invoke 'Start-Process' -Times 1 -Exactly -ModuleName 'PSKoans'
        }

        It 'opens the file directly when selected editor is unavailable' {
            Set-PSKoanSetting -name Editor -Value "missing_editor"

            Show-Karma -Library | Should -BeExactly $koanLocation

            Should -Invoke 'Get-Command' -Times 1 -Exactly -ParameterFilter { $Name -eq "missing_editor" } -ModuleName 'PSKoans'
            Should -Invoke 'Invoke-Item' -Times 1 -Exactly -ModuleName 'PSKoans'
        }
    }
}
