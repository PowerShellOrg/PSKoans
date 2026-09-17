function Show-Advice {
    <#
    .SYNOPSIS
        Prints a piece of advice to the screen.

    .DESCRIPTION
        Prints a piece of advice to the screen.
        Advice snippets are stored in a small library file in the module folder.

    .PARAMETER Name
        The title or name of the specific advice snippet to display.

    .EXAMPLE
        Get-Advice

        Print a random piece of advice to the screen.

    .NOTES
        Author: Friedrich Weinmann (@FriedrichWeinmann)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Register-Advice.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Show-Advice.md')]
    [Alias('Get-Advice')]
    [OutputType([void])]
    param(
        [Parameter(Position = 0)]
        [string]
        $Name = "*"
    )
    begin {
        $AdviceFolder = $script:ModuleRoot | Join-Path -ChildPath 'Data/Advice'
    }
    process {
        $AdviceObject = Get-ChildItem -Path $AdviceFolder -Recurse -File -Filter "$Name.Advice.json" |
        Get-Random |
        Get-Content |
        ConvertFrom-Json

        # Checking for errors
        if (-not $AdviceObject) {
            $ErrorDetails = @{
                ExceptionType    = 'System.IO.FileNotFoundException'
                ExceptionMessage = 'Could not find any Advice files matching the specified Name: {0}.' -f $Name
                ErrorId          = 'PSKoans.NoMatchingAdviceFound'
                ErrorCategory    = 'ObjectNotFound'
                TargetObject     = $Name
            }
            $PSCmdlet.ThrowTerminatingError( (New-PSKoanErrorRecord @ErrorDetails) )
        }
        elseif (-not ($AdviceObject.Title -and $AdviceObject.Content)) {
            $ErrorDetails = @{
                ExceptionType    = 'System.IO.FileLoadException'
                ExceptionMessage = 'Could not find Title and/or Content elements for Advice file: {0}' -f $Name
                ErrorId          = 'PSKoans.IncorrectAdviceData'
                ErrorCategory    = 'InvalidData'
                TargetObject     = $Name
            }
            $PSCmdlet.ThrowTerminatingError( (New-PSKoanErrorRecord @ErrorDetails) )
        }

        $AdviceObject.Title | Write-ConsoleLine -Title
        $AdviceObject.Content | Write-ConsoleLine
    }
    end {
    }
}
