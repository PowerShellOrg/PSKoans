using module PSKoans
[Koan(Position = 307)]
param()
<#
    Redirection

    Redirection ties into the concept of PowerShell's data streams, of which there are six discrete streams.
    Each stream has an assigned number that can be referenced when using redirection operators. In order,
    the distinct streams are:

    Stream #	Description	        Introduced in
    --------	-----------	        -------------
    1           Success             PowerShell 2.0
    2           Error               PowerShell 2.0
    3           Warning             PowerShell 3.0
    4           Verbose             PowerShell 3.0
    5           Debug               PowerShell 3.0
    6           Information         PowerShell 5.0
    *           All                 PowerShell 3.0

    It could also be argued that since PowerShell operates on top of the pre-existing command-line
    interface with various applications it also makes use of the 'stdin', 'stdout', and 'stderr' streams.
    These must be dealt with when handling PowerShell as a console application or when dealing with output
    from other commands, but in most common cases native command output will be handled by PowerShell as
    being sent to stream #1, the success stream.

    Stream 1 is commonly referred to the "output" stream, as the majority of cmdlets and native commands
    send their output to this stream. Data can always be redirected to this stream from any other
    PowerShell stream.

    However, all streams above stream #1 are strongly-typed and only allow data to be sent as a specific
    type of object, depending on the stream. This means that not all data handled by the success stream
    can be handled by other streams.

    For more comprehensive explanations of the various streams and how to work with, see 'Get-Help about_Redirection'
#>
Describe 'Redirection Operators' {
    BeforeAll {
        $script:OriginalDebugPreference = $DebugPreference
        $script:OriginalVerbosePreference = $VerbosePreference
        $script:FilePath = 'TestDrive:\TestFile.txt'

        $DebugPreference = $VerbosePreference = 'Continue'
    }

    Context 'Simple Redirection' {
        It 'can be used to redirect output to files' {
            # Providing a path will send output to that location, creating the file if necessary.
            'I see mountains once again as mountains,' > $FilePath
            $FileContent = Get-Content -Path $FilePath

            '____' | Should -Be $FileContent
        }

        It 'can append to files' {
            # Appending to existing files adds a new line.
            'And waters once again as waters.' >> $FilePath
            $FileContent = Get-Content -Path $FilePath

            'I see mountains once again as mountains,' | Should -Be $FileContent[0]
            '____' | Should -Be $FileContent[1]
        }

        It 'can be used to suppress output' {
            'All things return to the void' > $null | Should -BeNullOrEmpty
            $Data = __

            $Data | Should -Not -BeNullOrEmpty
            $Data > $null | Should -BeNullOrEmpty
        }
    }

    Context 'Using Numbered Streams to Redirect' {
        BeforeAll {
            function Test-MergeStream {
                Write-Warning 'The waters are upon the mountains.'
                Write-Output 'The hills are alive with the sound of tulips.'
            }

            function Test-AllMerge {
                [CmdletBinding()]
                param()

                Write-Output 'And within every dewdrop'
                Write-Warning 'A world of dew,'
                Write-Verbose 'A world of struggle.'
                Write-Information 'A world within the world.'
            }
        }

        AfterEach {
            Clear-Content -Path $FilePath
        }

        It 'can use the default or output stream (number 1)' {
            # The number here is optional, as stream 1 is the default.
            Write-Output 'The stream flows forth with successes!' 1> $FilePath
            $FileContent = Get-Content -Path $FilePath
            '____' | Should -Be $FileContent
        }

        It 'can use the error stream (number 2)' {
            # Redirecting errors can generally only be done from any scope above where the error is generated.
            & { Write-Error 'The gasoline is in the water.' } 2> $FilePath
            $FileContent = Get-Content -Path $FilePath

            "____ : ____" | Should -Be $FileContent[0]
            "+ CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException" |
                Should -Be $FileContent[4]
            "+ FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException" |
                Should -Be $FileContent[5]
        }

        It 'can use the warning stream (number 3)' {
            Write-Warning 'The cat swatted at the dog.' 3> $FilePath
            $FileContent = Get-Content -Path $FilePath
            '____' | Should -Be $FileContent
        }

        It 'can use the verbose stream (number 4)' {
            Write-Verbose 'The sun is round.' 4> $FilePath
            $FileContent = Get-Content -Path $FilePath
            '____' | Should -Be $FileContent
        }

        It 'can use the debug stream (number 5)' {
            Write-Debug 'Debug' 5> $FilePath
            $FileContent = Get-Content -Path $FilePath
            '____' | Should -Be $FileContent
        }

        It 'can use the information stream (number 6)' {
            Write-Information 'Hark a fly!' 6> $FilePath
            $FileContent = Get-Content -Path $FilePath
            '____' | Should -Be $FileContent
        }

        It 'can be used to merge streams' {
            Test-MergeStream 3>&1 > $FilePath
            $FileContent = Get-Content -Path $FilePath

            @( 'The waters are upon the mountains.', '____' ) | Should -Be $FileContent

        }

        It 'can merge multiple streams at once' {
            # *> will merge all streams with any content into the same output pat
            Test-AllMerge *> $FilePath
            $FileContent = Get-Content -Path $FilePath

            '____' | Should -Be $FileContent[0]
            '____' | Should -Be $FileContent[1]
            '____' | Should -Be $FileContent[2]
            '____' | Should -Be $FileContent[3]
        }

        It 'can suppress all streams at once' {
            # *> $null will completely silence all output
            Test-AllMerge *> $null | Should -Be __
        }

        It 'can be used to redirect streams to files' {
            # Outputting to a file without appending will overwrite it completely
            Write-Information 'Truth can be expressed without speaking, nor remaining silent.' 6> $FilePath
            $FileContent = Get-Content -Path $FilePath

            '____' | Should -Be $FileContent
        }
    }

    AfterAll {
        $DebugPreference = $OriginalDebugPreference
        $VerbosePreference = $OriginalVerbosePreference
    }
}
