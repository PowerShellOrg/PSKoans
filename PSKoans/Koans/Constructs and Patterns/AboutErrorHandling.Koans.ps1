using module PSKoans
[Koan(Position = 308)]
param()

<#
    Error Handling in PowerShell

    PowerShell handles errors via the instances of the System.Management.Automation.ErrorRecord class.
    Each ErrorRecord object contains all the information available about an error.

    Errors come in two main flavours: terminating and non-terminating. The type you get is determined
    by the command that created the error. Generally speaking, if the command can continue processing
    items it will throw a non-terminating error, and otherwise it will throw a terminating error.

    Terminating errors can be paired with try/catch patterns that allow more granular control over
    exactly how the error is handled, while non-terminating errors can be handled with the
    $ErrorActionPreference and -ErrorAction variables.
#>

Describe 'ErrorRecord' {
    Context '$Error' {
        BeforeAll {
            <#
                $Error is an automatic variable that contains a list of recent errors.
                By calling $Error.Clear() we ensure past errors to not carry into our testing.
            #>
            $Error.Clear()
        }
        It 'sometimes has a reference to the object that caused the error' {

            # Non-terminating error behaviour can be adjusted with the -ErrorAction parameter.
            Get-Item -Path "TestDrive:\This_Shouldn't_Exist" -ErrorAction SilentlyContinue

            <#
                $Error[0] is always the most recent error. Even if an error is silenced with
                -ErrorAction SilentlyContinue, it is still recorded in $Error.
            #>
            '____' | Should -Be $Error[0].TargetObject
        }
        It 'does continue to add Errors until the PowerShell session is closed' {
            Get-Item -Path "TestDrive:\This_Shouldn't_Exist" -ErrorAction SilentlyContinue
            __ | Should -Be $Error.Count
        }
        It 'is possible to surpress the error record all together' {
            Get-Item -Path "TestDrive:\This_Shouldn't_Exist" -ErrorAction Ignore
            __ | Should -Be $Error.Count
        }
    }
    Context 'Error Assignments' {
        BeforeAll {
            $script:ErrorRecord = try {
                throw "A challenge to the sky!"
            }
            catch {
                $_
            }
        }

        It 'is an ErrorRecord' {
            # At times, even tautologies can make sense of what is, and is not.
            $ErrorRecord -is [____] | Should -BeTrue
        }

        It 'always contains a reference to an Exception' {
            $ErrorRecord.Exception | Should -Not -BeNullOrEmpty
            $ErrorRecord.Exception -is [____] | Should -BeTrue
            '____' | Should -Be $ErrorRecord.Exception.Message
        }

        It 'can be assigned one of the preset categories' {
            '____' -as [System.Management.Automation.ErrorCategory] |
                Should -Be $ErrorRecord.CategoryInfo.Category
        }

        It 'will usually specify an ErrorID' {
            <#
                These ID strings are generally used to identify the source of the error and help distinguish
                between multiple similarly-typed errors.
            #>
            '____' | Should -Be $ErrorRecord.FullyQualifiedErrorId
        }

        It 'contains an InvocationInfo reference' {
            # InvocationInfo is a quick snapshot of the surrounding environment when the error happened.
            __ | Should -Be $ErrorRecord.InvocationInfo.ScriptLineNumber
            __ | Should -Be $ErrorRecord.InvocationInfo.PipelineLength
            $ErrorString = @(
                'At ____'
                '+                 ____ "____"'
                '+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            ) -join [Environment]::NewLine

            $ErrorString | Should -Be $ErrorRecord.InvocationInfo.PositionMessage
        }
    }
}

Describe 'Types of Errors' {

    Context 'Non-Terminating Errors' {
        <#
            Non-terminating errors can be generated in one of two ways:
                - Using the Write-Error cmdlet.
                - Using the $PSCmdlet.WriteError() method in an advanced function.

            Non-terminating errors are an indication that something went wrong, but that the issue only
            affects a single item being processed; if there are more items to process, the command will
            continue to do so.

            The behaviour of this type of error can be altered by the -ErrorAction common parameter
            available on all cmdlets and advanced functions. The available values for the -ErrorAction
            parameter are:
                - Continue
                    As per normal, non-terminating errors are displayed and processing continues. (Default)
                - Ignore
                    Non-terminating errors are completely suppressed and not recorded in transcripts and $Error.
                - Inquire
                    Errors will pause execution and prompt the user for the desired action.
                - SilentlyContinue
                    Similar to Ignore, but errors are still recorded for later handling if needed.
                - Stop
                    Treat all errors as terminating errors.
        #>
        BeforeAll {
            function Write-SimpleError {
                Write-Error "Something went wrong!"
            }

            function Write-DetailedError {
                # These are only some of the parameters for Write-Error. Check Get-Help Write-Error -Full for more.
                $Params = @{
                    Exception         = [BadImageFormatException]::new("A broken mirror.")
                    Message           = "What happened here?"
                    ErrorId           = "PSKoans.TestError"
                    TargetObject      = @{Property = 1; Name = 'Jim' }
                    RecommendedAction = "Pass the test."
                }
                Write-Error @Params
            }

            function Write-ErrorWithMethod {
                [CmdletBinding()]
                param()

                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [Exception]::new("This is a very plain Exception."),
                    'PSKoans.TestWriteErrorMethod',
                    [System.Management.Automation.ErrorCategory]::LimitsExceeded,
                    { Secret-ScriptBlock }
                )

                $PSCmdlet.WriteError($ErrorRecord)
            }
        }

        It 'is emitted with the Write-Error cmdlet' {
            # The redirection operators can be used to more easily retrieve non-standard output, like errors
            $ErrorRecord = Write-SimpleError 2>&1

            '__' | Should -Be $ErrorRecord.GetType().Name
        }

        It 'can be customized in detail with the Write-Error cmdlet' {
            $ErrorRecord = Write-DetailedError 2>&1

            '__' | Should -Be $ErrorRecord.Exception.Message
            '____,____' | Should -Be $ErrorRecord.FullyQualifiedErrorId
            '__' | Should -Be $ErrorRecord.TargetObject.Name
            '__' | Should -Be $ErrorRecord.ErrorDetails.RecommendedAction
        }

        It 'is created by WriteError()' {
            $ErrorRecord = Write-ErrorWithMethod 2>&1
            '__' | Should -Be $ErrorRecord.FullyQualifiedErrorId
            '__' | Should -Be $ErrorRecord.TargetObject.ToString()
        }
    }

    Context 'Terminating Errors' {
        <#
            Terminating errors are generated in a few ways:
                - The "throw" keyword.
                - The $PSCmdlet.ThrowTerminatingError() method.
                - Using -ErrorAction Stop on any cmdlet or advanced function that generates a non-terminating error.

            Terminating errors will terminate all further execution at the level they occur in, and pass control
            to the command that called the currently executing code. They will travel up the execution stack until
            either they are handled with a catch{} block, or all commands terminate and the error is dumped into the
            console. -ErrorAction has no effect on terminating errors.

            The typical try/catch pattern looks like this:

                try {
                    # Code that might error.
                }
                catch [ExceptionType] {
                    # Code that handles error.
                    # In this block, $_ refers to the current ErrorRecord.
                }
                finally {

                }

            Specifying the exception type is optional, the default is to catch everything. If you know the types
            of errors you're looking for, it's often best to only catch the ones you're expecting. For example,
            if you handle an error like this:

            try { Start-Action } catch { Write-Host "There was an error." }

            When an error occurs, whoever called your code has absolutely no possible way to get at the
            information in the original error. No matter how much detail you put in your string of text,
            you'll be hard-pressed to match the level of detail available in ErrorRecords. Instead, you can
            re-throw the ErrorRecord you receive once you've, for example, logged the error somewhere:

            try { Start-Action } catch { Write-Log $_.Exception.Message; throw $_ }

            Valid try/catch/finally patterns include:
                - try { } catch { }
                - try { } finally { }
                - try { } catch { } finally { }

            (Multiple catch{} blocks can be used to catch various kinds of errors.)

            The finally{} block will always run whether or not the commands in the try or catch blocks generate an error of any kind, so it is often useful for disposing of objects and other cleanup when it is needed.

            trap { } is a similar statement to catch { }, except that it treats its whole scope as though it is a try block, and catches any targeted error type indiscriminately. It sees little use in PowerShell as it tends
            to limit the readability and ease of debugging one can do without modifying the code for debugging
            purposes.
        #>

        It 'can be created with the throw keyword' {
            try {
                throw "A red ball."
            }
            catch {
                # A red ball is thrown... and what is caught?
                $_ -is [____] | Should -BeTrue
                $_.Exception -is [____] | Should -BeTrue
                '____' | Should -Be $_.Exception.Message
            }
        }

        It 'can catch specific types of errors based on Exception type' {
            try {
                throw [ExecutionEngineException]::new('Catch me if you can!')
            }
            catch [System.Management.Automation.RuntimeException] {
                Should -Fail -Because "We caught the wrong error type!"
            }
            catch [ExecutionEngineException] {
                '____' | Should -Be $_.Exception.Message
                '____' | Should -Be $_.Exception.GetType().Name
            }
            catch {
                Should -Fail -Because "This block will only trigger if we don't handle the specific type separately."
            }
        }

        It 'can execute a finally{} block regardless of the error state' {
            try {
                $Value = 0
                try {
                    throw [Exception]::new('Something is wrong; abort!')
                }
                finally {
                    $Value++
                }
            }
            catch {
                # When something upstream catches the error, we can see the finally{} block still executed.
                __ | Should -Be $Value
            }
        }

        It 'can be created by ThrowTerminatingError()' {
            # ThrowTerminatingError() can only be called from within an advanced function.
            function Invoke-TerminatingError {
                [CmdletBinding()]
                param()

                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Management.Automation.WildcardPatternException]::new("The pattern breaks."),
                    'PSKoans.TestTerminatingError',
                    [System.Management.Automation.ErrorCategory]::DeadlockDetected,
                    @{ Secret = 'Blue' }
                )

                $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            }

            try {
                Invoke-TerminatingError
            }
            catch {
                # What can we catch here?
                $_ -is [____] | Should -BeTrue
                $_.Exception -is [____] | Should -BeTrue
                '____' | Should -Be $_.Exception.Message
                '____' | Should -Be $_.TargetObject.Secret
            }
        }

        It 'can be created by the Write-Error cmdlet' {
            try {
                # Provided, of course, we apply -ErrorAction Stop.
                $Params = @{
                    Message      = 'The writing upon the walls...'
                    Category     = 'InvalidData'
                    ErrorId      = 'PSKoans.Invalid'
                    TargetObject = @('Chalk', 'Crayon', 'Marker', 'Pen', 'Pencil')
                    ErrorAction  = 'Stop'
                }
                Write-Error @Params
            }
            catch {
                $_ -is [____] | Should -BeTrue
                [____] | Should -Be $_.Exception.GetType()
                '____' | Should -Be $_.Exception.Message
                @('____', '____', '____') | Should -Be $_.TargetObject[3..1]
            }
        }
    }

    <#
        Selecting Error Types

        In general terms:
        - Use the throw keyword when you intend to catch the error in the same function or script for further
        handling, or you're writing a script to perform a series of tasks and you need to exit immediately
        when the error occurs.
        - Use the $PSCmdlet.ThrowTerminatingError(), $PSCmdlet.WriteError(), or their Write-Error equivalents
        when you intend for the error to be handled by whoever is running the command you're writing.
    #>
}
