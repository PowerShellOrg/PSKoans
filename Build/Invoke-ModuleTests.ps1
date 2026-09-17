$Lines = '-' * 70

Import-Module 'PSKoans'

$PesterVersion = (Get-Module -Name Pester).Version
$PSVersion = $PSVersionTable.PSVersion

Write-Host $Lines
Write-Host "TEST: PowerShell Version: $PSVersion"
Write-Host "TEST: Pester Version: $PesterVersion"
Write-Host $Lines

try {
    # Try/Finally required since this will exit with exit code on failure.
    $configuration = New-PesterConfiguration
    $configuration.CodeCoverage.Enabled = $true
    $configuration.TestResult.Enabled = $true
    $configuration.Run.Path = $env:PROJECTROOT
    $configuration.Output.Verbosity = 'Normal'
    
    Invoke-Pester -Configuration $Configuration
}
finally {
    $Timestamp = Get-Date -Format "yyyyMMdd-hhmmss"
    $TestFile = "PS${PSVersion}_${TimeStamp}_PSKoans.TestResults.xml"
    $CodeCoverageFile = "PS${PSVersion}_${TimeStamp}_PSKoans.CodeCoverage.xml"

    $ModuleFolders = @(
        Get-Item -Path "$env:PROJECTROOT/PSKoans"
        Get-ChildItem -Path "$env:PROJECTROOT/PSKoans" -Directory -Recurse |
            Where-Object FullName -NotMatch '[\\/]Tests[\\/]|[\\/]PSKoans[\\/]Koans[\\/]'
    ).FullName -join ';'
    
    $AzurePipelines = $env:BUILD_SOURCESDIRECTORY -and $env:BUILD_BUILDNUMBER
    $GithubActions = [bool]$env:GITHUB_WORKSPACE
    
    if ($AzurePipelines) {
        # Tell Azure what the test results & code coverage file names will be
        Write-Host "##vso[task.setvariable variable=TestResults]$TestFile"
        Write-Host "##vso[task.setvariable variable=CodeCoverageFile]$CodeCoverageFile"
        Write-Host "##vso[task.setvariable variable=SourceFolders]$ModuleFolders"
        
        # Move files generated from Invoke-Pester to expected location
        Move-Item -Path './testResults.xml' -Destination "$env:BUILD_ARTIFACTSTAGINGDIRECTORY/$TestFile"
        Move-Item -Path './coverage.xml' -Destination "$env:BUILD_ARTIFACTSTAGINGDIRECTORY/$CodeCoverageFile"
    }
    elseif ($GithubActions) {
        @(
            "TestResults=$TestFile"
            "CodeCoverageFile=$CodeCoverageFile"
            "SourceFolders=$ModuleFolders"
        ) | Add-Content -Path $env:GITHUB_ENV
        
        Move-Item -Path './testResults.xml' -Destination "$env:GITHUB_WORKSPACE/$TestFile"
        Move-Item -Path './coverage.xml' -Destination "$env:GITHUB_WORKSPACE/$CodeCoverageFile"        
    }
}
