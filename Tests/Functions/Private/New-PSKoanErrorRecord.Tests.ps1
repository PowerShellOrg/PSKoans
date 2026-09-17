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

Describe 'New-PSKoanErrorRecord' {

    Context 'With Exception Object' {

        BeforeAll {
            $Output, $Parameters = InModuleScope 'PSKoans' {
                $Params = @{
                    Exception     = [Exception]::new('Test message')
                    ErrorId       = 'Test.ErrorId'
                    ErrorCategory = 'NotSpecified'
                    TargetObject  = $null
                }
                New-PSKoanErrorRecord @Params
                $Params
            }
        }

        It 'creates an ErrorRecord object' {
            $Output | Should -BeOfType System.Management.Automation.ErrorRecord
        }

        It 'emits the same type of exception' {
            $Output.Exception | Should -BeOfType $Parameters.Exception.GetType().FullName
        }

        It 'includes the input exception message' {
            $Output.Exception.Message | Should -BeExactly $Parameters.Exception.Message
        }

        It 'emits the correct error ID with "PSKoans" prefix' {
            $Output.FullyQualifiedErrorId | Should -BeExactly "PSKoans.$($Parameters.ErrorId)"
        }

        It 'assigns the requested error category' {
            $Output.CategoryInfo.Category | Should -Be $Parameters.ErrorCategory
        }

        It 'assigns the target object' {
            $Output.TargetObject | Should -Be $Params.TargetObject
        }
    }

    Context 'With TypeName and Message' {

        BeforeAll {
            $Output, $Parameters = InModuleScope 'PSKoans' {
                $Params = @{
                    ExceptionType    = 'Exception'
                    ExceptionMessage = 'Test message'
                    ErrorId          = 'Test.OtherErrorId'
                    ErrorCategory    = 'NotSpecified'
                    TargetObject     = $null
                }
                New-PSKoanErrorRecord @Params
                $Params
            }
        }

        It 'creates an ErrorRecord object' {
            $Output | Should -BeOfType System.Management.Automation.ErrorRecord
        }

        It 'creates the correct type of exception' {
            $Output.Exception | Should -BeOfType $Parameters.ExceptionType
        }

        It 'applies the requested exception message' {
            $Output.Exception.Message | Should -BeExactly $Parameters.ExceptionMessage
        }

        It 'emits the correct error ID with "PSKoans" prefix' {
            $Output.FullyQualifiedErrorId | Should -BeExactly "PSKoans.$($Parameters.ErrorId)"
        }

        It 'assigns the requested error category' {
            $Output.CategoryInfo.Category | Should -Be $Parameters.ErrorCategory
        }

        It 'assigns the target object' {
            $Output.TargetObject | Should -Be $Params.TargetObject
        }
    }
}
