using namespace System.Collections.Generic

function Update-PSKoan {
    <#
    .SYNOPSIS
        Update the user Koan directory with new topics and koans.

    .DESCRIPTION
        Update the user Koan directory with new topics.
        Topics will be moved to new directories if appropriate.
        Old files will be removed.

        Existing koan topics are updated with new koans.
        Progress is preserved as much as possible.

    .PARAMETER IncludeModule
        Update the default PowerShell Koans as well as Koans for the specified module.
        Wildcards are supported.

    .PARAMETER Module
        Update Koans in the specified module only.
        Wildcards are supported.

    .PARAMETER Topic
        Updates the specified topic from the module.
        Wildcards are supported.

    .EXAMPLE
        Update-PSKoan -Topic AboutCompareObject

        The topic AboutCompareObject will be added if it is not already present.
        If it is already present, the current copy will be compared to the base module copy.
        If any koans are missing from the user's copy, they will be added.
        If any koans have been removed from the module copy, they will be removed from the user's copy.

    .EXAMPLE
        Update-PSKoan

        All missing topics and koans will be copied from the module.

    .NOTES
        Author: Chris Dent (@indented-automation)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoan.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Reset-PSKoan.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'TopicOnly', ConfirmImpact = "High",
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Update-PSKoan.md')]
    [OutputType([void])]
    param(
        [Parameter()]
        [Alias('Koan', 'File')]
        [SupportsWildcards()]
        [string[]]
        $Topic,

        [Parameter(Mandatory, ParameterSetName = 'ModuleOnly')]
        [SupportsWildcards()]
        [string[]]
        $Module,

        [Parameter(Mandatory, ParameterSetName = 'IncludeModule')]
        [SupportsWildcards()]
        [string[]]
        $IncludeModule
    )

    $KoanFolder = Get-PSKoanLocation
    if (-not (Test-Path -Path $KoanFolder)) {
        New-Item -Path $KoanFolder -ItemType Directory > $null
    }

    $GetParams = @{
        Scope                = 'Module'
        SkipAttributeParsing = $true
    }
    switch ($pscmdlet.ParameterSetName) {
        'IncludeModule' { $GetParams['IncludeModule'] = $IncludeModule }
        'ModuleOnly' { $GetParams['Module'] = $Module }
        { $Topic } { $GetParams['Topic'] = $Topic }
    }
    $ModuleKoanList = Get-PSKoan @GetParams | Group-Object Topic -AsHashtable -AsString

    $GetParams['Scope'] = 'User'
    $UserKoanList = Get-PSKoan @GetParams | Group-Object Topic -AsHashtable -AsString

    if (-not $UserKoanList) {
        $UserKoanList = @{ }
    }

    $TopicList = [HashSet[String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($TopicName in [string[]]$ModuleKoanList.Keys + [string[]]$UserKoanList.Keys) {
        $null = $TopicList.Add($TopicName)
    }

    switch ($TopicList) {
        <#
            Create the parent folder if the topic is in the module list,
            and the parent directory does not yet exist in the users koan location.

            Update or Copy will follow.
        #>
        { $ModuleKoanList.ContainsKey($_) } {
            $DestinationPath = Join-Path -Path $KoanFolder -ChildPath $ModuleKoanList[$_].RelativePath

            $ParentPath = Split-Path -Path $DestinationPath -Parent
            if (-not (Test-Path -Path $ParentPath)) {
                New-Item -Path $ParentPath -ItemType Directory > $null
            }
        }
        <#
            Update

            If the topic is present in both the module and the users location: Attempt
            to update the existing koan topic by merging the users answers into the topic
            file copied from the module.
        #>
        { $ModuleKoanList.ContainsKey($_) -and $UserKoanList.ContainsKey($_) } {
            if ($UserKoanList[$_].Path -ne $DestinationPath) {
                if ($PSCmdlet.ShouldProcess($_, 'Move Topic')) {
                    Write-Verbose "Moving $_"

                    $UserKoanList[$_].Path | Move-Item -Destination $DestinationPath
                }
            }

            if ($PSCmdlet.ShouldProcess($_, 'Update Koan Topic')) {
                Update-PSKoanFile -Topic $_
            }

            continue
        }
        <#
            Copy

            If the topic only exists in the module location, copy the file to the users
            location.
        #>
        { $ModuleKoanList.ContainsKey($_) } {
            if ($PSCmdlet.ShouldProcess($_, 'Add Topic')) {
                Write-Verbose "Adding $_"

                $ModuleKoanList[$_].Path | Copy-Item -Destination $DestinationPath -Force
            }

            continue
        }
        <#
            Remove

            If the topic only exists in the users location: Assume the topic has been retired
            or renamed and delete the file from the users koan location.
        #>
        { $UserKoanList.ContainsKey($_) } {
            if ($PSCmdlet.ShouldProcess($_, 'Remove Topic')) {
                Write-Verbose "Removing $_"

                $UserKoanList[$_].Path | Remove-Item
            }

            continue
        }
    }
}
