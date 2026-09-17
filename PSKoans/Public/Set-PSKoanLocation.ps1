function Set-PSKoanLocation {
    <#
    .SYNOPSIS
        Sets the PSKoans folder location where koan lesson files will be stored and retrieved.

    .DESCRIPTION
        Sets the `KoanLocation` configuration setting in order to modify where the module looks for and stores its koan lesson files.

    .PARAMETER PassThru
        Whether the function should pass the provided `-Path` value down the pipe when the configuration has been changed.

    .PARAMETER Path
        Specify the path to set the koan location to.

    .EXAMPLE
        Set-PSKoanLocation -Path C:\PSKoans

        Measure-Karma

        Sets the koan folder location to 'C:\PSKoans' and then invokes Measure-Karma to examine that location for koan files.

    .NOTES
        Author: Joel Sallow (@vexx32)

        The PSKoans folder specified will become the location to look for koans files.
        If this location is empty or nonexistent, it will be created and populated with a pristine copy of the koans library when Measure-Karma is run next.

        You can optionally populate it yourself by running `Show-Karma -Reset` following use of this cmdlet.

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoanLocation.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Move-PSKoanLibrary.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Set-PSKoanLocation.md')]
    [OutputType([void])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [Alias('PSPath', 'Folder')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $PassThru
    )
    begin {
        $resolvedPath = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

        if ($resolvedPath.Count -gt 1 -or [WildcardPattern]::ContainsWildcardCharacters($resolvedPath)) {
            $ErrorDetails = @{
                ExceptionType    = [System.Management.Automation.PSArgumentException]
                ExceptionMessage = 'Wildcarded paths are not supported.'
                ErrorId          = 'InvalidPath'
                ErrorCategory    = 'InvalidArgument'
                TargetObject     = $Path
            }
            $PSCmdlet.ThrowTerminatingError((New-PSKoanErrorRecord @ErrorDetails))
        }

        if (Test-Path $resolvedPath -PathType Leaf) {
            $ErrorDetails = @{
                ExceptionType    = [System.Management.Automation.PSArgumentException]
                ExceptionMessage = 'You cannot use a file path as the location for your PSKoans library.'
                ErrorId          = 'InvalidPathType'
                ErrorCategory    = 'InvalidArgument'
                TargetObject     = $Path
            }
            $PSCmdlet.ThrowTerminatingError((New-PSKoanErrorRecord @ErrorDetails))
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess("Set PSKoans folder location to '$resolvedPath'")) {
            Set-PSKoanSetting -Name KoanLocation -Value $resolvedPath
        }
        else {
            Write-Warning "PSKoans folder location has not been changed."
        }

        if ($PassThru) {
            $resolvedPath
        }
    }
}
