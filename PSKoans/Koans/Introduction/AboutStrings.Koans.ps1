using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    'Number',
    Justification = 'Demonstrates that "$Number:text" does not expand $Number (colon starts a drive/scope qualifier); intentionally unused by the koan.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    'String2',
    Justification = 'Setup value for the blank the learner fills in below with $String2; unused until solved.'
)]
[Koan(Position = 104)]
param()
<#
    Strings

    Strings in PowerShell come in two flavours: expandable strings, and string
    literals. Expandable strings in PowerShell are created using double quotes,
    while string literals are created with single quotes.

    Expandable strings in PowerShell can evaluate expressions or variables
    mid-string in order to dynamically insert values into a preset string, like
    a sort of impromptu template string.
#>
Describe 'Strings' {

    It 'is a simple string of text' {
        '____' | Should -Be 'string'
    }

    Context 'Literal Strings' {

        It 'assumes everything is literal' {
            $var = 'Some things you must take literally'
            '____' | Should -Be $var
        }

        It 'can contain special characters' {
            # 'Special' is just a title.
            $complexVar = 'They interpret these characters literally: $ ` $()'
            '____' | Should -Be $complexVar
        }

        It 'can contain quotation marks' {
            $Quotes = 'This creates only one set of ''quotation marks'' in the string.'

            # Single quotes are easier to work with in double-quoted strings.
            "____" | Should -Be $Quotes
        }
    }

    Context 'Evaluated Strings' {

        It 'can expand variables' {
            $var = 'apple'
            '____' | Should -Be "My favorite fruit is $var"
        }

        It 'can do a simple expansion' {
            '____' | Should -Be "Your home directory is: $HOME"
        }

        It 'handles other ways of doing the same thing' {
            # Strings can handle entire subexpressions being inserted as well!
            $String = "Your home folder is: $(Get-Item -Path $HOME)"
            '____' | Should -Be $String
        }

        It 'will expand variables that do not exist' {
            <#
                If a string contains a variable that has not been created,
                PowerShell will still try to expand the value. A variable that
                doesn't exist or has a null value will simply disappear when it
                is expanded.

                This could be the result of a typing mistake.
            #>
            $String = "PowerShell's home folder is: $SPHome"
            "____" | Should -Be $String
        }

        It 'can get confused about :' {
            <#
                In PowerShell, a colon (:) is used to define a scope or provider
                path for a variable. For example, the Environment provider uses
                the syntax $env:SomeVariableName, which refers to an environment
                variable named 'SomeVariableName'. Environment variables are
                initially set by the operating system and usually passed to
                child processes, offering a limited way for processes to
                communicate in a limited way.

                When : is part of a string, PowerShell will try and expand a
                variable in that scope or from that provider.
            #>

            $Number = 1
            $String = "$Number:Get shopping"
            '____' | Should -Be $String
        }

        It 'can use curly braces to mark the variable name' {
            <#
                Variables followed by : or adjacent to other characters normally
                included in a variable name can be referenced by enclosing the
                variable name with curly braces like so: ${varName}
            #>

            $Number = 1
            $String = "${Number}:Get shopping"
            '____' | Should -Be $String
        }

        It 'can escape special characters with backticks' {
            $LetterA = 'Apple'
            $String = "`$LetterA contains $LetterA."

            '____' | Should -Be $String
        }

        It 'can escape quotation marks' {
            $String = "This is a `"string`" value."
            $AlternateString = "This is a ""string"" value."

            # A mirror image, a familiar pattern, reflected in the glass.
            $Results = @(
                '____'
                '____'
            )
            $Results | Should -Be @($String, $AlternateString)
        }

        It 'can insert special characters with escape sequences' {
            <#
                All text strings in PowerShell are actually just a series of
                character values. Each of these values has a specific number
                assigned in the [char] type that represents that letter, number,
                or other character.

                .NET uses UTF16 encoding for [char] and [string] values.
                However, with most common letters, numbers, and symbols, the
                assigned [char] values are identical to the ASCII values.

                ASCII is an older standard encoding for text, but you can still
                use all those values as-is with [char] and get back what you'd
                expect thanks to the design of the UTF16 encoding. An extended
                ASCII code table is available at: https://www.ascii-code.com/
            #>
            $ExpectedValue = [char] 9

            <#
                If you're not sure what character you're after, consult the
                ASCII code table above.

                Get-Help about_Special_Characters will list the escape sequence
                you can use to create the right character with PowerShell's
                native string escape sequences.
            #>
            $ActualValue = "`_"

            $ActualValue | Should -Be $ExpectedValue
        }
    }

    Context 'String Concatenation' {

        It 'adds strings together' {
            # Two become one.
            $String1 = '_____'
            $String2 = 'is cool.'

            $String1 + ' ' + $String2 | Should -Be 'This string is cool.'
        }

        It 'can be done more easily' {
            # Water mixes seamlessly with itself.
            $String1 = 'This string'
            $String2 = 'is cool.'

            "$String1 $____" | Should -Be 'This string is cool.'
        }
    }

    Context 'Substrings' {

        It 'lets you select portions of a string' {
            # Few things require the entirety of the library.
            $String = 'At the very top!'

            <#
                The [string].Substring() method has a few variants, or
                "overloads." The most common overloads are:

                string Substring(int startIndex)
                string Substring(int startIndex, int length)

                In other words:
                - Both variants return a string.
                - One variant needs two index references, where to start and
                    stop in selecting the substring.
                - The other only requires a starting index, and goes until the
                    end of the original string.
            #>
            '____' | Should -Be $String.Substring(0, 6)
            '____' | Should -Be $String.Substring(7)
        }
    }

    Context 'Here-Strings' {
        <#
            Here-strings are a fairly common programming concept, but have some
            additional quirks in PowerShell that bear mention. They start with
            the sequence @' or @" and end with the matching reverse "@ or '@
            sequence.

            The terminating sequence MUST be at the start of the line, or they
            will be ignored, and the string will not terminate correctly.
        #>
        It 'can be a literal string' {
            $LiteralString = @'
            Hullo!
'@ # This terminating sequence must be at the start of the line.

            # "Empty" space, too, is a thing of substance for some.
            '            ____' | Should -Be $LiteralString
        }

        It 'can be an evaluated string' {
            # The key is in the patterns.
            $Number = __

            # Indentation sometimes gets a bit disrupted around here-strings.
            $String = @"
I am number #$Number!
"@

            '____' | Should -Be $String
        }

        It 'interprets all quotation marks literally' {
            $AllYourQuotes = @"
All things that are not 'evaluated' are "recognised" as characters.
"@
            '____' | Should -Be $AllYourQuotes
        }
    }

    Context 'Arrays and Strings' {

        It 'can be inserted into a string' {
            <#
                Arrays converted to string will display each member separated by
                a space by default.
            #>
            $array = @(
                'Hello'
                'world'
            )
            '____ ____' | Should -Be "$array"
        }

        It 'can be joined with a different string by setting the OFS variable' {
            <#
                The $OFS variable, short for "Output Field Separator," defines
                the separator used to join an array when it is converted to a
                string.

                By default, the OFS variable is unset, and a single space is
                used as the separator.
            #>

            $OFS = '... '
            $array = @(
                'Hello'
                'world'
            )
            '____' | Should -Be "$array"

            # Removing the created OFS variable, the default will be restored.
            Remove-Variable -Name OFS -Force
        }
    }
}
