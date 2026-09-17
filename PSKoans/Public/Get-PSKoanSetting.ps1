function Get-PSKoanSetting {
    <#
    .SYNOPSIS
        Retrieves the configuration settings for PSKoans.

    .DESCRIPTION
        Retrieves configuration data from the locally stored json file in `$HOME/.config/PSKoans`.

    .PARAMETER Name
        Specifies which setting value to retrieve.

    .EXAMPLE
        Get-PSKoanSetting

        Retrieves all module settings.

    .EXAMPLE
        Get-PSKoanSetting -Name LibraryFolder

        Retrieves the library folder location (also retrievable with `Get-PSKoanLocation`).

    .EXAMPLE
        Get-PSKoanSetting -Name Editor

        Retrieves the text editor that PSKoans will use for `Show-Karma -Contemplate`.

    .NOTES
        Author: Joel Sallow (@vexx32)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Set-PSKoanSetting.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoanSetting.md')]
    [OutputType([string], [PSCustomObject])]
    param(
        [Parameter()]
        [string]
        $Name
    )

    $Configuration = if (-not (Test-Path $script:ConfigPath)) {
        # No settings file present, create file with default settings
        Set-PSKoanSetting -Settings $script:DefaultSettings -Confirm:$false
        [PSCustomObject]$script:DefaultSettings
    }
    else {
        Get-Content -Path $script:ConfigPath | ConvertFrom-Json
    }

    if ($Name) {
        $Configuration.$Name
    }
    else {
        $Configuration
    }
}
