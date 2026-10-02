using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseSingularNouns',
    '',
    Justification = 'Add-Things/Add-Numbers are minimal in-exercise example functions; naming is incidental to the parameter-passing lesson.'
)]
[Koan(Position = 117)]
param()
<#
    Functions & Script Blocks (I)

    Now that we've seen the basics of variable assignment and typing,
    we'll look at some basic examples of functions and how they operate.

    A script block in PowerShell is essentially an unnamed or anonymous
    function, and can be assigned to a variable or even later assigned
    a name as needed.
#>
Describe 'Functions' {

    It 'allows you to assign a name to a sequence of commands' {
        <#
            An apt name eases the transition to abstraction.
            PowerShell function names are named in convention following
            the cmdlets; Verb-Noun. To see the list of approved
            PowerShell verbs, run 'Get-Verb' in the console.

            There are many methods of sending output from a function.
        #>
        function Get-Number {
            <#
                Explicit use of Write-Output allows multiple items to be output
                within the function without causing the function to exit.
            #>
            Write-Output 20
            Write-Output 42
        }

        __ | Should -Be (Get-Number)

        function Get-ReturnedNumber {
            <#
                Use of the return statement causes all output previously declared
                to be sent, along with any output passed to the return statement
                itself, then ends the function.
            #>
            return __
            Write-Output "Does not return anything."
        }

        Get-ReturnedNumber | Should -Be 13

        function Get-DroppedNumber {
            <#
                Leaving a value, or a statement that returns a value on a line
                by itself causes that output to be 'dropped' to the output
                stream, similar to functional languages. It can be considered
                an implicit (and faster) 'Write-Output'
            #>
            12
        }

        __ | Should -Be (Get-DroppedNumber)
    }

    It 'can accept parameters' {
        # Simplicity is a two-sided coin.
        function Add-Things {
            return ($args[0] + $args[1])
        }

        # Values are supplied separated by spaces, without parentheses.
        Add-Things '7' __ | Should -Be '72' # Strings add differently than numbers!
        __ | Should -Be (Add-Things 1 2)

        # The road to mastery is travelled with many small steps.
        function Add-Numbers ($Number1, $Number2) {
            return ($Number1 + $Number2)
        }

        __ | Should -Be (Add-Numbers 1 7)
        Add-Numbers __ 15 | Should -Be 31

        <#
            Values can be passed to specified parameters; these values will be assigned to
            the variables of the same name defined at the head of the function.
        #>
        Add-Numbers -Number2 8 -Number1 12 | Should -Be 20
    }

    It 'can declare parameters explicitly' {
        function Measure-String {
            <#
                Declaring parameters in this way allows for more advanced techniques,
                which will be covered in AboutAdvancedFunctions. It works similarly
                to the simpler technique, values can be passed in the same way by
                position or name.
            #>
            param(
                $InputString
            )
            return $InputString.Length
        }
        # How long is a piece of string?
        Measure-String 'Hello!' | Should -Be 6
        __ | Should -Be (Measure-String 'Muffins')
    }
}

Describe 'Script Block' {
    <#
        Script blocks can be used to group commands without defining a function.
        These can be used for various things, most commonly for parameters or
        defining a sequence of actions to be executed multiple times.

        Many PowerShell cmdlets can take script blocks as parameters, particularly
        pipeline cmdlets.

        .FORWARDHELPTARGETNAME
        about_Script_Blocks
    #>
    It 'is an anonymous function' {
        $Script = {
            throw 'This is a script block that just throws an error.'
        }

        # Sometimes, you just want to watch things burn, and the console to stream red errors.
        $Script2 = {
            # Currently, this will just output the script block as an object
            # Try appending .Invoke() to the following line to cause the original block to be executed
            $Script
        }
        $Script | Should -Throw
        $Script2 | Should -Throw
    }
}
