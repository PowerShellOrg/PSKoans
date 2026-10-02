using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseShouldProcessForStateChangingFunctions',
    '',
    Justification = 'New-Enumeration is a minimal in-exercise example defining an enum in a nested scope; it has no real side effects to guard with ShouldProcess.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseUsingScopeModifierInNewRunspaces',
    '',
    Justification = '$Type is Get-Objects own function parameter declared inside the Start-Job scriptblock, not a captured outer-scope variable; $using: does not apply.'
)]
[Koan(Position = 310)]
param()
<#
    About Enumerations

    Enumerations, or Enums, are used to give names to lists of constant values.
    Enumerations are very widely used in the .NET framework and frequently
    encountered in PowerShell.

    Examples in this topic use Start-Job to avoid problems when continually
    loading a type in the current PowerShell session. Enumeration values
    demonstrated in this section are cast to String within the jobs, otherwise
    PowerShell will return only the numeric value from the job.
#>
Describe 'About Enumerations' {
    <#
        The DayOfWeek enumeration (enum) which holds values describing the days
        of the week is a simple example of an existing .NET enumeration.
    #>

    Context 'Using Enumerations' {
        It 'exposes the values of an enumeration in a number of different ways' {
            <#
                The most direct way to refer to enumeration values is with the
                static member access operator.

                If Strict Mode (Set-StrictMode) has been enabled, accessing a
                non-existent value will raise an error.
            #>

            [DayOfWeek]::____ | Should -BeOfType [DayOfWeek]

            <#
                We can also cast a string to the enumeration type.

                Casting to a non-existent value always raises an error.
            #>

            { [DayOfWeek]'____' } | Should -Not -Throw

            <#
                We can also use the -as operator to do a "safe cast" to the
                enumeration type.

                Using -as with a non-existent value will simply return $null.
            #>

            '____' -as [DayOfWeek] | Should -BeOfType [DayOfWeek]
        }

        It 'will find a match from a partial name if it can' {
            <#
                PowerShell will match an enum value based on a partial name.
                The name used must match a unique value in the enum.

                Try making Name less than the whole word.
            #>

            $Name = '____'

            $Name | Should -Not -Be 'Monday'
            $Name -as [DayOfWeek] | Should -Be 'Monday'

            <#
                Using -as with a non-unique value will simply return $null.
                Casting to a non-unique value will raise an error.
            #>

            $ExpectedError = '____'

            { [DayOfWeek]'T' } | Should -Throw -ExpectedMessage $ExpectedError
        }

        It 'can retrieve all names in an enumeration with the GetEnumNames method' {
            $daysOfWeek = @('____', '____', '____', '____', '____', '____', '____')

            $daysOfWeek | Should -Be ([DayOfWeek].GetEnumNames())

            # The [Enum] type has another method of getting the same data.

            [Enum]::GetNames([DayOfWeek]) | Should -Be $daysOfWeek
        }

        It 'has a numeric value associated with each name' {
            <#
                In the DayOfWeek enumeration, Sunday has the value 0, and Monday
                has the value 1, and so on.

                The underlying value is accessible by casting to a numeric type:

                    [Int][DayOfWeek]::Sunday

                Or by accessing the value__ property:

                    [DayOfWeek]::Sunday.value__

                A value from the enumeration can be compared to a number without
                casting or directly accessing the value__ property.
            #>

            [DayOfWeek]::Sunday | Should -Be 0
            [DayOfWeek]::____ | Should -Be 2
        }

        It 'can retrieve the list of possible values using the GetEnumValues method' {
            <#
                The values of an enumeration are displayed in much the same way
                as the name, with one important difference:
                - GetEnumNames() returns an array of strings, the names of the
                    values only.
                - GetEnumValues() returns an array of values, which will be
                    presented as the names.
            #>

            [DayOfWeek].GetEnumValues() | Select-Object -First 1 | Should -BeOfType [DayOfWeek]
        }

        It 'has a numeric type backing each enumeration type' {
            <#
                Enumerations in the .NET framework, for example those created in
                languages such as C#, can be of any numeric type.

                The type can be found using the GetEnumUnderlyingType method.
            #>

            [____] | Should -Be ([DayOfWeek].GetEnumUnderlyingType())

            # Most enums use Int32 as the underlying type, but not all.

            $underlyingType = [System.Security.AccessControl.AceFlags].GetEnumUnderlyingType()
            [____] | Should -Be $underlyingType
        }

        It 'is created using the enum keyword' {
            <#
                In PowerShell enumerations are created using the enum keyword.

                All names in an enumeration have a value behind them. In some
                cases the value may not be important, only the word. The
                simplest of enumerations is a list of words.

                These restrictions apply to the names used in an enumeration:
                - Must start with A-Z, a-z, or _.
                - May contain A-Z, a-z, _, and 0-9.
                - Cannot use other special characters.
            #>

            $enumNames = Start-Job -ScriptBlock {
                enum ColourOfTheRainbow {
                    Red
                    Yellow
                    Pink
                    Green
                    Purple
                    Orange
                    Blue
                }

                [ColourOfTheRainbow].GetEnumNames()
            } | Receive-Job -Wait

            $colours = @(
                '____'
                '____'
                '____'
                '____'
                '____'
                '____'
                '____'
            )

            $enumNames | Should -Be $colours
        }

        It 'can assign specific numeric values to each enumeration value' {
            <#
                Each value in an enumeration can be assigned an explicit value.
                By default values are automatically assigned starting from 0.

                Windows PowerShell only allows the use of Int32 values in an
                enumeration. Any decimal values will be rounded to an integer.
            #>

            $script = {
                enum Number {
                    One = 1
                    Two = 2
                }

                <#
                    Numeric values can be cast or converted to an enumeration
                    value.

                    The $using: syntax allows access to variables from the
                    parent PowerShell session when using Start-Job and
                    Invoke-Command.
                #>

                $using:Value -as [Number] -as [String]
            }

            $Value = 2
            $Name = Start-Job -ScriptBlock $script | Receive-Job -Wait

            '____' | Should -Be $Name

            <#
                Automatic numbering may still be used. Automatic numbering
                continues incrementing from the last value assigned.
            #>

            $script = {
                enum Number {
                    One = 1
                    Two
                    Five = 5
                    Six
                }

                $using:Value -as [Number] -as [Int]
            }

            $Value = 'Six'
            $NumericValue = Start-Job -ScriptBlock $script | Receive-Job -Wait

            __ | Should -Be $NumericValue
        }

        It 'can represent other integer in PowerShell Core' -Skip:($PSVersionTable.PSVersion -lt '6.2.0') {
            <#
                In PowerShell 6.2+, enumerations can be based around types other
                than Int32. The numeric type can be SByte, Byte, Int16, UInt16,
                Int32 (default), UInt32, Int64, and UInt64.

                PowerShell, like C#, uses inheritance-like syntax to express the
                type in use.

                    enum EnumName : NumericType

                Inheritance is explored in the AboutClasses topic.
            #>

            $script = '
                # This number is too large for Int32, Int64 is used instead.

                enum Int64Enum : Int64 {
                    LargeValue = 9223370000000000000
                }

                [Int64Enum]::LargeValue -as [Int64Enum].GetEnumUnderlyingType()
            '

            $ExpectedType = [____]

            Start-Job -ScriptBlock [scriptblock]::Create($script) |
                Receive-Job -Wait |
                Should -BeOfType $ExpectedType

            # Smaller types such as Byte or Int16 can also be used.
        }

        It 'does not require explicit casting to compare values' {
            <#
                In PowerShell the value on the right hand side of a comparison
                operator is coerced into the type of the value on the left hand
                side of an operator.
            #>

            $script = {
                enum Number {
                    One = 1
                    Two = 2
                }

                [Number]1 -eq $using:Name
            }

            $Name = '____'
            Start-Job -ScriptBlock $script | Receive-Job -Wait | Should -BeTrue
        }

        It 'can use the enum type to test if a value exists in the enum' {
            <#
                The Enum type includes two static methods:

                    Parse
                    TryParse

                Parse is normally used to convert a string into an enum value.
                Parse is not required in PowerShell as values can be directly
                cast to the enum type as shown in the first example.

                TryParse returns true if a value was successfully parsed, and
                false otherwise. TryParse expects three arguments:

                1. The enum type.
                2. The string value to parse.
                3. A reference to a variable which can hold the parse
                    result.

                Running [Enum]::TryParse without parentheses will show the
                arguments the method expects.
            #>

            $valueToParse = '____'
            $enumType = [DayOfWeek]
            $parseResult = [DayOfWeek]::Sunday

            $result = if ($PSVersionTable.PSVersion.Major -gt 5) {
                <#
                    .NET Core's TryParse() method (available in PS v6+) can take
                    an explicit type argument. When available, this is a more
                    robust method to work with.
                #>
                [Enum]::TryParse($enumType, $valueToParse, [ref]$parseResult)
            }
            else {
                <#
                    This method still works, but it relies on the [ref] variable
                    already containing a valid enum value from the target type.
                    This is because the method is actually a generic method,
                    and PS has no way to specify a target type, instead being
                    forced to infer the target type from the result variable.
                #>
                [Enum]::TryParse($valueToParse, [ref]$parseResult)
            }

            $result | Should -BeTrue
            $parseResult | Should -Not -Be 'Sunday'
        }
    }

    Context 'About Flags' {
        <#
            The flags attribute can be used to indicate that an enumeration
            represents a series of flags.

            This allows more than one value in the enumeration to be used at
            once.

            .NET makes extensive use of flags based enumerations, from Internet
            security protocols, to file system rights.
        #>

        It 'represents each flag value with a single bit' {
            <#
                A name in the enumeration normally represents a single bit in a
                numeric value.

                PowerShell enumerations use Int32 by default. PowerShell Core
                can use other integer types as demonstrated in the previous
                context.

                32 unique flags can be expressed in an enumeration based on
                Int32. Each value will be double that of the last. Therefore
                expected values are 1, 2, 4, 8, 16, and so on. These are the
                values of individual bits.

                The [Flags()] attribute is placed above the enum keyword.

                The example below is based on 4 different flags.
            #>

            $script = {
                [Flags()]
                enum Bit {
                    None = 0
                    Bit1 = 1
                    Bit2 = 2
                    Bit3 = 4
                    Bit4 = 8
                }

                $using:Value -as [Bit] -as [String]
            }

            $Value = 2
            $Name = Start-Job -ScriptBlock $script | Receive-Job -Wait

            '____' | Should -Be $Name

            <#
                If more than one flag is present, the value returned is a
                comma-separated list.
            #>

            $Value = 2 -bor 8 # 10
            $Name = Start-Job -ScriptBlock $script | Receive-Job -Wait

            '____' | Should -Be $Name
        }

        It 'can represent multiple flag names with a single value' {
            # A list of names can be converted to a single flag value.

            $script = {
                [Flags()]
                enum Bit {
                    None = 0
                    Bit1 = 1
                    Bit2 = 2
                    Bit3 = 4
                    Bit4 = 8
                }

                $using:Names -as [Bit] -as [Int32]
            }

            <#
                The names are a single string with commas separating values,
                not an array. Spaces are discarded when converting the value.
            #>

            $Names = '____, ____'
            $Value = Start-Job -ScriptBlock $script | Receive-Job -Wait

            __ | Should -Be $Value
        }

        It 'allows you to test for the presence of a given flag' {
            <#
                A value which has multiple flags set is provided as a single
                value.

                The presence of individual flag can be tested in either of two
                ways.

                One way is to call the HasFlag() method, which may be called on
                an enumeration value:
            #>

            $script = {
                [Flags()]
                enum Bit {
                    None = 0
                    Bit1 = 1
                    Bit2 = 2
                    Bit3 = 4
                    Bit4 = 8
                }

                $BitValue = [Bit]$using:Value

                $BitValue.HasFlag([Bit]$using:FlagName)
            }

            $Value = 10
            $FlagName = '____'

            Start-Job -ScriptBlock $script | Receive-Job -Wait | Should -BeTrue

            <#
                The bitwise operator, -band, can also be used to test for the
                presence of specific flags as an alternative to the HasFlag
                method.
            #>

            $script = {
                [Flags()]
                enum Bit {
                    None = 0
                    Bit1 = 1
                    Bit2 = 2
                    Bit3 = 4
                    Bit4 = 8
                }

                $BitValue = [Bit]$using:Value

                <#
                    -band will return the result of the bitwise AND; either 0,
                    or the same value as FlagName.
                #>
                ($BitValue -band $using:FlagName) -eq $using:FlagName
            }

            $Value = 10
            $FlagName = '____, ____'

            Start-Job -ScriptBlock $script | Receive-Job -Wait | Should -BeTrue
        }

        It 'can use values representing a combination of flags' {
            <#
                The .NET type System.Security.AccessControl.FileSystemRights
                is a Flags-based enumeration used to represent NTFS access
                rights.

                The enumeration contains several values which are composites of
                several different flags. This technique is used to simplify the
                set of flags, making it easier to understand and use.

                The enumeration below contains two different composite values.
            #>

            $script = {
                [Flags()]
                enum ObjectType {
                    User = 1
                    Group = 2
                    UserAndGroup = 3
                    Computer = 4
                }

                $individualValues = $using:Names -as [ObjectType]
                $compositeValue = $using:CompositeName -as [ObjectType]

                $individualValues -eq $compositeValue
            }

            $CompositeName = '____'
            $Names = 'User, Group'

            Start-Job -ScriptBlock $script | Receive-Job -Wait | Should -BeTrue

            <#
                Individual values that match a composite are automatically
                replaced with the name of the composite value.
            #>

            $script = {
                [Flags()]
                enum ObjectType {
                    User = 1
                    Group = 2
                    UserAndGroup = 3
                    Computer = 4
                }

                $using:Names -as [ObjectType] -as [String]
            }

            $CompositeName = '____, ____'
            $Names = 'User, Group, Computer'

            Start-Job -ScriptBlock $script |
                Receive-Job -Wait |
                Should -Be $CompositeName
        }
    }

    Context 'Enumerations and Parameters' {
        <#
            An enumeration can be used to define the type for a parameter. This
            can be used as an alternative to ValidateSet in some cases.
        #>

        It 'can be used instead of ValidateSet for a parameter' {
            <#
                Using the enumeration as the parameter type will offer
                tab-completion to anyone using the function.
            #>

            $TypeName = Start-Job -ScriptBlock {
                enum ObjectType {
                    User
                    Group
                }

                function Get-Object {
                    [CmdletBinding()]
                    param (
                        [ObjectType]
                        $Type
                    )

                    $Type -as [String]
                }

                Get-Object -Type User
            } | Receive-Job -Wait

            '____' | Should -Be $TypeName
        }

        It 'will raise an error if the parameter value is incorrect' {
            <#
                If an invalid value is supplied, an error will be raised, which
                lists the permitted values.
            #>
            $script = {
                enum ObjectType {
                    User
                    Group
                }

                function Get-Object {
                    [CmdletBinding()]
                    param (
                        [ObjectType]$Type
                    )

                    $Type -as [String]
                }

                Get-Object -Type Computer
            }

            # The error message is long, a partial match is enough.
            $ExpectedError = '____'

            { Start-Job -ScriptBlock $script | Receive-Job -Wait -ErrorAction Stop } |
                Should -Throw -ExpectedMessage $ExpectedError
        }
    }

    Context 'PowerShell Enumeration Scope' {

        It 'creates PowerShell enumerations in the local scope' {
            <#
                Classes and enumerations are resolvable in the scope they are
                created and child scopes. They are not available in parent
                scopes by default.
            #>

            $Values = Start-Job -ScriptBlock {
                enum ObjectType {
                    User
                    Group
                }

                # The enumeration can be used in the current scope

                'User' -as [ObjectType] -as [String]

                function Get-Object {
                    # The enumeration can be used in child scopes

                    'Group' -as [ObjectType] -as [String]
                }

                Get-Object
            } | Receive-Job -Wait

            @('____', '____') | Should -Be $Values
        }

        It 'cannot access enumerations created in child scopes' {
            $script = {
                function New-Enumeration {
                    enum ObjectType {
                        User
                        Group
                    }
                }

                # The enum defined in the function is not available outside it.

                New-Enumeration
                [ObjectType]::User
            }

            $ErrorMessage = '____'

            { Start-Job -ScriptBlock $script | Receive-Job -Wait -ErrorAction Stop } |
                Should -Throw $ErrorMessage
        }

        It 'can import enumerations with using module' {
            <#
                The using module statement can be used at the top of a script to
                make enumerations and classes within a module available in a
                parent scope.
            #>

            $Value = Start-Job -ScriptBlock {
                $modulePath = Join-Path -Path $using:TestDrive -ChildPath 'EnumModule.psm1'

                Set-Content -Path $modulePath -Value @'
                        enum ObjectType {
                            User
                            Group
                        }
'@

                <#
                    Creating a script block avoids a complaint about how using
                    statements must appear first in a script for this example.

                    Ordinarily the path to, or name of, the module would be a
                    fixed value.
                #>

                & ([ScriptBlock]::Create("
                        using module $modulePath

                        'User' -as [ObjectType] -as [String]
                    "))
            } | Receive-Job -Wait

            '____' | Should -Be $Value
        }
    }
}
