function Set-PSKoanSetting {
    <#
    .SYNOPSIS
        Modifies the configuration settings for PSKoans.

    .DESCRIPTION
        Sets module configuration data in a JSON file in the user's $HOME directory.

    .PARAMETER Name
        Specifies which setting value to modify.

    .PARAMETER Reset
        Resets the user's settings to the default values.

    .PARAMETER Settings
        A hashtable containing one or more settings to modify and their values.

    .PARAMETER Value
        Provides a value to apply to the target setting.

    .EXAMPLE
        Set-PSKoanSetting -Name LibraryFolder -Value "./PSKoans"

        Sets the library folder location to the `PSKoans` folder in the current directory.

    .EXAMPLE
        Set-PSKoanSetting -Name Editor -Value "atom"

        Sets the text editor used for `Show-Karma -Contemplate` to GitHub Atom. For a
        list of text editors known to PSKoans, see Example 2 in the documentation for
        [Show-Karma -Contemplate](https://github.com/vexx32/PSKoans/tree/main/docs/Show-Karma.md).

    .NOTES
        Author: Joel Sallow (@vexx32)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoanSetting.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter',
        'Value',
        Justification = 'Referenced inside a nested Select-Object calculated-property scriptblock, which PSScriptAnalyzer does not trace back to the enclosing param.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter',
        'Reset',
        Justification = 'Used only to select the Reset parameter set; dispatch reads $PSCmdlet.ParameterSetName, not the switch value.'
    )]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Single',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Set-PSKoanSetting.md')]
    [OutputType([void])]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Single')]
        [string]
        $Name,

        [Parameter(Position = 1, Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Single')]
        [object]
        $Value,

        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = 'Multiple')]
        [hashtable]
        $Settings,

        [Parameter(ParameterSetName = 'Reset')]
        [switch]
        $Reset
    )

    process {
        if ($PSCmdlet.ShouldProcess($script:ConfigPath, "Update configuration file")) {
            $CurrentSettings = if (Test-Path $script:ConfigPath) {
                Get-Content -Path $script:ConfigPath | ConvertFrom-Json
            }
            else {
                $ConfigRoot = $script:ConfigPath | Split-Path -Parent

                if (-not (Test-Path $ConfigRoot)) {
                    New-Item -ItemType Directory -Path $ConfigRoot > $null
                }

                [PSCustomObject]$script:DefaultSettings
            }

            $NewSettings = switch ($PSCmdlet.ParameterSetName) {
                'Single' {
                    $CurrentSettings |
                        Select-Object -Property *, @{ Name = $Name; Expression = { $Value } } -ExcludeProperty $Name
                }
                'Multiple' {
                    $Properties = @(
                        '*'
                        foreach ($key in $Settings.Keys) {
                            @{
                                Name       = $key
                                Expression = { $Settings[$key] }.GetNewClosure()
                            }
                        }
                    )
                    $CurrentSettings |
                        Select-Object -Property $Properties -ExcludeProperty $Settings.Keys.ForEach{ $_ }
                }
                'Reset' {
                    $CurrentSettings
                }
            }

            $NewSettings |
                ConvertTo-Json |
                Set-Content -Path $script:ConfigPath
        }
    }
}
