using module PSKoans
[Koan(Position = 402)]
param()

<#
    *-Csv Cmdlets

    Storing data from PowerShell is not always simple. The cmdlets best suited to
    store and retrieve any data you need stored to disk will depend on the format
    of the data.

    For uniform collections of objects with fairly simple property types,
    the CSV cmdlets work well, and can create data that is easily imported to
    Microsoft Excel or other spreadsheet applications.

    CSV is short for Comma-Separated Values, and is used to store tabular data.
    Unlike Microsoft Excel workbooks, only a single table can be stored in a file;
    multiple tables are not supported under common CSV definitions, and cannot be
    handled directly by PowerShell's CSV cmdlets without some extra work.
#>

Describe 'CSV Cmdlets' {

    Context 'Export-Csv' {
        <#
            Export-Csv is very handy for quickly storing data as CSV to the local filesystem.
            Objects of any type may be exported as CSV, but all property values are stored as
            string data; keep that in mind when working with complex data types.

            Generally speaking, you cannot export objects of different types to the same CSV file;
            the properties used when exporting the CSV data are determined by the first object the cmdlet
            is given. Attempting to export objects of another type, or those with different properties,
            will usually result in largely empty entries in the CSV file unless the property names happen
            to match.
        #>
        BeforeAll {
            $script:Objects = foreach ($number in 1..5) {
                [PSCustomObject]@{
                    Number = $number
                    Square = $number * $number
                }
            }
        }

        It 'can store object data to a simple CSV text file' {
            <#
                In PowerShell 5.1 and below, converting data to CSV leaves behind a type hint as the
                first line of the file. This type hint is never used, however, so it's generally
                not useful to use; the -NoTypeInformation switch prevents it from being added.
            #>
            $Objects | Export-Csv -Path "$TestDrive/Data.csv" -NoTypeInformation

            $Filename = '____'
            "$TestDrive/$Filename" | Should -Exist
        }

        It 'stores the data accurately' {
            # Now if we read the file as text, let's see what's inside!
            $FileContents = Get-Content -Path "$TestDrive/Data.csv"

            <#
                The headers (first line) will list the property names from the objects in question.
                Each subsequent row of the file corresponds to a single object in the input.
            #>

            $Text = @(
                '"____","____"'
                '"__","__"'
                '"__","__"'
                '"__","__"'
                '"__","__"'
                '"__","__"'
            )
            $Text | Should -BeExactly $FileContents
            <#
                The number value on your first data line should be the same as the first original
                object's number! Note that we're working with a text-based format here, so all
                data is stored as text.
            #>
            $Text[1].Substring(1, 1) -as [int] | Should -Be $Objects[0].Number
        }

        It 'allows you to specify the delimiter' {
            $Delimiter = '_'
            $Path = 'TestDrive:/DelimitedData.csv'

            $Text = @(
                '"Number"?"Square"'
                '"__"?"__"'
                '"__"?"__"'
                '"__"?"__"'
                '"__"?"__"'
                '"__"?"__"'
            )

            $Objects | Export-Csv -Path $Path -Delimiter $Delimiter -NoTypeInformation
            $FileContents = Get-Content -Path $Path
            $Text | Should -BeExactly $FileContents
        }
    }

    Context 'Import-Csv' {
        <#
            Import-Csv is used to import a CSV file and display or work with the data in PowerShell.
            All data will be imported as an array of PSCustomObjects with string properties.
        #>
        BeforeAll {
            $script:Objects = foreach ($number in 1..5) {
                [bigint]$number
            }

            $CsvPath = "$TestDrive/Data.csv"

            $Objects | Export-Csv -Path $CsvPath -NoTypeInformation
            $script:ImportedData = Import-Csv -Path $CsvPath
        }

        It 'imports the stored data as PSCustomObjects' {
            # Our original data type is a .NET numeric type.
            'System.____.____' | Should -Be $Objects[0].GetType().FullName

            $ImportedData | Should -Not -BeNullOrEmpty

            # What comes back after the import?
            'System.____.____.____' | Should -Be $ImportedData[0].GetType().FullName
        }

        It 'stores properties of an object, not any inherent value' {
            $StartingValues = @(
                __
                __
                __
                __
                __
            )
            $StartingValues | Should -Be $Objects

            # (!) But our imported data does not share these values.
            $StartingValues | Should -Not -Be $ImportedData
            $PropertyNames = @(
                '____'
                '____'
                '____'
                '____'
                '____'
            )
            $PropertyNames | Should -Be $ImportedData[0].PSObject.Properties.Name
        }

        It 'allows you to specify the delimiter' {
            # What happens if we have a CSV that doesn't use commas to separate values?
            $CsvString = @"
"Name"|"Age"|"Animal"
"Stu"|"2"|"Dog"
"Alice"|"4"|"Cat"
"@
            $AnimalCsv = "$TestDrive/Animals.csv"
            $CsvString | Set-Content -Path $AnimalCsv

            # Make sure to change the delimiter below
            $Delimiter = '_'

            $Animals = Import-Csv -Path $AnimalCsv -Delimiter $Delimiter

            $Animals.Name | Should -Not -BeNullOrEmpty
            $Animals[0].Animal | Should -Be 'Dog'
            $Animals[1].Name | Should -Be 'Alice'

            @( '__', '__' ) | Should -Be $Animals.Age
        }

        It 'allows you to specify the headers' {
            # Importing a CSV with no headers causes the first entry to be used as the headers instead.
            $CsvString = @"
"Parrot","2","Steve","Yellow"
"Cockatiel","1","Jerry","Blue"
"@
            $FilePath = "$TestDrive/NoHeaders.csv"
            $CsvString | Set-Content -Path $FilePath

            # How does the import go if we just try to import?
            $HeaderLess = Import-Csv -Path $FilePath
            '____' | Should -Be $HeaderLess.Parrot

            # Maybe we should specify headers to make some sense of things.
            $ActualData = Import-Csv -Path $FilePath -Header Species, Age, Name, Colour
            '____' | Should -Be $ActualData[0].Name
            '__' | Should -Be $ActualData[1].Age
            @('____', '____') | Should -Be $ActualData.Colour
        }
    }

    Context 'ConvertTo-Csv' {
        <#
            ConvertTo-Csv is virtually identical to Export-Csv. The key difference here is that
            it will output the lines of the CSV as strings instead of storing the data to a file.
        #>
        BeforeAll {
            $script:Objects = foreach ($number in 1..5) {
                [PSCustomObject]@{
                    Number = $number
                    Square = $number * $number
                }
            }
        }

        It 'operates on string data rather than directly with files' {
            $CsvString = $Objects | ConvertTo-Csv -NoTypeInformation
            $CsvString -is [____] | Should -BeTrue
        }

        It 'works the same way as Export-Csv' {
            $CsvString = $Objects | ConvertTo-Csv -NoTypeInformation

            '"____","____"' | Should -Be $CsvString[0]
            '"__","__"' | Should -Be $CsvString[1]
            '"__","__"' | Should -Be $CsvString[2]
            '"__","__"' | Should -Be $CsvString[3]
            '"__","__"' | Should -Be $CsvString[4]
            '"__","__"' | Should -Be $CsvString[5]
        }
    }

    Context 'ConvertFrom-Csv' {

        BeforeAll {
            $script:CsvString = @"
"Number","Square"
"1","1"
"2","4"
"3","9"
"4","16"
"5","25"
"@
        }

        It 'operates on string data rather than directly with files' {
            $null = $CsvString | ConvertFrom-Csv
            $CsvString -is [____] | Should -BeTrue
        }

        It 'works the same way as Import-Csv' {
            $Objects = $CsvString | ConvertFrom-Csv
            @('__', '__', '__') | Should -Be $Objects[0..2].Number
        }
    }
}
