using module PSKoans
[Koan(Position = 206)]
param()
<#
    Measure-Object

    Measure-Object is, as its name implies, a utility cmdlet that
    performs mathematical operations on collections of objects.
#>
Describe 'Measure-Object' {
    BeforeAll {
        $script:Numbers = @(
            839, 339, 763, 663, 238, 427, 577, 613, 284, 453
            850, 130, 250, 843, 669, 972, 572, 41, 172, 155
            729, 616, 285, 231, 128, 540, 204, 584, 407, 98
            668, 85, 320, 435, 87, 719, 936, 25, 75, 122
            665, 154, 943, 35, 391, 816, 420, 229, 3, 938
        )

        $script:Files = Get-ChildItem -Path $HOME -Recurse -Depth 2
    }

    It 'can count objects' {
        $Numbers |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be __

        $Files |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be __
    }

    It 'can sum numerical objects' {
        $StopIndex = __

        $Numbers[0..$StopIndex] |
            Measure-Object -Sum |
            Select-Object -ExpandProperty Sum |
            Should -Be 6046
    }

    It 'can average numerical objects' {
        $StartIndex = __

        $Numbers[$StartIndex..25] |
            Measure-Object -Average |
            Select-Object -ExpandProperty Average |
            Should -Be 421.5
    }

    It 'can find the largest or smallest value' {
        $StopIndex = __

        $Values = $Numbers[5..$StopIndex] |
            Measure-Object -Minimum -Maximum

        $Values.Minimum | Should -Be 130
        $Values.Maximum | Should -Be 972
    }

    It 'can find multiple values at once' {
        $StartIndex = __
        $StopIndex = __

        $Values = $Numbers[$StartIndex..$StopIndex] |
            Measure-Object -Average -Minimum -Sum

        $Values.Average | Should -Be 377
        # 'Count' is always present in the data from Measure-Object
        $Values.Count | Should -Be 11
        $Values.Minimum | Should -Be 85
        $Values.Sum | Should -Be 4147
    }

    It 'can operate on object properties' {
        $Data = $Files.BaseName | Measure-Object -Property Length -Sum -Average

        # Averages can have a lot of decimal places, so we'll round to just 4 decimal places.
        $Average = [math]::Round($Data.Average, 4)

        __ | Should -Be $Data.Sum
        __ | Should -Be $Average
    }

    It 'can measure text lines, characters, and words of strings' {
        $Text = '
            Two monks were arguing about the temple flag waving in the wind.
            One said, "The flag moves."
            The other said, "The wind moves."
            They argued back and forth but could not agree.

            Hui-neng, the sixth patriarch, said:
            "Gentlemen! It is not the flag that moves. It is not the wind that moves. It is your mind that moves."

            The two monks were struck with awe.
        '
        $Data = $Text | Measure-Object -Line -Word -Character

        __ | Should -Be $Data.Lines
        __ | Should -Be $Data.Words
        __ | Should -Be $Data.Characters
    }
}
