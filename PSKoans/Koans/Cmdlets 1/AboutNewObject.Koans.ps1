using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseLiteralInitializerForHashtable',
    '',
    Justification = 'Creating a Hashtable via New-Object (vs. the @{} literal) is the exact thing this koan demonstrates.'
)]
[Koan(Position = 203)]
param()
<#
    New-Object

    New-Object, as the name implies, is used to create objects. For the most part,
    it is used to instantiate .NET objects, but can also be used to create COM
    objects for interactions with the Windows COM interfaces.
#>
Describe 'New-Object' {

    It 'can create objects of a specified type' {
        $Object = New-Object -TypeName 'System.Collections.Hashtable'
        $Hashtable = @{}

        $Hashtable | Should -BeOfType System.Collections.Hashtable
        $Object | Should -BeOfType __
    }

    It 'can create objects of any available type' {
        $PSObject = New-Object -TypeName 'PSObject'
        $PSObject | Should -BeOfType __
    }

    It 'can accept arguments for the constructor' {
        $Object = New-Object 'string' -ArgumentList ([char[]]@('b','a','n','a','n','a'), 0, 3)
        '__' | Should -Be $Object
        $Object | Should -BeOfType string
    }

    It 'is just one way to instantiate an object' {
        $Object = New-Object 'PSObject'
        $Object2 = [PSObject]::new()

        $Object | Should -BeOfType System.Management.Automation.PSObject
        $Object2 | Should -BeOfType __
    }
}
