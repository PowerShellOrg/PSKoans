function Show-Karma {
    <#
    .SYNOPSIS
        Reflect on your progress and check your answers.

    .DESCRIPTION
        Show-Karma executes Pester against the koans to evaluate if you have made the necessary corrections for success.
        The default output mode is to the information stream, with decorated flavour text and progress information.

        If you want a more data-oriented results report, use `Get-Karma` instead.

    .PARAMETER ClearScreen
        Clears the console host before displaying the meditation prompt.

    .PARAMETER Contemplate
        Opens your local koans library.
        If VS Code is installed, it will start VS Code in the folder.
        Otherwise, the folder is simply opened in a file explorer.
        If you have VS Code Insiders installed, you can set `$env:PSKoans_EditorPreference = "code-insiders"` to indicate VS Code Insiders should be opened instead.

    .PARAMETER Detailed
        Adds a summarized view of the current topic file to the meditation prompt.
        The summary will contain a full list of all koans in the file, and indicate their current status.

    .PARAMETER IncludeModule
        Show Karma for the default PowerShell Koans as well as Koans for the specified module.
        Wildcards are supported.

    .PARAMETER Library
        Opens the current `KoanLocation` folder in the preferred editor.
        To set the preferred editor, use `Set-PSKoanSetting`.
        If the preferred editor cannot be found or the setting is cleared, the folder will be opened in the default handler.
        This should be Windows Explorer on Windows, Finder on Mac, etc.

    .PARAMETER List
        Output a complete list of available koan topics.

    .PARAMETER Module
        Show Karma for Koans in the specified module only.
        Wildcards are supported.

    .PARAMETER Topic
        Execute koans only from the selected Topic(s).
        Wildcard patterns are permitted.
        When provided along with `-Contemplate`, the targeted topic will be respected.

    .EXAMPLE
        Show-Karma

        Assesses the koan lessons, and displays the meditation prompt with the results.

    .EXAMPLE
        Show-Karma -Contemplate

        Opens the current koan file in the editor specified by the `Editor` setting.
        Use `Set-PSKoanSetting` to change the editor used.

        If a known editor (`code`, `code-insiders`, `codium`, or `atom`) is used, PSKoans will pass along line information as well.

    .EXAMPLE
        Show-Karma -Contemplate -Topic AboutComparison

        Opens the specified `AboutComparison` topic file in the preferred editor.

    .NOTES
        Author: Joel Sallow (@vexx32)

    .LINK
        https://github.com/vexx32/PSKoans/blob/main/docs/Get-Karma.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Show-Karma.md')]
    [OutputType([void])]
    [Alias('Invoke-PSKoans', 'Test-Koans', 'Get-Enlightenment', 'Meditate', 'Clear-Path', 'Measure-Karma')]
    param(
        [Parameter(ParameterSetName = 'ListKoans')]
        [Parameter(ParameterSetName = 'ListKoans-ModuleOnly')]
        [Parameter(ParameterSetName = 'ListKoans-IncludeModule')]
        [Parameter(ParameterSetName = 'ModuleOnly')]
        [Parameter(ParameterSetName = 'IncludeModule')]
        [Parameter(ParameterSetName = 'OpenFile')]
        [Parameter(ParameterSetName = 'OpenFile-ModuleOnly')]
        [Parameter(ParameterSetName = 'OpenFile-IncludeModule')]
        [Parameter(ParameterSetName = 'Default')]
        [Alias('Koan', 'File')]
        [SupportsWildcards()]
        [string[]]
        $Topic,

        [Parameter(Mandatory, ParameterSetName = 'ModuleOnly')]
        [Parameter(Mandatory, ParameterSetName = 'ListKoans-ModuleOnly')]
        [Parameter(Mandatory, ParameterSetName = 'OpenFile-ModuleOnly')]
        [SupportsWildcards()]
        [string[]]
        $Module,

        [Parameter(Mandatory, ParameterSetName = 'IncludeModule')]
        [Parameter(Mandatory, ParameterSetName = 'ListKoans-IncludeModule')]
        [Parameter(Mandatory, ParameterSetName = 'OpenFile-IncludeModule')]
        [SupportsWildcards()]
        [string[]]
        $IncludeModule,

        [Parameter(Mandatory, ParameterSetName = 'ListKoans')]
        [Parameter(Mandatory, ParameterSetName = 'ListKoans-ModuleOnly')]
        [Parameter(Mandatory, ParameterSetName = 'ListKoans-IncludeModule')]
        [Alias('ListKoans', 'ListTopics')]
        [switch]
        $List,

        [Parameter(Mandatory, ParameterSetName = 'OpenFile')]
        [Parameter(Mandatory, ParameterSetName = 'OpenFile-ModuleOnly')]
        [Parameter(Mandatory, ParameterSetName = 'OpenFile-IncludeModule')]
        [Alias('Meditate')]
        [switch]
        $Contemplate,

        [Parameter(Mandatory, ParameterSetName = 'OpenFolder')]
        [Alias('OpenFolder')]
        [switch]
        $Library,

        [Parameter()]
        [Alias()]
        [switch]
        $ClearScreen,

        [Parameter(ParameterSetName = 'ModuleOnly')]
        [Parameter(ParameterSetName = 'IncludeModule')]
        [Parameter(ParameterSetName = 'Default')]
        [Alias()]
        [switch]
        $Detailed
    )

    $GetParams = @{ }
    switch ($PSCmdlet.ParameterSetName) {
        { $_ -match 'IncludeModule$' } { $GetParams['IncludeModule'] = $IncludeModule }
        { $_ -match 'ModuleOnly$' } { $GetParams['Module'] = $Module }
        { $PSBoundParameters.ContainsKey('Topic') } { $GetParams['Topic'] = $Topic }
    }

    switch ($PSCmdlet.ParameterSetName) {
        { $_ -match '^ListKoans' } {
            Get-PSKoan @GetParams
        }
        'OpenFolder' {
            $KoanLocation = Get-PSKoanLocation
            Write-Verbose "Checking existence of koans folder"
            if (-not (Test-Path $KoanLocation)) {
                Write-Verbose "Koans folder does not exist. Initiating full reset..."
                Update-PSKoan -Confirm:$false
            }

            Write-Verbose "Opening koans folder"
            $Editor = Get-PSKoanSetting -Name Editor
            if ($Editor -and (Get-Command -Name $Editor -ErrorAction SilentlyContinue)) {
                $EditorSplat = @{
                    FilePath     = $Editor
                    ArgumentList = '"{0}"' -f (Resolve-Path $KoanLocation)
                    NoNewWindow  = $true
                }
                Start-Process @EditorSplat
            }
            else {
                $KoanLocation | Invoke-Item
            }
        }
        { $_ -match '^OpenFile' } {
            # If there is no cached data, we need to call Get-Karma to populate it
            if (-not $script:CurrentTopic -or ($Topic -and $script:CurrentTopic.Name -notlike $Topic)) {
                try {
                    # We can discard this; the results we need are saved in $script:CurrentTopic
                    $null = Get-Karma @GetParams
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }

            $Editor = Get-PSKoanSetting -Name Editor
            $KoanParams = @{
                Topic         = $script:CurrentTopic.Name
                IncludeModule = @( $Module; $IncludeModule )
                Scope         = 'User'
            }
            $FilePath = (Get-PSKoan @KoanParams).Path
            $LineNumber = $script:CurrentTopic.CurrentLine

            $Arguments = switch ($Editor) {
                { $_ -in 'code', 'code-insiders', 'codium' } {
                    '--goto'
                    '"{0}":{1}' -f (Resolve-Path $FilePath), $LineNumber
                    '--reuse-window'
                }
                atom {
                    '"{0}":{1}' -f (Resolve-Path $FilePath), $LineNumber
                }
                default {
                    '"{0}"' -f (Resolve-Path $FilePath)
                }
            }

            if ($Editor -and (Get-Command -Name $Editor -ErrorAction SilentlyContinue)) {
                Start-Process -FilePath $Editor -ArgumentList $Arguments -NoNewWindow
            }
            else {
                Invoke-Item -Path $FilePath
            }

            # Discard the results so we avoid accidentally returning the same result multiple times
            $script:CurrentTopic = $null
        }

        default {
            if ($ClearScreen) {
                Clear-Host
            }

            $FormatParams = @{ }
            if ($Detailed) {
                $FormatParams['View'] = 'Detailed'
            }

            try {
                Get-Karma @GetParams |
                    Format-Custom @FormatParams |
                    Out-Host
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
}
