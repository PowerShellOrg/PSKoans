function Get-Karma {
    <#
    .SYNOPSIS
        Retrieves information about your progress in PSKoans.

    .DESCRIPTION
        Get-Karma executes Pester against the koans and outputs a short report on your current progress.

    .PARAMETER IncludeModule
        Get Karma for the default PowerShell Koans as well as Koans for the specified module.
        Wildcards are supported.

    .PARAMETER List
        Output a complete list of available koan topics.

    .PARAMETER Module
        Get Karma for the specified module only.
        Wildcards are supported.

    .PARAMETER Topic
        Execute koans only from the selected Topic(s).
        Wildcard patterns are permitted.

    .EXAMPLE
        Get-Karma

        Outputs a hashtable containing information about your progress.

    .EXAMPLE
        Get-Karma -List

        Outputs a list of koan topics, including both the user file location and the module file location.

    .NOTES
        Author: Joel Sallow (@vexx32)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Get-Karma.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Get-Karma.md')]
    [OutputType('PSKoans.Result', 'PSKoans.CompleteResult')]
    [Alias()]
    param(
        [Alias('Koan', 'File')]
        [SupportsWildcards()]
        [string[]]
        $Topic,

        [Parameter(Mandatory, ParameterSetName = 'ModuleOnly')]
        [Parameter(ParameterSetName = 'ListKoans')]
        [string[]]
        $Module,

        [Parameter(Mandatory, ParameterSetName = 'IncludeModule')]
        [string[]]
        $IncludeModule,

        [Parameter(Mandatory, ParameterSetName = 'ListKoans')]
        [Alias('ListKoans', 'ListTopics')]
        [switch]
        $List
    )

    $GetParams = @{
        Scope = 'User'
    }
    switch ($pscmdlet.ParameterSetName) {
        'IncludeModule' { $GetParams['IncludeModule'] = $IncludeModule }
        'ModuleOnly' { $GetParams['Module'] = $Module }
        { $Topic } { $GetParams['Topic'] = $Topic }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'ListKoans' {
            Get-PSKoan @GetParams
        }
        default {
            Write-Verbose 'Sorting koans...'
            try {
                $SortedKoanList = Get-PSKoan @GetParams
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            foreach ($item in $IncludeModule) {
                if ($SortedKoanList.Where{ $_.Module -notlike $item }.Count -eq 0) {
                    $warningString = @(
                        "Koans for a module name matching '$item' were not found in your user directory."
                        "Please run Update-PSKoan -Module $item to ensure those modules are present."
                    ) -join ' '

                    Write-Warning $warningString
                }
            }

            Write-Verbose "Koan files retrieved: $($SortedKoanList.Count)"
            Write-Verbose 'Counting koans...'

            if ($SortedKoanList.Count -eq 0) {
                if ($Topic) {
                    $Message = @(
                        'Could not find any PSKoans topics matching Topic(s): {0}.'
                        'Use Update-PSKoan to ensure your koan library is up to date.'
                    ) -join ' '
                    $TopicList = $Topic -join ','

                    $ErrorDetails = @{
                        ExceptionType    = 'System.IO.FileNotFoundException'
                        ExceptionMessage = $Message -f $TopicList
                        ErrorId          = 'PSKoans.TopicNotFound'
                        ErrorCategory    = 'ObjectNotFound'
                        TargetObject     = $TopicList
                    }
                    $PSCmdlet.ThrowTerminatingError( (New-PSKoanErrorRecord @ErrorDetails) )
                }

                if ($Module) {
                    # No koans were found because modules aren't copied by default.
                    Update-PSKoan -Module $Module -Confirm:$false
                    Get-Karma @PSBoundParameters

                    return
                }

                # Something's wrong; possibly a koan folder from older versions, or a folder exists but has no files
                $Modules = if ($IncludeModule) {
                    @{ IncludeModule = $IncludeModule }
                }
                else {
                    @{ }
                }

                Write-Warning 'No koans found in your koan directory. Initiating full reset...'
                Update-PSKoan -Confirm:$false @Modules
                Get-Karma @PSBoundParameters # Re-call ourselves with the same parameters

                return # Skip the rest of the function
            }

            [int]$TotalKoans = Measure-Koan $SortedKoanList
            $KoansPassed = 0

            foreach ($KoanFile in $SortedKoanList) {
                Write-Verbose "Testing karma with file [$($KoanFile.Path)]"

                # Execute in a fresh scope to prevent internal secrets being leaked
                $PesterTests = Invoke-Koan @{
                    Path     = $KoanFile.Path
                    PassThru = $true
                    Output   = 'None'
                }

                $KoansPassed += $PesterTests.PassedCount

                Write-Verbose "Karma: $KoansPassed"
                if ($PesterTests.FailedCount -gt 0) {
                    Write-Verbose 'Your karma has been damaged.'
                    break
                }
            }

            $Meditation = if ($PesterTests.FailedCount -gt 0) {
                $NextKoanFailed = $PesterTests.Failed[0]

                $script:CurrentTopic = @{
                    Name        = $KoanFile.Topic
                    Completed   = $PesterTests.PassedCount
                    Total       = $PesterTests.TotalCount
                    CurrentLine = ($NextKoanFailed.ErrorRecord.DisplayStackTrace -split '\r?\n')[1] -replace ':.+'
                }

                [PSCustomObject]@{
                    PSTypeName     = 'PSKoans.Result'
                    Describe       = $NextKoanFailed.Block.Name
                    It             = $NextKoanFailed.Name
                    Expectation    = $NextKoanFailed.ErrorRecord.DisplayErrorMessage
                    Meditation     = $NextKoanFailed.ErrorRecord.DisplayStackTrace
                    KoansPassed    = $KoansPassed
                    TotalKoans     = $TotalKoans
                    CurrentTopic   = [PSCustomObject]$script:CurrentTopic
                    Results        = $PesterTests.Tests
                    RequestedTopic = $Topic
                }
            }
            else {
                [PSCustomObject]@{
                    PSTypeName     = 'PSKoans.CompleteResult'
                    KoansPassed    = $KoansPassed
                    TotalKoans     = $TotalKoans
                    RequestedTopic = $Topic
                    Complete       = $true
                }
            }

            $Meditation
        }
    }
}
