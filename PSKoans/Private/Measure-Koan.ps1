function Measure-Koan {
    <#
    .SYNOPSIS
        Counts the number of koans in the provided ExternalScriptInfo objects.
    .DESCRIPTION
        Traverses the AST of the script blocks taken from the Get-Command output of the koan
        files to find all of the 'It' blocks in order to count the total number of Pester
        tests present in the file.

        When provided with a piped list of KoanInfo objects, sums the entire
        collection's 'It' blocks and returns a single integer sum.
    .PARAMETER KoanInfo
        Takes an array of KoanInfo objects (as provided from Get-PSKoan).
    .EXAMPLE
        Get-Command .\KoanDirectory\*\*.ps1 | Measure-Koan

        422
    .NOTES
        Author: Joel Sallow
        Module: PSKoans
    .LINK
        https://github.com/vexx32/PSKoans
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments',
        'invokedViaInvokePester',
        Justification = 'Read by Pester internals via $ExecutionContext.SessionState.PSVariable.Get(''invokedViaInvokePester''), a dynamic-scope convention invisible to static analysis.'
    )]
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [PSTypeName('PSKoans.KoanInfo')]
        [psobject[]]
        $KoanInfo
    )
    begin {
        $KoanCount = 0
        $oldModulePath = $env:PSModulePath

        $env:PSModulePath = @(
            $MyInvocation.MyCommand.Module.ModuleBase
            $env:PSModulePath -split [System.IO.Path]::PathSeparator
        ) -join [System.IO.Path]::PathSeparator
    }
    process {
        Write-Verbose "Discovering koans in [$($KoanInfo.Name -join '], [')]"

        $Result = & (Get-Module Pester) {
            [CmdletBinding()]
            param(
                $Path,
                $ExcludePath,
                $SessionState
            )

            $_Pester_State_Backup = $state.PSObject.Copy()
            $state.Stack = [System.Collections.Stack]@()
            try {
                Reset-TestSuiteState

                # to avoid Describe thinking that we run in interactive mode
                $invokedViaInvokePester = $true

                $fileList = Find-File -Path $Path -ExcludePath $ExcludePath -Extension '.Koans.ps1'
                $containers = foreach ($file in $fileList) {
                    New-BlockContainerObject -File (Get-Item $file)
                }

                Find-Test -BlockContainer $containers -SessionState $SessionState
            }
            finally {
                $state = $_Pester_State_Backup
                Remove-Variable -Name _Pester_State_Backup
            }
        } -Path $KoanInfo.Path -SessionState $PSCmdlet.SessionState

        $KoanCount += Measure-KoanTestBlock $Result
    }
    end {
        Write-Verbose "Total Koans: $KoanCount"
        $KoanCount

        $env:PSModulePath = $oldModulePath
    }
}
