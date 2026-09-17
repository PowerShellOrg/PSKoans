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

$ModuleName = 'PSKoans'

Describe "$ModuleName Sanity Tests - Help Content" -Tags 'Module' {

    #region Discovery


    $ShouldProcessParameters = 'WhatIf', 'Confirm'

    # Generate command list for generating Context / TestCases
    $Module = Get-Module $ModuleName
    $CommandList = @(
        $Module.ExportedFunctions.Keys
        $Module.ExportedCmdlets.Keys
    )

    #endregion Discovery

    foreach ($Command in $CommandList) {
        Context "$Command - Help Content" {

            #region Discovery

            $Help = @{ Help = Get-Help -Name $Command -Full | Select-Object -Property * }
            $Parameters = Get-Help -Name $Command -Parameter * -ErrorAction Ignore |
                Where-Object { $_.Name -and $_.Name -notin $ShouldProcessParameters } |
                ForEach-Object {
                    @{
                        Name        = $_.name
                        Description = $_.Description.Text
                    }
                }
            $Ast = @{
                # Ast will be $null if the command is a compiled cmdlet
                Ast        = (Get-Content -Path "function:/$Command" -ErrorAction Ignore).Ast
                Parameters = $Parameters
            }
            $Examples = $Help.Help.Examples.Example | ForEach-Object { @{ Example = $_ } }

            #endregion Discovery

            It "has help content for $Command" -TestCases $Help {
                $Help | Should -Not -BeNullOrEmpty
            }

            It "contains a synopsis for $Command" -TestCases $Help {
                $Help.Synopsis | Should -Not -BeNullOrEmpty
            }

            It "contains a description for $Command" -TestCases $Help {
                $Help.Description | Should -Not -BeNullOrEmpty
            }

            It "lists the function author in the Notes section for $Command" -TestCases $Help {
                $Notes = $Help.AlertSet.Alert.Text -split '\n'
                $Notes[0].Trim() | Should -BeLike "Author: *"
            }

            # This will be skipped for compiled commands ($Ast.Ast will be $null)
            It "has a help entry for all parameters of $Command" -TestCases $Ast -Skip:(-not ($Parameters -and $Ast.Ast)) {
                @($Parameters).Count | Should -Be $Ast.Body.ParamBlock.Parameters.Count -Because 'the number of parameters in the help should match the number in the function script'
            }

            if ($Parameters) {
                It "has a description for $Command parameter -<Name>" -TestCases $Parameters {
                    $Description | Should -Not -BeNullOrEmpty -Because "parameter $Name should have a description"
                }
            }

            It "has at least one usage example for $Command" -TestCases $Help {
                $Help.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
            }

            if ($Examples) {
                It "lists a description for $Command example: <Title>" -TestCases $Examples {
                    $Example.Remarks | Should -Not -BeNullOrEmpty -Because "example $($Example.Title) should have a description!"
                }
            }
        }
    }
}
