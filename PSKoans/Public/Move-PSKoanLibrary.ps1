function Move-PSKoanLibrary {
    <#
    .SYNOPSIS
        Move your entire current PSKoans library folder to another location and update your KoanLocation setting to reflect the new location.

    .DESCRIPTION
        `Move-PSKoanLibrary` takes your current PSKoans library location and moves the folder to the specified destination.
        Then, it updates the current KoanLocation setting to point to the new location.

    .PARAMETER Path
        The path to the new library location.
        This path can be relative to the current session location, but cannot contain wildcards.

    .EXAMPLE
        Move-PSKoanLibrary -Path C:\Users\Joe\OneDrive

        Moves Joe's koan library into his OneDrive directory.

    .NOTES
        Author: Joel Sallow (@vexx32)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Set-PSKoanSetting.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoanSetting.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Move-PSKoanLibrary.md')]
    [OutputType([void])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [Alias('PSPath', 'Folder', 'Destination', 'TargetPath')]
        [string]
        $Path
    )
    process {
        if ($PSCmdlet.ShouldProcess($Path, 'Move existing koan files here')) {
            $OriginalPath = Get-PSKoanLocation

            Write-Verbose "Moving library files from '$OriginalPath' to '$Path'"
            Move-Item -Path $OriginalPath -Destination $Path -ErrorAction Stop -PassThru

            if ($?) {
                Set-PSKoanLocation -Path $Path
            }
        }
    }
}
