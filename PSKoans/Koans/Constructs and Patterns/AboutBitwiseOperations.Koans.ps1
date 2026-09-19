using module PSKoans
[Koan(Position = 309)]
param()
<#
    Binary

    Binary is introduced in the AboutBinary topic. This topic extends on AboutBinary, exploring different binary operations
    and more complex scenarios.

    PowerShell includes a number of operators which can be used to perform binary or bitwise operations.

     * band
     * bor
     * bxor
     * bnot
     * shl
     * shr
#>
Describe 'Binary Operators' {
    BeforeAll {
        <#
            PowerShell can use the .NET [Convert] type to change a binary string into a numeric
            value.

            The [Convert]::ToByte($String, $Base) method is used to change the value into a byte. The method
            used here has two arguments:

                1. The value to convert, a string.
                2. The base of the number, 2 for binary.

            The [Convert] type contains other methods for converting to different
            numeric types. These can be explored using Get-Member.

                [Convert] | Get-Member -Static

            The function below is used in the Koans tasks that follow.
        #>
        function ConvertFrom-Binary {
            [CmdletBinding()]
            [OutputType([string], [byte], [sbyte], [int16], [int32], [int64])]
            param (
                # The binary string to convert.
                [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
                [String]
                $BinaryString,

                # Convert the binary string to this.
                [String]
                $To = 'Byte'
            )

            process {
                if ($BinaryString -match '_') {
                    return 'Cannot convert this value!'
                }

                if ($To -ne 'ASCIIString') {
                    $BinaryString = $BinaryString -replace ' '
                }

                switch ($To) {
                    'Byte'         { [Convert]::ToByte($BinaryString, 2) }
                    'SByte'        { [Convert]::ToSByte($BinaryString, 2) }
                    'Int16'        { [Convert]::ToInt16($BinaryString, 2) }
                    'Int32'        { [Convert]::ToInt32($BinaryString, 2) }
                    'Int64'        { [Convert]::ToInt64($BinaryString, 2) }
                    'ASCIIString'  {
                        [Char[]]$characters = foreach ($value in $BinaryString -split ' ') {
                            [Convert]::ToByte($value, 2)
                        }
                        [String]::new($characters)
                    }
                    default  { throw "Sorry, I do not know how to convert to $To" }
                }
            }
        }
    }

    Context 'Bytes' {
        It 'A byte is made up of 8 bits' {
            <#
                Each bit can be set to either 0 or and each has a value based
                on its position.

                The most significant bit, the largest value, is first. The least
                significant bit, the smallest value, is last.

                    Bit position      Value
                    ------------      -----
                               1        128
                               2         64
                               3         32
                               4         16
                               5          8
                               6          4
                               7          2
                               8          1

                This order is known as Big Endian.
            #>

            '00000001' | ConvertFrom-Binary | Should -Be 1      # Least significant
            '________' | ConvertFrom-Binary | Should -Be 2
            '00000100' | ConvertFrom-Binary | Should -Be 4
            '________' | ConvertFrom-Binary | Should -Be 8
            '________' | ConvertFrom-Binary | Should -Be 16
            '00100000' | ConvertFrom-Binary | Should -Be 32
            '01000000' | ConvertFrom-Binary | Should -Be 64
            '________' | ConvertFrom-Binary | Should -Be 128    # Most significant
        }

        It 'can be used to create a larger number' {
            <#
                The bits that make up a byte can be used to make any number between 0 and 255.
                Each of the bits set to one is added together.
            #>

            '0000____' | ConvertFrom-Binary | Should -Be (1 + 4 + 8)
        }

        It 'can describe any byte, between 0 and 255, value using 8 bits' {
            # If more than one bit is set, the values are added together.

            '11000000' | ConvertFrom-Binary | Should -Be 192
            '________' | ConvertFrom-Binary | Should -Be 133
        }

        It 'ignores leading zeros' {
            # Leading zeros do not effect the value.

            $WithLeadingZeros = '00000100' | ConvertFrom-Binary
            $WithoutLeadingZeros = '100' | ConvertFrom-Binary

            $WithoutLeadingZeros | Should -Be $WithLeadingZeros

            $BinaryValue = '_____'

            $BinaryValue | ConvertFrom-Binary | Should -Be 16
            $BinaryValue.Length | Should -BeLessThan 8
        }
    }

    Context 'Int16, Int32, and Int64' {
        # Larger integer types, such as Int32, are made up of several bytes.

        It 'uses mulitple bytes to describe a larger integers' {
            '00010100 00000001' | ConvertFrom-Binary -To Int16 | Should -BeOfType [Int16]
            '01000000 00000100 00000010 00110001' | ConvertFrom-Binary -To Int32 | Should -BeOfType [Int32]
        }
    }

    Context 'About bitwise AND (-band)' {
        <#
            Bitwise AND compares each bit of two values. If a bit is 1 in both values, the bit in the result is 1.
            Otherwise the bit in the result is 0.

                Value 1  | 0 | 1 | 0 | 1 | # 5
                Value 2  | 1 | 1 | 0 | 0 | # 12
                ---------+---+---+---+---+
                Result   | 0 | 1 | 0 | 0 | # 4
        #>

        It 'is easy to read when the value is written in binary' {
            $Value1 = '00000010' | ConvertFrom-Binary
            $Value2 = '00000110' | ConvertFrom-Binary

            '________' | ConvertFrom-Binary | Should -Be ($Value1 -band $Value2)
        }

        It 'compares the bits of two different values, returning those common to both' {
            __ | Should -Be (4 -band 12)
        }
    }

    Context 'About bitwise OR (-bor)' {
        <#
            Bitwise OR compares each bit of two values. If a bit is 1 in either value, the bit in the result is 1.
            Otherwise the bit in the result is 0.

                Value 1  | 0 | 1 | 0 | 1 | # 5
                Value 2  | 1 | 1 | 0 | 0 | # 12
                ---------+---+---+---+---+
                Result   | 1 | 1 | 0 | 1 | # 13
        #>

        It 'is easy read when the value is written in binary' {
            $Value1 = '00000011' | ConvertFrom-Binary # 3
            $Value2 = '00001110' | ConvertFrom-Binary # 14

            '________' | ConvertFrom-Binary | Should -Be ($Value1 -bor $Value2)
        }

        It 'compares the bits of two different values, returning the bits set in either value' {
            __ | Should -Be (3 -bor 14)
        }
    }

    Context 'About bitwise NOT (-bnot)' {
        <#
            The bitwise NOT operator inverts the bits in a value.

                Value  | 0 | 1 | 0 | 1 |
                -------+---+---+---+---+
                Result | 1 | 0 | 1 | 0 |

            The operation performed by bitwise NOT is also known as a One's Complement.
        #>

        It 'inverts the bits in a value' {
            $Value = '00000011' | ConvertFrom-Binary
            $Result = '________' | ConvertFrom-Binary

            <#
                The binary operators will, when given smaller value return a 32-bit integer. GetType can show this:

                    (-bnot $Value).GetType()

                This can make the result of the operation below confusing. When written in binary, the result is
                similar to:

                    11111111 11111111 11111111 ________

                -band can be used to mask the result, limiting the possible result to a single byte.

                      11111111 11111111 11111111 ________
                -band 00000000 00000000 00000000 11111111
            #>

            -bnot $Value -band 255 | Should -Be $Result
        }
    }

    Context 'About bitwise exclusive OR (-bxor)' {
        <#
            Bitwise exclusive OR compares each bit in two values. If a bit is 1 in one, but not both, of the values, the bit
            in the result is 1. Otherwise the bit in the result is 0.

                Value 1  | 0 | 1 | 0 | 1 |
                Value 2  | 1 | 1 | 0 | 0 |
                ---------+---+---+---+---+
                Result   | 1 | 0 | 0 | 1 |
        #>

        It 'gets a value where one, but not both, bits are set' {
            $Value1 = '10000011' | ConvertFrom-Binary
            $Value2 = '00001110' | ConvertFrom-Binary
            $Result = '________' | ConvertFrom-Binary

            $Value1 -bxor $Value2 | Should -Be $Result
        }
    }

    Context 'About shift' {
        <#
            The bits that make up a value can be shifted to the left or right.
            This changes the value depending on the direction of the shift.
        #>

        It 'allows bits to shift to the left' {
            <#
                The example below shows the result of a shift one bit to the left.

                    Value  | 0 | 0 | 1 | 1 |   # 3
                    -------+---+---+---+---+
                    Result | 0 | 1 | 1 | 0 |   # 6

                Each bit to the left doubles the value.
            #>

            __ -shl 2 | Should -Be 8
        }

        It 'allows bits to shift to the right' {
            <#
                The example below shows the result of a shift one bit to the right.

                    Value  | 1 | 1 | 0 | 0 |   # 12
                    -------+---+---+---+---+
                    Result | 0 | 1 | 1 | 0 |   # 6

                Each bit to the right halves the value.
            #>

            __ -shr 2 | Should -Be 2
        }

        It 'loses bits when shifting outside of the range of the type when shifting left' {
            <#
                When a shift operation pushes bits outside of the range of a numeric type
                those bits are discarded.

                A byte is made 8 bits with a maximum value of 255. In binary, 128 is the
                highest order bit:

                    Binary | 10000000
                    -------+---------
                    Byte   | 128

                When [Byte]128 is shifted one bit to the left the result is 0. A Byte cannot hold a value
                greater than 255.
            #>

            0 | Should -Be ([Byte]128 -shl 1)
            __ | Should -Be ([Byte]224 -shl 2)
        }

        It 'can be used with casting to create a larger number' {
            # If the value is cast to a larger numeric type, the left shift operation will succeed.

            $Byte = [Byte]128

            $Shift = __
            $Byte -shl $Shift | Should -Be 0
            [Int]$Byte -shl $Shift | Should -Be 512
        }

        It 'loses bits when shifting outside of the range of the type when shifting right' {
            <#
                Bits will fall out of scope when shifting to the right in a similar manner as shifting left.

                When a Byte has the value 1, and the value is shifted one bit to the right the result is 0.

                Shifting the lowest order bit of a numeric value to the right will always result in 0.

                    Byte  | 00000001
                    Int16 | 00000000 00000001
                    Int32 | 00000000 00000000 00000000 00000001
            #>

            1 | Should -Be (3 -shr 1)
            __ | Should -Be (7 -shr 1)
        }

        It 'can be used to create larger values from a sequence of bytes' {
            <#
                A 32-bit integer can be made up of four bytes.

                When creating a larger value from a sequence of bytes, each byte is shifted to the left based
                on its position. In the case of an integer, the most significant byte is shifted 24 bits to the
                left (3 * 8).

                The most significant byte is first, the bytes below are in Big Endian order.


                    Binary            | 00010110  | 00111000 | 11000000 | 00001111 |
                    ------------------+-----------+----------+----------+----------+
                    Byte Value        | 22        | 56       | 192      | 15       |
                    ------------------+-----------+----------+----------+----------+
                    Bitwise operation | -shl 24   | -shl 16  | -shl 8   |          |
                    ------------------+----------=+----------+----------+----------+
                    Int32 Value       | 369098752 | 3670016  | 49152    | 15       |

                The final Int32 value, 372817935, is obtained by adding each of the individual pieces together.
            #>

            # Hint: set one bit for each value
            $BinaryValues = '________', '________', '________', '________'

            $Bytes = $BinaryValues | ConvertFrom-Binary

            [Int]$Bytes[0] -shl 24 | Should -Be 1073741824
            [Int]$Bytes[1] -shl 16 | Should -Be 2097152
            [Int]$Bytes[2] -shl 8 | Should -Be 4096
            $Bytes[3] | Should -Be 8

            $Value = @(
                [Int]$Bytes[0] -shl 24
                [Int]$Bytes[1] -shl 16
                [Int]$Bytes[2] -shl 8
                $Bytes[3]
            ) | Measure-Object -Sum

            $Value.Sum | Should -Be 1075843080
            -join $BinaryValues | ConvertFrom-Binary -To Int32 | Should -Be $Value.Sum
        }
    }


    Context 'About the signing bit' {
        <#
            A byte is an example of an unsigned integer. The values can range from 0 to 255, the value cannot
            be a negative number.

            Signed integers reserve a single bit to denote whether the value is positive or negative.
            When the value of the signing bit is 0, the value is positive. When the value is 1, the value is
            negative.

            The signing bit takes the place of the most significant bit.

                    Bit position      Value
                    ------------      -----
                               1      Signing bit
                               2      64
                               3      32
                               4      16
                               5      8
                               6      4
                               7      2
                               8      1

            This value is known as SByte, or signed byte. The signed byte allows numbers in the range -128 to 127.

            In .NET, SByte, Int16, Int32, and Int64 are all signed integers. Byte, UInt16, UInt32, and UInt64 are all
            unsigned integers.
        #>

        It 'allows positive values to be expressed in the same way as an unsigned integer' {
            # Positive values do not use the signing bit.

            '0_______' | ConvertFrom-Binary -To SByte | Should -Be (1 + 4 + 8)
        }

        It 'uses the most significant bit to describe a negative number' {
            # When the signing bit alone is set, the value is the smallest value, -128.

            '10000000' | ConvertFrom-Binary -To SByte | Should -Be (-128)

            # The opposite binary value is the maximum positive value for the number.

            '01111111' | ConvertFrom-Binary -To SByte | Should -Be 127

            # When the signing bit is set, each value adds to the minimum.

            '10000001' | ConvertFrom-Binary -To SByte | Should -Be (-128 + 1)
            '10000010' | ConvertFrom-Binary -To SByte | Should -Be (-128 + 2)
            '1_______' | ConvertFrom-Binary -To SByte | Should -Be (-128 + 4)
            '1_______' | ConvertFrom-Binary -To SByte | Should -Be (-128 + 8)
        }

        It 'can use -shl to create a negative number from a positive number' {
            $Value = '00100001' | ConvertFrom-Binary -To SByte

            $Value | Should -Be 33

            $Shift = __
            $Value -shl $Shift | Should -Be -124
        }
    }

    Context 'A matter of perspective' {
        It 'a binary string can be used to represent different numeric values' {
            # The number it represents can depend on the numeric type used.

            $BinaryValue = '________'

            $BinaryValue | ConvertFrom-Binary -To Byte | Should -Be 225
            $BinaryValue | ConvertFrom-Binary -To SByte | Should -Be -31

            <#
                As the signing bit is always the least significant, converting the 8 bit
                binary value above to a larger type, such as, Int32 will create a positive value.
            #>

            $BinaryValue | ConvertFrom-Binary -To Int32 | Should -Be 225
        }

        It 'the value might be a number, or it might be a string, or something else' {
            <#
                A larger numeric value can be created from a series of bytes. The bytes are shifted to the left based
                on their position to create the number.
            #>

            $BinaryValue = '________ ________ ________ ________'

            $BinaryValue | ConvertFrom-Binary -To Int32 | Should -Be 1652126821

            <#
                The bytes might also be used to represent a string.

                A string value depends on the encoding used. ASCII and UTF8 both use one byte for each character.
                Unicode uses two bytes to represent each character. UTF32 uses 4 bytes for each character, and so on.

                In this case, each byte is considered to be a value from the ASCII character table.
            #>

            $BinaryValue | ConvertFrom-Binary -To ASCIIString | Should -Be 'byte'

            # The byte sequence might represent something else still. For instance, it might be an IP address.

            [Byte[]]$bytes = $BinaryValue -split ' ' | ConvertFrom-Binary
            [IPAddress]::new($bytes) | Should -Be '98.121.116.101'

            # It could be a date, although the date is less likely in this case.

            $Date = [DateTime]::FromFileTime(($BinaryValue | ConvertFrom-Binary -To Int64))

            $Date.ToString('dd MMMM yyyy HH:mm:ss') | Should -Be '01 January 1601 00:02:45'
        }
    }

    Context 'Perspective and Endianness' {
        <#
            Big Endian and Little Endian are terms used to describe the order of of the bits
            or bytes in a binary value.

            If a value is Big Endian, the largest value, the "big end", is first.

            If a value is Little Endian, the largest value is last.

            The endian order returned by the .NET types used below is dependent on the processor architecture.
            Most modern systems use Little Endian ordering.

            The section below assumes the processor and operating system are Little Endian.
        #>

        It 'might use a different byte order' {
            # The significance assigned to each bit can dramatically change the value.

            $BinaryValue = '________ ________ ________ ________'

            # The value below is the result if the binary string is considered to be Big Endian.

            $BinaryValue | ConvertFrom-Binary -To Int32 | Should -Be 1652126821
            $BinaryValue | ConvertFrom-Binary -To ASCIIString | Should -Be 'byte'

            # This can be explored forindividual bytes, by setting all others to 0. For example:

            '________ 00000000 00000000 00000000' | ConvertFrom-Binary -To Int32 | Should -Be 1644167168
            '00000000 00000000 00000000 ________' | ConvertFrom-Binary -To Int32 | Should -Be 101

            <#
                The Convert type used to change the value from a binary string expects the order
                to be Big Endian.

                The command below takes the binary string and turns it into an array of bytes. Because the string
                is in Big Endian order the bytes will be too.
            #>

            $Bytes = $BinaryValue -split ' ' | ConvertFrom-Binary

            <#
                The BitConverter type has a number of static methods which can be used to create a value from a
                series of bytes.

                BitConverter expects bytes to be in Little Endian order.
            #>

            [BitConverter]::ToInt32($Bytes, 0) | Should -Be 1702132066

            #  To produce the same value as the original the array of bytes must be reversed.

            [Array]::Reverse($Bytes)
            [BitConverter]::ToInt32($Bytes, 0) | Should -Be 1652126821
        }

        It 'The IPAddress type can be used to change the order of a byte sequence' {
            <#
                Many values in network packets are transmitted in Big Endian order. An IP address, for example, is
                transmitted as a single unsigned 32-bit integer.

                An operating system might need to convert from Big Endian to Little Endian, or from
                Little Endian to Big Endian.

                The IPAddress type has two static methods available to change the Endian order of a value.

                    [IPAddress] | Get-Member -Static

                In PowerShell Core, the System.Buffers.Binary.BinaryPrimitives type offers more functionality.

                    [System.Buffers.Binary.BinaryPrimitives] | Get-Member -Static
            #>

            $Value = __

            [IPAddress]::HostToNetworkOrder($value) | Should -Be 1702132066

            # As the operation reverses a byte array, repeating the operation will return the original value.

            [IPAddress]::HostToNetworkOrder(1702132066) | Should -Be $value

            <#
                The IP address class has a second method, NetworkToHostOrder. This behaves in exactly
                the same way as HostToNetworkOrder.
            #>

            [IPAddress]::NetworkToHostOrder($value) | Should -Be 1702132066
        }
    }
}
