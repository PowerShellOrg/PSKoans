using module PSKoans
[Koan(Position = 304)]
param()

<#
    PSObjects

    Everything in PowerShell is in actuality a PSObject. PSObject is a wrapper type that can contain
    any other type of boxable object, or none. Not all object types can actually be boxed; byref-like
    structs (e.g., System.Span) are one particular example.

    PSObjects can be used to add additional members to a basic object type; this is how the Add-Member
    cmdlet works. It is also quite easy to access the normally-hidden PSObject properties in order
    to accomplish otherwise difficult tasks, such as dynamically listing any given object's members,
    as well as adding and removing ETS (instance) properties.

    It is somewhat comparable to C#'s ExpandoObject, but is unrelated.
#>

Describe 'PSObject' {
    BeforeAll {
        $script:Object = @('Stand for nothing; fall for everything.')
    }

    It "is accessed via a hidden .PSObject property" {
        <#
            The .PSObject member contains many properties, but the .PSObject property itself does not
            actually register for tab-completion, though its child properties do.
        #>
        $PSObjectProperties = ($Object.PSObject | Get-Member -MemberType Properties).Name | Sort-Object

        @(
            'BaseObject'
            '____'
            'Members'
            'Methods'
            '____'
            '____'
        ) | Sort-Object | Should -Be $PSObjectProperties
    }

    It "details the base object's properties and methods" {
        $PropertyNames = @(
            'Count'
            'IsFixedSize'
            '____'
            '____'
            '____'
            'LongLength'
            '____'
            'SyncRoot'
        ) | Sort-Object
        $ExpectedProperties = $Object.PSObject.Properties.Name | Sort-Object
        $PropertyNames | Should -Be $ExpectedProperties

        $Methods = $Object.PSObject.Methods
        __ | Should -Be $Methods.ForEach{$_}.Count
        $Methods['____'].Name | Should -Be 'get_Length'
    }

    It "can be found on any object in PowerShell" {
        # Even an empty collection holds some meaning
        $Empty = @()

        # Native .NET objects have their standard properties mapped to PSObject properties for easy access
        $PropertyNames = $Empty.PSObject.Properties.Name | Sort-Object
        $PropertyNames | Should -Not -BeNullOrEmpty
        @(
            '____',
            '____',
            'IsReadOnly',
            'IsSynchronized',
            '____',
            '____',
            '____',
            '____'
        ) | Sort-Object | Should -Be $PropertyNames
        __ | Should -Be $Empty.IsReadOnly
    }

    It "exposes the object's ETS properties as a collection" {
        <#
            ETS (Extended Type System) properties are often created by PowerShell's own internal methods for many
            pre-existing types, but we can create and add new ones at will.
            A PSCustomObject's properties are all ETS NoteProperties.
        #>
        $Object = [PSCustomObject]@{
            Flower = "Rose"
            Color  = "Red"
            Thorns = $true
        }

        @('____', '____', '____') | Should -Be $Object.PSObject.Properties.Name
        # Collections come in many shapes and sizes - what type is this one?
        '____' | Should -Be $Object.PSObject.Properties.GetType().Name
        '____' | Should -Be $Object.PSObject.Properties['Flower'].MemberType
    }

    It "details where the properties originate from" {
        # Sometimes where it comes from is more important then what it is
        $Object = @()
        Add-Member -InputObject $Object -MemberType NoteProperty -Name 'TestProperty' -Value __

        $Object.TestProperty | Should -Be 12
        '____' | Should -Be $Object.PSObject.Properties['TestProperty'].MemberType

        $PropertyTypes = $Object.PSObject.Properties |
            Group-Object -Property MemberType |
            Select-Object -ExpandProperty Name |
            Sort-Object

        # There may be varying property types depending on your PowerShell version
        @( '____', '____', '____' ) | Sort-Object | Should -Be $PropertyTypes
    }

    It "can find derivative properties" {
        $Name = @("Julian")
        Add-Member -InputObject $Name -MemberType ScriptProperty -Name 'Letters' -Force -Value {
            # A ScriptProperty is dynamic, and can reference the object itself using the reserved variable '$this'.
            $this | ForEach-Object { $_ -as [char[]] -as [string[]] }
        }
        Add-Member -InputObject $Name -MemberType NoteProperty -Name 'Surname' -Value 'Sylph'

        '____' | Should -Be $Name.Letters[3]

        $PropertyTypes = $Name.PSObject.Properties |
            Group-Object -Property MemberType |
            ForEach-Object -MemberName Name |
            Sort-Object

        @( '____', '____', '____', '____') | Sort-Object | Should -Be $PropertyTypes
    }
}
