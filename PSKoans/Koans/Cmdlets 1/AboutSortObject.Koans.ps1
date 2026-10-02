using module PSKoans
[Koan(Position = 211)]
param()
<#
    Sort-Object

    Sort-Object is the most common pipeline-collating cmdlet. It is extremely useful
    when sorting a collection of objects, and is capable of fairly sophisticated
    sorting methods as you require.

    However, note that it is a collating cmdlet; it will pause the pipeline where it
    is called in order to sort everything into the specified order. This can slow
    down processing, and as a result it is recommended to sort your collection as
    late in the pipeline sequence as possible.
#>
Describe 'Sort-Object' {
    BeforeAll {
        $script:Numbers = 5, 2, 7, 1, 4, 6, 8, 3, 10, 9
        $script:Strings = 'hello', 'goodbye', 'who', 'Steve', 'PowerShell'
    }

    It 'sorts a collection of objects' {
        $Sorted = $Numbers | Sort-Object
        __ | Should -Be $Sorted
    }

    It 'can sort in descending order' {
        $Sorted = $Strings | Sort-Object -Descending
        __ | Should -Be $Sorted
    }

    It 'can sort based on the properties of objects' {
        $Sorted = 'who', 'Steve', 'hello', 'goodbye', 'PowerShell'
        $Strings | Sort-Object -Property __ | Should -Be $Sorted
    }

    It 'can sort based on custom criteria' {
        $Sorted = $Numbers | Sort-Object {$_ % 3}
        __ | Should -Be $Sorted
    }
}
