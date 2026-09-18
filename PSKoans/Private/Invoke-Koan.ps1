function Invoke-Koan {
    <#
    .SYNOPSIS
        Safely invokes Pester on a koan file in a fresh scope where tests can be executed out of harm's way.

    .DESCRIPTION
        Creates a new instance of PowerShell to execute the Pester tests in. Requires a valid parameter-splat hashtable
        for Invoke-Pester.

    .PARAMETER ParameterSplat
        Defines the hashtable that will be splatted into Invoke-Pester in the new PowerShell instance.

    .EXAMPLE
        Invoke-Koan @{ Path = '.\AboutArrays.Koans.ps1'; PassThru = $true; Show = 'None' }

        Triggers Pester to assess the AboutArrays file in the current directory and pass back the complete tests object,
        hiding the standard test results display.
    #>

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Position = 0, Mandatory)]
        [Alias('Params')]
        [hashtable]
        $ParameterSplat
    )
    begin {
        if (-not $script:KoanRunspace) {
            $script:KoanRunspace = New-KoanRunspace
        }
    }
    end {
        try {
            $Requirements = [System.Management.Automation.Language.Parser]::ParseFile(
                $ParameterSplat.Path,
                [ref]$null,
                [ref]$null
            ).Ast.ScriptRequirements

            $Script = {
                param( $Params, $RequiredModules, $PSModulePath )

                $oldModulePath = $env:PSModulePath
                try {
                    $env:PSModulePath = @(
                        $PSKoansPath | Split-Path -Parent
                        $PSModulePath -split [System.IO.Path]::PathSeparator
                        $env:PSModulePath -split [System.IO.Path]::PathSeparator
                    ) -join [System.IO.Path]::PathSeparator

                    foreach ($module in $RequiredModules) {
                        Import-Module $module
                    }

                    . ([scriptblock]::Create('using module PSKoans'))
                    Invoke-Pester @Params
                }
                finally {
                    $env:PSModulePath = $oldModulePath
                }
            }

            $ps = [powershell]::Create()
            $ps.Runspace = $script:KoanRunspace
            $ps.AddScript($Script, <# useLocalScope: #> $true) > $null

            $ps.AddParameter('Params', $ParameterSplat) > $null
            $ps.AddParameter('PSModulePath', $env:PSModulePath) > $null

            if ($Requirements.RequiredModules) {
                $ps.AddParameter('RequiredModules', $Requirements.RequiredModules)
            }

            $Status = $ps.BeginInvoke()

            do { Start-Sleep -Milliseconds 100 } until ($Status.IsCompleted)

            $Result = $ps.EndInvoke($Status)

            if ($ps.HadErrors) {
                # These will be errors outside the test itself; better propagate them upwards.
                foreach ($errorItem in $ps.Streams.Error) {
                    $PSCmdlet.WriteError($errorItem)
                }
            }

            $Result
        }
        finally {
            $ps.Dispose()
        }
    }
}
