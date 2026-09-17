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

Describe 'Invoke-Koan' {

    BeforeAll {
        $testFile = @{ Script = "$PSScriptRoot/ControlTests/Invoke-Koan.Control_Tests.ps1" }
    }

    It 'runs the test successfully' {
        {
            InModuleScope 'PSKoans' -Parameters $testFile {
                param($Script)
                Invoke-Koan @{ Script = $Script }
            }
        } | Should -Not -Throw
    }

    It 'produces output with -Passthru' {
        InModuleScope 'PSKoans' -Parameters $testFile {
            param($Script)
            Invoke-Koan @{ Script = $Script; PassThru = $true }
        } | Should -Not -BeNullOrEmpty
    }

    It 'correctly reports test results' {
        $Results = InModuleScope 'PSKoans' -Parameters $testFile {
            param($Script)
            Invoke-Koan @{ Script = $Script; PassThru = $true }
        }

        $Results.TotalCount | Should -Be 2
        $Results.PassedCount | Should -Be 0
        $Results.FailedCount | Should -Be 2
    }

    It 'reports only expected exception types' {
        $Results = InModuleScope 'PSKoans' -Parameters $testFile {
            param($Script)
            Invoke-Koan @{ Script = $Script; PassThru = $true }
        }

        $Results.Tests.ErrorRecord.Exception |
            ForEach-Object -MemberName GetType |
            Should -Be @([Exception], [NotImplementedException])
    }
}
