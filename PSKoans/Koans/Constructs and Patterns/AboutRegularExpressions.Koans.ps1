using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    'replaceWith',
    Justification = 'Setup value for the blank the learner fills in below with $replaceWith; unused until solved.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    'greedy',
    Justification = 'Setup value for the blank the learner fills in below with $greedy; unused until solved.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    'lazy',
    Justification = 'Setup value for the blank the learner fills in below with $lazy; unused until solved.'
)]
[Koan(Position = 320)]
param()

<#
    Regular Expressions

    Regular expressions, or regex, are sequences of characters that define a search pattern
    which is then used to find or replace parts of strings. This is especially handy for things
    like extracting text from log files, determining if some user input matches some criteria,
    or replacing parts of a string with other values.

    As you learn about regex, you'll see more and more opportunities to use it as you code.
#>
Describe 'Working With Regular Expressions' {

    Context 'Using the -match Operator' {

        It 'returns $true if a match is found' {
            <#
                In PowerShell, the -match operator returns a boolean result based on whether the
                pattern (regex) on the right side is found within the string on the left side. Yes,
                in this case 'string' is a regular expression!

                Regex is case sensitive, but -match, along with many other PowerShell operators, perform
                case-insensitive matching.
            #>

            'a string value' -match 'string' | Should -BeTrue

            $trueValue = '____'
            $trueValue -match 'climb' | Should -BeTrue

        }

        It 'returns $false if a match is not found' {
            $falseValue = '____'
            $falseValue -match 'climb' | Should -BeFalse
        }
    }

    Context 'Using the -replace Operator' {

        It 'manipulates strings' {
            <#
                The -replace operator returns a string. On the left side, it takes a string, and on
                the right side it takes two arguments. The first is a regular expression to search
                the string for, and the second is the string to replace the pattern with if it is
                found in the string.
            #>

            $replacePattern = 'simple string'
            $replaceWith = 'string that got something replaced'
            $newString = 'Here is a simple string.' -replace $replacePattern, $____
            $newString | Should -Be 'Here is a string that got something replaced.'
        }

        It 'can completely change the meaning of your text' {
            $replacePattern = '____'
            $replaceWith = '____'
            $newString = 'I love that regex is simple' -replace $replacePattern, $replaceWith
            $newString | Should -Be 'I love that regex is flexible'
        }

        It 'does not need a second argument' {
            # If you leave out a "replace with" argument, -replace still works
            $replacePattern = ' extra bits'
            $newString = 'This would be perfect if not for the extra bits' -replace $replacePattern
            $newString -eq '____' | Should -BeTrue
        }
    }

    Context 'Using the -split Operator' {

        It 'breaks up strings into collections of strings' {
            <#
                The -split operator in PowerShell returns a collection of strings. It takes a string
                on the left side, and a regular expression on the right side, and breaks the string
                into pieces where it finds that pattern.
            #>
            $splitString = 'Crows mate for life and crows memorize human faces'
            $splitPattern = '____'  # Watch out for whitespace
            $splitString -split $splitPattern | Should -Be @(
                'Crows mate for life'
                'crows memorize human faces'
            )
        }
    }

    Context 'Using the [Regex] Class Methods' {

        It 'returns RegularExpressions.Match objects' {
            <#
                You don't have to confine yourself to the regex operators that come with PowerShell.
                Since you have access to all kinds of .NET goodness, you can start taking advantage
                of those now that you are learning how regular expressions work! The following
                example looks at the Matches() method that's a part of the [Regex] class.

                The Matches() method takes two arguments. In order, they are the string that is
                being examined, followed by the regular expression being searched for.
            #>

            $regexMatch = [Regex]::Matches('Running through a forest', 'through')
            '____' | Should -Be $regexMatch.GetType().FullName
            '____' | Should -Be $regexMatch.Value
        }

        It 'has different options for how matches might work' {
            # The Matches() method has a number of overloads, including one that takes options
            $overloadString = 'REGEX IS CASE SENSITIVE'

            $standardMatch = [regex]::Matches($overloadString, 'case')
            __ | Should -Be $standardMatch.Count

            $ignoreCase = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            $optionsMatch = [regex]::Matches($overloadString, 'case', $ignoreCase)
            __ | Should -Be $optionsMatch.Count
        }

        It 'can split up strings' {
            <#
                The [regex] class has a whole lot more in it than just the ::Matches() method. It
                also has methods for splitting, replacing, and performing boolean matches. Check out
                https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regex?view=netcore-3.0#methods
                for more information.
            #>

            $catString = 'Cats have whiskers and fur'
            $catSplit = '____'
            [regex]::Split($catString, $catSplit) | Should -Be @('Cats have whiskers', 'fur')
        }

        It 'can return a boolean result' {
            $catString = 'Cats can make about 100 different sounds'
            $catMatch = 'have bees inside them'
            $result = [regex]::IsMatch($catString, $catMatch)
            $____ | Should -Be $result
        }
    }
}

Describe 'Quantifiers' {
    <#
        Until now, all of the regex exmaples have been literal values. For instace, searching for
        the pattern "through" within the string "Running through a forest", the pattern "through" is
        literally the characters t, h, r, o, u, g, and h in that order. Since quantifiers and many other
        symbols in regex have special meanings, it can sometimes be confusing for humans to read
        regular expressions.

        Quantifiers are a subset of what are commonly called "special characters" in regex. When you
        have a quantifier in a regular expression, they do not indicate that the literal character
        should be present. Instead, quantifiers are an indicator that the pattern element (which may
        be a single character or a group of characters) that occurs just before the quantifier itself
        may be repeated or omitted entirely in the target string, depending on the quantifier used.
    #>

    Context '*' {

        BeforeEach {
            $script:firstTest = ('pears' -match 'p*ears')
            $script:secondTest = ('shears' -match 'p*ears')
        }

        It 'specifies 0 or more of something' {
            <#
                The * character specifies "0 or more" of the symbol or group that comes
                immediately before it. In this case, the pattern can be read aloud as "zero or more
                of the letter p, then the letters e, a, r, and s."
            #>

            $____ | Should -Be $firstTest
            $____ | Should -Be $secondTest
        }

        It 'does not need to match the entire string' {
            <#
                What happened in that last example? What part of 'shears' matched the pattern
                'p*ears'? When you use the -match operator, you can see some interesting information
                in the automatic variable $matches. $matches is a collection of the match objects
                that are created when you use the -match operator. This isn't as flexible nor as
                robust as using [regex]::Matches(), but it's handy in a pinch.

                In this case, you'll see that the "sh" in "shears" weren't part of the match. The
                pattern "zero or more p's, followed by e, a, r, s," is found in the string, even
                though there are parts of the string that aren't relevant to that matching effort.

                $matches[0] is always your most recent match.
            #>

            '____' | Should -Be $matches[0]
        }

        It 'is not just an array of text' {
            # What else do you think $matches might contain?
            '____' | Should -Be $matches.GetType().FullName
        }
    }

    Context '+' {

        It 'specifies 1 or more of something' {
            <#
                The + symbol is a lot like the *, but instead of matching zero or more, it
                matches one or more.
            #>

            '____' -match 'p+ickles' | Should -BeTrue
        }

        It 'needs the string to start with p' {
            # Change the value of $pickleMatch to pass this test
            $pickleMatch = 'pickles'
            $pickleMatch = '____'
            $pickleMatch -match 'p+ickles' | Should -BeFalse
        }
    }

    Context '?' {

        It 'specifies 0 or 1 of something' {
            # The ? matches "zero or one" of something.
            $____ | Should -Be ('flying through the sky' -match 'f?lying')
        }

        It 'does not mind matching 0 of something' {
            $____ | Should -Be ('floating away' -match 'b?oat')
        }
    }

    Context 'Greediness and Laziness' {

        It 'matches a little or matches a lot' {
            <#
                A number of the quantifiers have two versions: A greedy version which tries to match an
                element as many times as possible, and a non-greedy (or lazy) version which tries to
                match an element as few times as possible. You can turn a greedy quantifier into a lazy
                quantifier by simply adding a ?.
            #>

            $lazyPattern = 'p+?'
            $lazyMatch = [regex]::Matches('pineapple', $lazyPattern)[0].Value
            __ | Should -Be $lazyMatch.Length
        }

        It 'is greedy by default' {
            $greedyPattern = 'a+'
            $greedyMatch = [regex]::Matches('aardvark', $greedyPattern)[0].Value
            __ | Should -Be $greedyMatch.Length
        }

        It 'behaves differently depending on whether or not qualifiers are greedy' {
            $greedy = 'o+'
            $lazy = 'o+?'
            @([regex]::Matches('helloooooo', $____).Value)[0] | Should -Be 'o'
            @([regex]::Matches('helloooooo', $____).Value)[0] | Should -Be 'oooooo'
        }
    }
}

Describe 'Special Symbols' {
    <#
        In regex, there are far more symbols with unique meanings than just quantifiers. What comes
        next is not a definitive guide to EVERY SINGLE ONE, but rather an introduction to some of
        the most common and useful special symbols in regex.

        This is ^\where things st\Art getting \weir\D$
    #>


    Context '. (period)' {

        It 'matches any character' {
            # The . (period) matches literally any character

            $____ | Should -Be ('Lazy Sunday mornings' -match 'S.nday')
        }

        It 'starts looking kind of weird now' {
            '____' -match 'invi.a.ion' | Should -BeTrue
        }
    }

    Context '\n' {

        It 'matches new lines' {
            <#
                The \n symbol is the first regex symbol you've encountered that isn't just a single
                character. Normally if you saw a lowercase "n" in a regex, it would just mean
                "literally the letter n". When it's preceded by a backslash, however, that "n" takes
                on a special meaning. In this case, \n matches new lines. Actually, it matches the
                encoded character that indicates a new line.

                There are many more regex symbols that are single letters preceded by a backslash.
                In fact, the backslash is probably the single most important character in all of
                regex.
            #>

            $multiLine = @"
They might look
similar and look
soft, but you should
never confuse a
wild cougar for
a domestic cat
"@
            $catPattern = '____\n'
            $multiLine -match $catPattern | Should -BeTrue
        }
    }

    Context '\d and \D' {
        <#
            The \d symbol matches digits (the numbers 0 - 9 inclusive), while the symbol \D
            matches anything OTHER THAN a digit. Yes, regular expressions are case sensitive.
            This "lower case for affirmative, upper case for negative" pattern is common among
            regex symbols as you'll discover as you carry on.
        #>

        It 'matches digits' {
            '__' -match '\d' | Should -BeTrue
        }

        It 'can require more than one occurence in a row' {
            '__' -match '\d\d\d' | Should -BeTrue
        }

        It 'matches things that are NOT digits' {
            '__' -match '\D' | Should -BeTrue
        }
    }

    Context '\w and \W' {

        It 'matches (non-)word characters' {
            <#
                \w matches word characters which are letters, numbers, and underscores. The \W
                symbol matches anything else.

                For these challenges, make sure you're using either \w or \W in your regular
                expression. Otherwise, you're just cheating yourself!
            #>
            '***' -match '__' | Should -BeTrue
        }

        It 'sees only word characters in here' {
            'warmth' -match '__' | Should -BeTrue
        }
    }

    Context '^ (caret) and $ (dollar sign)' {

        It 'matches the start of lines with ^' {
            $caretMatch = '____'
            $caretMatch -match '^a' | Should -BeTrue
        }

        It 'matches the end of lines with $' {
            $dollarMatch = '____'
            $dollarMatch -match 'z$' | Should -BeTrue
        }
    }

    Context '\s and \S' {

        It 'matches (non-) whitespace characters' {
            <#
                \s matches whitespace characters (space, tab, etc.) while \S matches anything other
                than whitespace
            #>

            # Enter either \s or \S - which do you think will work?
            'Room to grow' -match '__' | Should -BeTrue
        }

        It 'matches what you cannot see' {
            # Careful to only fill in a value for the '____', not the '    '
            '    ' -match '__' | Should -BeFalse
        }

        It 'is hard to see, but not that hard' {
            $____ | Should -Be ('valentine' -match '\s')
        }
    }

    Context 'The Great Escape' {

        It 'escapes other special symbols' {
            <#
                As you know now, the backslash is basically a magic regex wand that gives some
                normal characters special meanings. It does more than that, though. The backslash
                can also take special meaning away from characters, even itself. The process of
                removing the special meaning from a letter in regex is called "escaping".
            #>

            # Escape the period character to match a literal period instead of "any character"
            'This . character means something else in regex' -match '\.' | Should -BeTrue
            $matches[0] | Should -Be '____'

            $dollarValue = 'The price is $4.99.'
            $dollarMatch = '____'
            [regex]::Matches($dollarValue, $dollarMatch).Value | Should -Be '$4.99'
        }

        It 'is needed when working with UNC paths and more' {
            $slashPath = '\\path\with\slashes'
            $slashPattern = '____'
            [regex]::Matches($slashPath, $slashPattern).Value | Should -Be '\slashes'
        }
    }
}

Describe 'Brackets and Braces' {
    <#
        Brackets and braces don't have one overarching purpose in regular expressions. Different
        types of brackets and braces all mean different things. Sometimes other regex symbols
        meanings change when they're found inside some brackets or braces.
    #>

    Context '{ and } - Curly Braces' {

        It 'works like a custom quantifier' {
            <#
                Curly braces are effectively customizable quantifiers. The star, plus, and question
                mark quantifiers from earlier are static in their meaning. Star always means "zero
                or more", question mark always means "one or zero", and plus always means "one or
                more". Those cover tons of use cases and examples, but there are plenty more
                situations where you want to be more specific.
            #>

            <#
                The portion of this regex in curly braces acts as a quantifier for the symbol that
                comes immediately before it. It means "exactly 4 digits."
            #>
            'I can count to 1024' -match '\d{4}' | Should -BeTrue
            $matches[0] | Should -Be '____'
        }

        It 'is very specific' {
            '____' -match '\w{10}' | Should -BeFalse
            '____' -match '\w{10}' | Should -BeTrue
        }

        It 'can work with ranges' {
            <#
                One can use curly braces to give a range of numbers. This one means "between 2 and 4
                of any character"
            #>
            $____ | Should -Be ('Paper airplane' -match '.{2,4}')
        }

        It 'checks for double letters' {
            $fruitMatch = 'p____'
            [regex]::Matches('Apples', $fruitMatch).Value | Should -Be 'pp'
            $fruitMatch.Contains('}') | Should -BeTrue     # Make sure you use curly braces!
        }

        It 'does not need two numbers, even with a comma' {
            <#
                If you omit the second number, the custom quantifier becomes "this many or more".
                This one means "two or more non-whitespace characters"
            #>
            $____ | Should -Be ('The moon in June is a big balloon' -match '\s{2,}')
        }

        It 'can work a lot like the quantifiers you already know and love' {
            <#
                Excitingly, you already know about some of the quantifiers that exist in regex.
                Since the curly braces allow you to create custom quantifications, you should
                therefore be able to reproduce the function of the standard *, +, and ?
                quantifiers using curly braces.
            #>

            $grass = 'Teeny blades of grass'

            $plusGrassPattern = 'e+'
            $plusGrassMatch = [regex]::Matches($grass, $plusGrassPattern).Value[0]

            $customGrassPattern = 'e{__}'
            $customGrassMatch = [regex]::Matches($grass, $customGrassPattern).Value[0]

            $customGrassMatch | Should -Be $plusGrassMatch
            $customGrassPattern.Contains('}') | Should -BeTrue # Use the curly braces!
        }
    }

    Context '( and ) - Round Braces' {

        It 'groups patterns together' {
            <#
                Round brackets are used to create groups of symbols. These groups can then have
                quantifiers applied to the entire group, or be used in approximately 42 trillion
                other ways. This is just the tip of the round bracket/regular expression groups
                iceberg.
            #>

            '____' | Should -Be ([regex]::Matches('Bears Beat Bongos', '(B.+){3}').Value)
        }

        It 'does not find just one badger' {
            $badgers = 'BadgerBadgerBadger'
            $groupingPattern = '(____){__}'
            [regex]::Matches($badgers, $groupingPattern).Value | Should -Be 'BadgerBadgerBadger'
            $groupingPattern.Contains(')') | Should -BeTrue    # Use a group!
        }
    }

    Context '[ and ] - Square Brackets' {

        It 'defines a set' {
            <#
                Square brackets denote a set or collection of symbols within a regular
                expression. Imagine a pattern that might read "a or b or c or d". You may use square
                brackets to create that regex. The set contained within the square brackets
                represent one charactermwithin the string being searched.

                The fancy regex name for this is a "character class".
            #>

            $____ | Should -Be ('End of the line' -match '[efg]$')
        }

        It 'wants you to end the string a certain way' {
            '____' -match '[abcdefg]$' | Should -BeTrue
        }

        It 'wants you to avoid ending the string a certain way' {
            <#
                Normally, the ^ character means "start of a line", but inside of square brackets, it
                negates the set. Instead of "these symbols" it means "not these symbols"
            #>
            '____' -match '[^abcdefg]$' | Should -BeTrue
        }

        It 'still needs to match a ^ inside a set' {
            <#
                What do you think you might do if you want to match a literal ^ symbol within a set?
                Use the ^ (caret) symbol in this one.
            #>
            $caretMatch = '[____]'
            '^&*' -match $caretMatch | Should -BeTrue
            $caretMatch.Contains('^') | Should -BeTrue # Use the caret symbol!
        }
    }
}

Describe 'Meditative Examples' {
    # Here are some challenges for you to put your new skills to work on.

    Context 'Isolate a Username From a domain\username String Using Just One Regex Pattern' {

        It 'is handy for isolating parts of strings' {
            $usernamePattern = '____'
            [regex]::Matches('cat\harley', $usernamePattern).Value | Should -Be 'harley'
            [regex]::Matches('cat\kali', $usernamePattern).Value | Should -Be 'kali'
            [regex]::Matches('human\thomas', $usernamePattern).Value | Should -Be 'thomas'
        }
    }

    Context 'Validate a Bunch of Phone Numbers' {

        <#
            Validate a bunch of phone numbers - get rid of the non-numeric characters and check
            which ones are actually the right length to be dialed.
        #>
        BeforeAll {
            $script:phoneNumbers = @(
                '1 425 555 1234'
                '1-425-555-4321'
                '1.425.555.6789'
                '01234'
                '+14255556789'
            )

            $script:sanitizedNumbers = @(
                '14255551234'
                '14255554321'
                '14255556789'
                '01234'
                '14255556789'
            )
        }

        It 'sanitizes user input' {

            $phoneNumbers -replace '____' | Should -Be $sanitizedNumbers
        }

        It 'validates user input' {
            $validPhoneNumbers = [regex]::Matches($sanitizedNumbers, '____').Value
            $validPhoneNumbers | Should -Be @(
                '14255551234'
                '14255554321'
                '14255556789'
                '14255556789'
            )
        }
    }
}
