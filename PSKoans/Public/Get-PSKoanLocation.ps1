function Get-PSKoanLocation {
    <#
    .SYNOPSIS
        Gets the folder location where the current user's copy of the PSKoans lessons are stored.

    .DESCRIPTION
        Gets the current value of the PSKoans working library path.
        This value defaults to `$HOME\PSKoans` but can be changed as you prefer.

    .EXAMPLE
        Get-PSKoanLocation

        C:\Users\Timmy\PSKoans

        Displays the path to the current user's koan library location.

    .NOTES
        Author: Joel Sallow (@vexx32)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoanLocation.md')]
    [OutputType([string])]
    param()
    process {
        $Location = Get-PSKoanSetting -Name KoanLocation
        if ($Location) {
            $Location
        }
        else {
            $ErrorDetails = @{
                Exception     = [System.IO.DirectoryNotFoundException]::new(
                    'PSKoans folder location has not been defined'
                )
                ErrorId       = 'PSKoans.LibraryFolderNotDefined'
                ErrorCategory = 'NotSpecified'
                TargetObject  = $MyInvocation.MyCommand.Name
            }
            $PSCmdlet.ThrowTerminatingError( (New-PSKoanErrorRecord @ErrorDetails) )
        }
    }
}
