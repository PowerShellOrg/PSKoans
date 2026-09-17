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

        $configuration = New-PesterConfiguration
        $configuration.Output.Verbosity = 'None'
        $configuration.Run.SkipRun = $true
        $configuration.Run.PassThru = $true
        $configuration.Run.TestExtension = ".Koans.ps1"
    }
    process {
        $koanTopics = "[$($KoanInfo.Name -join '], [')]"
        Write-Verbose "Discovering koans in $koanTopics"
        $configuration.Run.Path = $KoanInfo.Path

        $Result = Invoke-Pester -Configuration $configuration

        Write-Debug "Found $($Result.TotalCount) koans in $koanTopics"
        $KoanCount += $Result.TotalCount
    }
    end {
        $env:PSModulePath = $oldModulePath
        Write-Verbose "Total Koans: $KoanCount"
        $KoanCount
    }
}
