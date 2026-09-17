function Reset-PSKoan {
    <#
    .SYNOPSIS
        Reset one or more koans or koan topics to the initial state.

    .DESCRIPTION
        Replaces the koan in the user file set with the original copy of the koan from the module.

    .PARAMETER Context
        Reset koans in the specified `Context` block.

    .PARAMETER IncludeModule
        Reset the default PowerShell Koans as well as Koans for the specified module.
        Wildcards are supported.

    .PARAMETER Module
        Reset Koans for the specified module only.
        Wildcards are supported.

    .PARAMETER Name
        The name of the koan to reset.
        Wildcards are supported.

    .PARAMETER Topic
        Reset the specified topic or topics.
        Wildcards are supported.

    .EXAMPLE
        Reset-PSKoan

        Completely reset all koans in the user folder to the initial state.
        You will be prompted to confirm.

    .EXAMPLE
        Reset-PSKoan -Topic AboutArrays

        Resets all koans in the AboutArrays topic.

    .EXAMPLE
        Reset-PSKoan -Topic AboutArrays, AboutComparison

        Reset all koans in the AboutArrays and AboutComparison topics.

    .EXAMPLE
        Reset-PSKoan -Topic AboutArrays -Name 'allows the collection to be split into multiple parts'

        Resets the "allows the collection to be split into multiple parts" koan in the AboutArrays topic.

    .EXAMPLE
        Reset-PSKoan -Topic AboutComparison -Name 'may coerce values to boolean' -Context '-and'

        Resets the "may coerce values to boolean" koan in the "-and" context of the AboutComparison topic.

    .EXAMPLE
        Reset-PSKoan -Topic AboutComparison -Context '-and'

        Resets all koans in the "-and" context of the AboutComparison topic.

    .EXAMPLE
        Reset-PSKoan -Topic AboutC* -Name returns*

        Reset koans with names starting "returns" in topics matching the wildcard pattern "AboutC*".

    .NOTES
        Author: Chris Dent (@indented-automation)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Get-PSKoan.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Update-PSKoan.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Reset-PSKoan.md',
        PositionalBinding = $false,
        DefaultParameterSetName = 'NameOnly')]
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
        $IncludeModule,

        [Parameter()]
        [SupportsWildcards()]
        [string]
        $Name = '*',

        [Parameter()]
        [SupportsWildcards()]
        [string]
        $Context = '*'
    )

    $GetParams = @{
        Scope = 'Module'
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

    if (-not $ModuleKoanList) {
        $ErrorDetails = @{
            ExceptionType    = 'System.Management.Automation.ItemNotFoundException'
            ExceptionMessage = 'No koans found matching the specified Topic in the PSKoan module'
            ErrorId          = 'PSKoans.ModuleTopicNotFound'
            ErrorCategory    = 'ObjectNotFound'
            TargetObject     = $Topic
        }
        $pscmdlet.ThrowTerminatingError((New-PSKoanErrorRecord @ErrorDetails))
    }

    foreach ($moduleTopic in $ModuleKoanList.Keys) {
        if (-not $UserKoanList.ContainsKey($moduleTopic)) {
            if ($PSCmdlet.ShouldProcess($moduleTopic, 'Add new topic to PSKoans library')) {
                Update-PSKoan -Topic $moduleTopic -Confirm:$false
            }
            else {
                $ErrorDetails = @{
                    ExceptionType    = 'System.Management.Automation.ItemNotFoundException'
                    ExceptionMessage = 'No matching topic {0} in the user Koan location' -f $moduleTopic
                    ErrorId          = 'PSKoans.UserTopicNotFound'
                    ErrorCategory    = 'ObjectNotFound'
                    TargetObject     = $moduleTopic
                }
                Write-Error -ErrorRecord (New-PSKoanErrorRecord @ErrorDetails)
            }

            continue
        }

        if ($Name -ne '*' -or $Context -ne '*') {
            $ModuleItCommands = Get-KoanIt -Path $ModuleKoanList[$moduleTopic].Path |
                Where-Object ID -like ('{0}/{1}' -f $Context, $Name) |
                Group-Object ID -AsHashTable -AsString

            if ($ModuleItCommands) {
                $UserItCommands = Get-KoanIt -Path $UserKoanList[$moduleTopic].Path |
                    Where-Object { $ModuleItCommands.Contains($_.ID) }

                if ($UserItCommands) {
                    $content = Get-Content -Path $UserKoanList[$moduleTopic].Path -Raw

                    $UserItCommands |
                        Sort-Object { $_.SourceAst.Extent.StartLineNumber } -Descending |
                        ForEach-Object {
                            # Replace the content of the koan with the modules content.
                            $content = $content.Remove(
                                $_.Ast.Extent.StartOffset,
                                ($_.Ast.Extent.EndOffset - $_.Ast.Extent.StartOffset)
                            ).Insert(
                                $_.Ast.Extent.StartOffset,
                                $ModuleItCommands[$_.ID].Ast.Extent.Text
                            )
                        }

                    if ($PSCmdlet.ShouldProcess($moduleTopic, 'Resetting selected Koans')) {
                        Set-Content -Path $UserKoanList[$moduleTopic].Path -Value $content.TrimEnd() -NoNewline
                    }
                }
                else {
                    $ErrorDetails = @{
                        ExceptionType    = 'System.Management.Automation.ItemNotFoundException'
                        ExceptionMessage = 'No matching koans in the topic {0} in the user Koan location' -f $moduleTopic
                        ErrorId          = 'PSKoans.UserItNotFound'
                        ErrorCategory    = 'ObjectNotFound'
                        TargetObject     = $moduleTopic
                    }
                    Write-Error -ErrorRecord (New-PSKoanErrorRecord @ErrorDetails)
                }
            }
            else {
                Write-Verbose -Message ('{0}: No matching koans in module' -f $moduleTopic)
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess($moduleTopic, "Resetting all koans in topic")) {
                Copy-Item -Path $ModuleKoanList[$moduleTopic].Path -Destination $UserKoanList[$moduleTopic].Path -Force
            }
        }
    }
}
