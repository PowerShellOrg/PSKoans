function Get-PSKoan {
    <#
    .SYNOPSIS
        Gets koan topic metadata for each topic.

    .DESCRIPTION
        Get-PSKoan finds Koans in either the Module or User locations.
        Koan information includes position and module information, as well as topic name.

    .PARAMETER IncludeModule
        Get default PowerShell Koans as well as Koans for the specified module.
        Wildcards are supported.

    .PARAMETER ListModules
        List the modules included with PSKoans.

    .PARAMETER Module
        Get Koans for the specified module only.
        Wildcards are supported.

    .PARAMETER Scope
        Get koans from the specified scope.
        The default scope is Module.
        User scope gets Koan information from the location used by Get-PSKoanLocation.

    .PARAMETER SkipAttributeParsing
        By default, Get-PSKoan attempts to retrieve the Position and Module information from the Koan attribute in each file.
        This process may be skipped by using this parameter.

    .PARAMETER Topic
        Reset the specified topic or topics.
        Wildcards are supported.

    .EXAMPLE
        Get-PSKoan

        Get all Koans in the PSKoans module, excluding koans for individual modules.

    .EXAMPLE
        Get-PSKoan -IncludeModule *

        Get all Koans in the PSKoans module, include all koans for individual PowerShell modules.

    .EXAMPLE
        Get-PSKoan -Topic AboutArrays

        Get information about the AboutArrays koans.

    .EXAMPLE
        Get-PSKoan -Module ActiveDirectory

        Get koans from the ActiveDirectory module only.

    .EXAMPLE
        Get-PSKoan -Scope User

        Get all Koans in the User location, excluding koans for individual modules.

    .NOTES
        Author: Chris Dent (@indented-automation)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoan.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter',
        'SkipAttributeParsing',
        Justification = 'Referenced inside a nested ForEach-Object scriptblock, which PSScriptAnalyzer does not always trace back to the enclosing param.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter',
        'ListModules',
        Justification = 'Used only to select the ListModules parameter set; dispatch reads $PSCmdlet.ParameterSetName, not the switch value.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'IncludeModule',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoan.md')]
    [OutputType('PSKoans.KoanInfo')]
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string[]]
        $Topic,

        [Parameter(ParameterSetName = 'ModuleOnly')]
        [SupportsWildcards()]
        [string[]]
        $Module,

        [Parameter(ParameterSetName = 'IncludeModule')]
        [SupportsWildcards()]
        [string[]]
        $IncludeModule,

        [ValidateSet('User', 'Module')]
        [string]
        $Scope = 'Module',

        [Parameter()]
        [switch]
        $SkipAttributeParsing,

        [Parameter(Mandatory, ParameterSetName = 'ListModules')]
        [switch]
        $ListModules
    )

    $ParentPath = switch ($Scope) {
        'User' {
            $KoanLocation = Get-PSKoanLocation
            Write-Verbose "Checking existence of koans folder"
            if (-not (Test-Path $KoanLocation)) {
                Write-Verbose "Koans folder does not exist. Initiating full reset..."
                Update-PSKoan -Confirm:$false
            }

            $KoanLocation
        }
        'Module' { Join-Path -Path $script:ModuleRoot -ChildPath 'Koans' }
    }

    if ($PSCmdlet.ParameterSetName -eq 'ListModules') {
        $modulesPath = Join-Path -Path $ParentPath -ChildPath 'Modules'

        if (Test-Path $modulesPath) {
            $modulesPath |
                Get-ChildItem -Directory |
                Select-Object -ExpandProperty Name
        }

        return
    }

    $KoanDirectories = switch ($PSCmdlet.ParameterSetName) {
        'IncludeModule' {
            $Module = $IncludeModule
            Get-ChildItem $ParentPath -Exclude Modules -Directory
        }
        { $Module } {
            $ModuleRegex = ConvertFrom-WildcardPattern -Pattern $Module

            $modulesPath = Join-Path -Path $ParentPath -ChildPath 'Modules'
            if (Test-Path $modulesPath) {
                Get-ChildItem $modulesPath -Directory |
                    Where-Object { $_.Name -match $ModuleRegex }
            }
        }
    }

    $TopicRegex = ConvertFrom-WildcardPattern -Pattern $Topic
    $ParentPathPattern = [regex]::Escape($parentPath)
    # Declared to avoid scope problems when attribute parsing is not required.
    $KoanAttribute = $null
    try {
        $KoanDirectories |
            Get-ChildItem -Recurse -Filter *.Koans.ps1 |
            Where-Object { -not $Topic -or $_.BaseName -replace '\.Koans$' -match $TopicRegex } |
            Assert-UnblockedFile -PassThru |
            ForEach-Object {
                if (-not $SkipAttributeParsing) {
                    $KoanAttribute = Get-KoanAttribute -Path $_.FullName

                    if (-not $KoanAttribute) {
                        return
                    }
                }

                [PSCustomObject]@{
                    Topic        = $_.BaseName -replace '\.koans$'
                    Module       = $KoanAttribute.Module
                    Position     = $koanAttribute.Position
                    Path         = $_.FullName
                    RelativePath = $_.Fullname -replace $ParentPathPattern -replace '^\\'
                    PSTypeName   = 'PSKoans.KoanInfo'
                }
            } |
            Sort-Object { $_.Module -ne '_powershell' }, Module, Position, Topic
    }
    catch {
        $pscmdlet.ThrowTerminatingError($_)
    }
}
