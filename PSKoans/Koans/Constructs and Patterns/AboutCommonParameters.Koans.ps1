
<#
    Common Parameters

    When using CmdletBinding to create an advanced function, several
    automatic parameters are automatically given to the function:

        -Verbose
        -Debug
        -WarningAction
        -WarningVariable
        -ErrorAction
        -ErrorVariable
        -InformationAction
        -InformationVariable
        -OutVariable
        -OutBuffer
        -PipelineVariable

    These parameters are also shared with all compiled cmdlets (usually written
    in C# or another .NET language), but their exact effect can vary a little
    bit depending on whether the author of the function/cmdlet is utilising the
    relevant features.
#>
Describe 'Common Parameters' {

    It 'provides the -Verbose and -Debug common parameters' {
        <#
            -Verbose is a parameter that requests additional detail on a
            function's actions during processing. This information may be
            useful for debugging at times, but is also used as a basic kind
            of progress and additional metadata output.

            Verbose messages can be written with the Write-Verbose cmdlet.

            These messages are automatically hidden by default, but users
            wanting more information on the command's operation can opt-in with
            the -Verbose switch.

            Typically verbose information will include some brief but
            informative messaging around what the command is doing internally.
            Good verbose messages don't provide intense amounts of detail, but
            still give the user a good summary of the actions the command is
            taking.

            -Debug is very similar, but intended specifically for debug
            messages. In Windows PowerShell, -Debug mode will actually
            prompt before coninuing for every debug message emitted. This
            behaviour has changed in recent versions of PowerShell (6.2+)
            and it behaves more like a detailed and focused version of
            -Verbose.

            Similarly to verbose messaging, debug messaging can be written with
            the Write-Debug cmdlet.

            Debug messaging can be extremely in-depth and detailed; it's often
            more to aid development efforts by emitting more thorough
            information that the command author can use to directly infer where
            bugs may be present, or unintended consequences may occur as a
            result of the command's action.

            Since it's written primarily for the command author, whether a
            command has any debug messaging will often depend on whether the
            author(s) of the command felt a need to include it or not. It can be
            invaluable for debugging efforts, but may often be omitted for less
            complicated commands.
        #>

        function Test-Verbose {
            [CmdletBinding()]
            param()
            <#
                A call to Write-Verbose displays the message, but only if
                -Verbose is enabled. It can be enabled with the -Verbose
                parameter, or by setting the $VerbosePreference variable to
                'Continue' or another mode that displays the result.

                By default, verbose messaging is NOT shown.
            #>
            Write-Verbose "____"
        }

        $String = "When you're falling in a forest, and there's nobody around, do you ever really crash or even make a sound?"

        <#
            By redirecting the verbose stream, we can test the result.
            Verbose is on stream 4, and debug is on stream 5.

            By default, data on alternate streams does not get passed over the
            pipeline; pipelines only handle output. Redirecting the stream back
            to the output stream lets a pipeline pass the data where we want.
        #>
        Test-Verbose 4>&1 | Should -BeNullOrEmpty

        # Verbose messages should appear with the -Verbose parameter.
        Test-Verbose -Verbose 4>&1 | Should -Be $String
    }

    It 'provides the -WarningAction common parameter' {
        function Test-WarningAction {
            [CmdletBinding()]
            param()
            <#
                Calling Write-Warning will generate a warning message.
                Warnings are visible by default.

                Warnings should generally be used for non-critical information
                that users need to be aware of, but is not sufficiently harmful
                to warrant terminating the operation and/or writing an error.
            #>
            Write-Warning "____"
        }

        # Warnings are written to stream 3
        Test-WarningAction 3>&1 | Should -Be 'Something went wrong!'
        Test-WarningAction -WarningAction SilentlyContinue 3>&1 | Should -BeNullOrEmpty
    }

    It 'provides the stream-associated -*Variable common parameters' {
        <#
            With the -*Variable common parameters, individual streams can store
            their output into variables. Variables must be provided by name (as
            a string) to the corresponding parameter, and any existing content
            in the variable is overwritten. If you would like to append new
            stream output to existing content in the variable, you can specify a
            variable name prefixed with a plus sign (+).

            For the streams that display by default, this doesn't actively
            suppress any of their output; you need to combine them with a
            corresponding `-*Action` parameter if you want to suppress (or show,
            for streams that are hidden by default) the output of a given
            stream.

            Available -*Variable common parameters are:

            -WarningVariable
            -ErrorVariable
            -InformationVariable

            Note that Write-Host actually utilises the information stream, so
            the -InformationVariable will also capture any text sent to
            Write-Host. Out-Host instead bypasses all streams and writes
            directly to the host.
        #>

        function Test-StreamVariables {
            [CmdletBinding()]
            param()

            Write-Warning 'Warnings are shown by default'
            Write-Error 'Errors are also shown by default, usually with more detail'
            Write-Information 'Information is hidden by default, but still recorded by transcripts'
        }

        $Quiet = @{
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
        }
        Test-StreamVariables @Quiet -InformationVariable 'info' -ErrorVariable 'err' -WarningVariable 'warn'

        # Which variables
        $____ | Should -Be 'Warnings are shown by default'
        $____ | Should -Be 'Errors are also shown by default, usually with more detail'
        $____ | Should -Be 'Information is hidden by default, but still recorded by transcripts'
    }

    It 'provides the -ErrorAction common parameter' {

    }

    It 'provides the -ErrorVariable common parameter' {

    }

    It 'provides the -InformationAction common parameter' {

    }

    It 'provides the -InformationVariable common parameter' {

    }

    It 'provides the -OutVariable common parameter' {

    }

    It 'provides the -OutBuffer common parameter' {

    }

    It 'provides the -PipelineVariable common parameter' {

    }
}
