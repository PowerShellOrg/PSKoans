using module PSKoans
[Koan(Position = 205)]
param()
<#
    Select-Object

    Select-Object is a utility cmdlet which serves a number of different purposes.

        * Select or skip a fixed number of objects from a pipeline
        * Select unique objects from an array or collection
        * Select individual properties from an object
        * Create a new object with additional, custom, properties
#>
Describe 'Select-Object' {
    It 'can select specific properties from an object' {
        <#
            Select-Object can accept an array of property names and creates a
            new custom object using those properties.
        #>

        $Selected = Get-Process -Id $PID | Select-Object Name, ID, Path

        @('____', '____', 'Path') | Should -Be $Selected.PSObject.Properties.Name

        $Selected.____ | Should -Be $PID
    }

    It 'can exclude specific properties from an object' {
        <#
            Individual properties can be excluded from a selection.

            Both the Property and ExcludeProperty parameters support wildcards.
        #>

        $Folder = Get-Item -Path $PSHome

        '____' | Should -Be $Folder.Attributes

        $Selected = $Folder | Select-Object -Property * -ExcludeProperty Attributes

        $Selected.Attributes | Should -BeNullOrEmpty
    }

    It 'changes the object type' {
        <#
            When properties are selected from an object a new custom object is created.

            The new object is also tagged with a PSTypeName derived from the original type name.
        #>

        $Folder = Get-Item -Path $PSHome

        $Folder | Should -BeOfType [____]

        'System.IO.Directoryinfo' | Should -BeIn $Folder.PSTypeNames

        # The new selected object is an instance of [System.Management.Automation.PSCustomObject].

        $Selected = $Folder | Select-Object -Property * -ExcludeProperty Attributes

        $Selected | Should -BeOfType [System.Management.Automation.PSCustomObject]

        '____' | Should -BeIn $Selected.PSTypeNames
    }

    It 'can retrieve just the contents or value of a property' {
        # Individual properties can be expanded, retrieving the just a value.

        $PropertyToExpand = '____'

        $Value = Get-Item -Path $PSHome | Select-Object -ExpandProperty $PropertyToExpand -ErrorAction SilentlyContinue

        $Value | Should -Be 'Directory'
    }

    It 'can merge the properties of a nested object with properties from the parent' {
        <#
            The ExpandProperty parameter can be used to "move" the properties of a nested
            property up to a new parent object.
        #>

        $PowerShellExe = Get-Process -Id $PID | Select-Object -ExpandProperty Path | Get-Item

        $Selected = $PowerShellExe | Select-Object Name -ExpandProperty VersionInfo

        # The resulting object will contain all of the properties found under VersionInfo.

        $Selected.____ | Should -Be $PowerShellExe.FullName
    }

    It 'can pick specific numbers of objects' {
        $Array = 1..100 -as [string[]]

        $FirstThreeValues = $Array | Select-Object -First 3
        @('__', '__', '__') | Should -Be $FirstThreeValues

        $LastFourValues = $Array | Select-Object -Last 4
        @('__', '__', '__', '__') | Should -Be $LastFourValues

        $Values = $Array | Select-Object -Skip 10 -First 5
        @('__', '__', '__', '__', '__') | Should -Be $Values

        # SkipLast cannot be used alongside the Last, First, and Skip parameters.

        $Values = $Array | Select-Object -SkipLast 95
        @('__', '__', '__', '__', '__') | Should -Be $Values
    }

    It 'can ignore duplicate objects' {
        # Select-Object can be used to create a unique list.

        $Array = @(
            '6', '1', '4', '8', '7', '5', '3', '9', '2', '3', '2', '1', '5', '1', '6'
            '2', '8', '4', '7', '3', '1', '2', '6', '3', '7', '1', '4', '5', '2', '1'
            '3', '6', '2', '5', '1', '4'
        )

        $UniqueItems = $Array | Select-Object -Unique
        @('6', '__', '4', '8', '__', '__', '3', '__', '2') | Should -Be $UniqueItems
    }

    It 'can ignore duplicate complex objects' {
        <#
            Unique works on some more complex objects.

            Ideally objects should be directly comparable, although this is
            rare outside of Strings, numeric types, enumeration types, and other value types.

            Select-Object falls back on the ToString method of an object.
        #>

        $Processes = @(
            Get-Process -Id $PID
            Get-Process -Id $PID
        )

        __ | Should -Be $Processes.Count

        $UniqueProcesses = $processes | Select-Object -Unique

        __ | Should -Be $UniqueProcesses.Count

        <#
            As Process objects are not directly comparable, they are made unique by comparing a
            string representation of the process.

            The string to compare is created as shown below:

                $object = Get-Process -Id $PID
                [PSObject]::AsPSObject($object).ToString()

            For PSCustomObjects the conversion to string is slightly different:

                $object = [PSCustomObject]@{ Name = 'one'}
                [PSObject]::AsPSObject($object.PSBase).ToString()

            This value includes the name of the process, but not the
            ProcessId.

            If several processes of the name name are running these
            will be removed by the Unique parameter.

            If the Property parameter is used, Unique is evaluated after creating a new
            custom object.
        #>
    }

    It 'maintains the original object type when the Property parameter is not used' {
        # When the Property parameter is used, a new object

        $Files = Get-ChildItem -Path $PSHome -File

        $SelectedFile = $Files | Select-Object -First 1

        '____' | Should -Be $SelectedFile.GetType().FullName
    }

    It 'supports custom, or calculated, properties' {
        <#
            The property parameter can read a hashtable which describes a property.

            The hashtable requires a Name, and Expression to calculate a value for the property.
            The Expression is most often a script block, a short script enclosed in curly braces.

            The variable $_, or $PSItem, is used to refer to the object from the pipeline within the
            Exrpression. Properties may be used even if they are not selected.
        #>

        $Selected = Get-Process -Id $PID | Select-Object @(
            'Name'
            'Id'
            @{ Name = 'RunningTime'; Expression = { (Get-Date) - $_.StartTime } }
        )

        $Selected.____ | Should -BeGreaterThan 0

        <#
            Custom properties are often used to merge information from multiple sources into
            a single object.
        #>

        $Selected = Get-Process -Id $PID | Select-Object @(
            'Name'
            'Id'
            @{ Name = 'RunningTime'; Expression = { (Get-Date) - $_.StartTime } }
            @{ Name = 'Size'; Expression = { (Get-Item $_.Path).Length } }
        )
    }

    It 'does not need a script block when renaming a property' {
        <#
            When renaming a property, a string with the existing property name can be used in place of the
            script block.
        #>

        $Process = Get-Process -Id $PID
        $Selected = $Process | Select-Object @(
            'Name'
            @{ Name = 'ProcessId'; Expression = 'Id' }
        )

        $Selected.____ | Should -Be $Process.Id
    }

    It 'allows Label to be used instead of Name' {
        $Process = Get-Process -Id $PID
        $Selected = $Process | Select-Object @(
            'Name'
            @{ Label = 'ProcessId'; Expression = 'Id' }
        )

        $Selected.____ | Should -Be $Process.Id
    }

    It 'supports abbreviated names in a calculated property' {
        <#
            Select-Object supports shorthand for the keys in the hashtable.

                * Name can be abbreviated to n
                * Label can be abbreviated to l
                * Expression can be abbreviated to e

            Properties are calculated when Select-Object runs, they are not updated or recalculated later.
        #>

        $Selected = Get-Process -Id $PID | Select-Object @(
            'Name'
            'Id'
            @{ Name = 'RunningTime'; Expression = { (Get-Date) - $_.StartTime } }
        )

        $Selected.____ | Should -BeOfType [TimeSpan]
    }

    It 'From Select-Object to PSCustomObject' {
        <#
            As mentioned above, the Select-Object command creates instances of the
            System.Management.Automation.PSCustomObject type.

            Select-Object can be used to create an object from scratch. The
            technique below was widely used before PowerShell 2 was released.
        #>

        $customObject = '' | Select-Object -Property @(
            @{ Name = 'Property1'; Expression = { 'Value1' } }
            @{ Name = 'Property2'; Expression = { 'Value2' } }
        )

        $customObject | Should -BeOfType [System.Management.Automation.PSCustomObject]

        # The approach above was replaced with New-Object with the release of PowerShell 2.

        $customObject = New-Object PSObject -Property @{
            Property1 = 'Value1'
            Property2 = 'Value2'
        }

        $customObject | Should -BeOfType [System.Management.Automation.PSCustomObject]

        <#
            The [PSCustomObject] type accelerator was made available with PowerShell 3. It provides
            a neater way of creating objects from scratch, replacing both of the methods above.

            Select-Object is still widely used when creating a new object from another object.
        #>

        $customObject = [PSCustomObject]@{
            Property1 = 'Value1'
            Property2 = 'Value2'
        }

        $customObject | Should -BeOfType [System.Management.Automation.PSCustomObject]

        <#
            Despite the similar naming, the PSCustomObject type accelerator is shorthand for
            System.Management.Automation.PSObject. It is named as it is because it creates a custom object.
        #>

        [PSCustomObject].FullName | Should -Be System.Management.Automation.PSObject
    }
}
