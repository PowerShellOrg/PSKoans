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

Describe 'Get-PSKoan' {

    BeforeAll {
        $koanLocation = Join-Path $TestDrive 'PSKoans'
        Mock 'Get-PSKoanLocation' -ModuleName 'PSKoans' { $koanLocation }

        Update-PSKoan -Confirm:$false

        # Stage test module
        $path = Join-Path -Path $koanLocation 'Modules\TestModule'
        New-Item -Path $path -ItemType Directory -Force
        Set-Content -Path (Join-Path -Path $path -ChildPath 'AboutSomething.Koans.ps1') -Value @'
            using module PSKoans
            [Koan(Position = 1, Module = 'TestModule')]
            param()

            Describe 'AboutSomething' {
                It 'first' {
                    $true | Should -BeTrue
                }
            }
'@
    }

    It 'retrieves all except module-specific koan files' {
        $Files = Get-ChildItem -Path $koanLocation -Filter *.Koans.ps1 -Recurse -File |
            Where-Object FullName -NotMatch 'PSKoans[\\/]Modules[\\/]'

        (Get-PSKoan).Topic.Count | Should -Be $Files.Count
    }

    It 'retrieves specific requested files with -Topic <Topic>' -TestCases @(
        @{ Topic = 'AboutArrays' }
        @{ Topic = 'AboutVariables' }
        @{ Topic = 'AboutTypeOperators' }
        @{ Topic = 'AboutLists' }
        @{ Topic = 'AboutVariables', 'AboutLists' }
    ) {
        (Get-PSKoan -Topic $Topic).Topic | Should -Be $Topic
    }

    It 'retrieves specific requested files with -Module <Module>' -TestCases @(
        @{ Topic = 'AboutSomething'; Module = 'TestModule' }
    ) {
        (Get-PSKoan -Module $Module -Scope User).Topic | Should -Be $Topic
    }

    It 'should throw a terminating error if a file is blocked' -Skip:($PSVersionTable.PSEdition -ne 'Desktop' -or $PSVersionTable.Platform -ne 'Win32NT') {
        $testFile = Get-ChildItem -Path $koanLocation -Filter AboutArrays.Koans.ps1 -Recurse -File |
            Select-Object -First 1

        Set-Content -Path $testFile.FullName -Stream Zone.Identifier -Value @'
                    [ZoneTransfer]
                    ZoneId=3
                    ReferrerUrl=C:\Downloads\File.zip
'@

        { Get-PSKoan -Topic AboutArrays -Scope User } | Should -Throw -ErrorId PSKoans.KoanFileIsBlocked
    }
}
