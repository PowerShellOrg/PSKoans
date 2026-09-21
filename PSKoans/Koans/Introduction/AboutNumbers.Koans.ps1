using module PSKoans
[Koan(Position = 103)]
param()
<#
    Numbers

    In PowerShell, we can use several different data types to represent numbers.
    Which type is used depends on what you need. The two most common types are:
    - Integers
        Integers represent whole numbers. This is the default numeric data type
        that PowerShell uses for numbers that don't include a decimal portion.
    - Doubles
        Doubles are typically numbers which include decimal places or exponents.
        This is the default numeric type that PowerShell will use for numbers
        specified with decimal places or exponents, for example:
        - 0.5
        - 2e3

    So 10 will be an integer and 10.0 will be a double, unless a specific type
    is applied either with a type suffix or a cast, which will be covered in
    more detail in a later topic. The examples below display some of the
    differences inherent to the numeric types.
#>

Describe 'Basic Number Types' {

    Context 'Double' {

        BeforeAll {
            $script:Int = 10
            $script:Double = 10.0
        }

        It 'has a specific object type for integers' {
            'System.____' | Should -Be $Int.GetType().Fullname
        }

        It 'has a specific object type for doubles' {
            'System.____' | Should -Be $Double.GetType().Fullname
        }

        It 'can result from mathematical operations with other number types' {
            <#
                When doing arithmetic on different types of numbers, PowerShell
                will automatically convert the less precise or more narrow type
                to the other kind.
            #>

            $Result = $Int * $Double

            # What type results when you multiply integers and doubles?
            'System.____' | Should -Be $Result.GetType().Fullname
        }
    }

    Context 'Integers' {

        It 'has to be a whole number' {
            function Get-Number {
                param(
                    [Parameter(Mandatory)]
                    [int]
                    $Number
                )
                $Number
            }

            $Pi = [Math]::PI

            'System.____' | Should -be $Pi.GetType().Fullname
            # What number will return if you pass Pi into an int function?
            ___ | Should -Be (Get-Number -Number $Pi)
        }

        It 'can be a larger number if needed' {
            <#
                Integers come in two flavours:
                - int (Int32)
                - long (Int64)

                If an integer value exceeds the limits of the Int32 type, it is
                automatically expanded to the larger Int64 type.
            #>

            # What exactly are the limitations of the [int] type?
            $MaxValue = [int]::MaxValue
            $MinValue = [int]::MinValue

            __ | Should -Be $MaxValue
            __ | Should -Be $MinValue

            # If you enter a number larger than that, the type should change.
            $BigValue = __
            $BigValue | Should -BeOfType [long]
            $BigValue | Should -BeGreaterThan $MaxValue

            $SmallValue = __
            $SmallValue | Should -BeOfType [long]
            $SmallValue | Should -BeLessThan $MinValue
        }

        It 'allows you to request the larger type with a suffix' {
            <#
                By specifying the L suffix, a number is forced to use the long
                type. There are more suffixes available, depending on your
                PowerShell version. We'll cover those in a later topic.
            #>

            100L | Should -BeOfType [long]

            $Value = __
            $Value | Should -BeOfType [long]
            [int]::MinValue -le $Value -and $Value -le [int]::MaxValue | Should -BeTrue
        }
    }
}

Describe "Banker's Rounding" {
    <#
        The default midpoint rounding method used in PowerShell is called
        "Rounding to Even," or "Banker's Rounding". Numbers will be rounded to
        the nearest even integer when rounding from a midpoint (###.5) value.

        This behaviour stems from the underlying library method [math]::Round()
        which is documented in more detail here:
        https://docs.microsoft.com/en-us/dotnet/api/system.math.round#midpoint-values-and-rounding-conventions

        Alternate overloads of the Round() method are also available if you need
        to adjust the midpoint rounding method used for a particular use case.
    #>

    It 'rounds to the nearest even when cast to integer if it is a midpoint' {
        # How will these numbers be rounded to integer?
        ____ | Should -Be ([int]2.5)
        ____ | Should -Be ([int]3.34)
        ____ | Should -Be ([int]12.7)

        ____ | Should -Be ([long]10.61)
        ____ | Should -Be ([long]5.5)
    }
}
