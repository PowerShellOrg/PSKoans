function New-KoanRunspace {
    <#
    .SYNOPSIS
    Creates a new runspace, with PSKoans and Pester already imported, and PSModulePath already set.

    .DESCRIPTION
    Creates a new runspace for reuse with Invoke-Koan. The new runspace will be pre-populated with a fresh copy of
    Pester and PSKoans imported, and with a copy of the current session state's PSModulePath, which will have the
    current PSKoans parent folder in it, such that `using module` statements will find the current PSKoans module
    first, avoiding issues with debug environments which may find older PSKoans modules installed instead of using the
    current debug version.

    .EXAMPLE
    $script:KoanRunspace = New-KoanRunspace

    .NOTES
    Run scripts in a new scope to avoid scope bleed wherever possible, with the `$ps.AddScript($script, $true) overload.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Constructs and returns an in-memory Runspace object; no external state is mutated.'
    )]
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Runspaces.Runspace])]
    param()

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $runspace.Name = 'PSKoans.KoanRunspace'
    $ps = [powershell]::Create()
    $ps.Runspace = $runspace

    try {
        $script = {
            param( $PSKoansPath )

            Get-Module $PSKoansPath -ListAvailable | Import-Module
        }

        $ps.AddScript($script) > $null
        $ps.AddParameter('PSKoansPath', $MyInvocation.MyCommand.Module.ModuleBase) > $null
        $ps.Invoke() > $null

        $runspace
    }
    finally {
        $ps.Dispose()
    }
}
