using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'Item',
    Justification = 'Second $Filter is a blank scriptblock body the learner completes; $Item is unused until solved.'
)]
[Koan(Position = 301)]
param()
<#
    Lists - Flexible, Generic Collections

    Arrays have one critical weakness: they are immutable collections. While the
    members within them can change, the number of items they hold cannot. Consider the
    folllowing code:

    $Array = 0, 1
    $Array = $Array + 2
    $Array += 3

    # So, if the number of items in an array can't change, what happens here?
    # You might think it should fail with an error, but it won't!

    Actually, in PowerShell, the addition operator for arrays is defined something like:

        "Take the elements in this array, and the thing(s) we're adding in, and
        build a new array with them."

    This is very convenient, but it can create a problem - this gets significantly more
    expensive if you need to do it a lot. For large collections, adding items to them
    becomes very slow to do.

    Introducing: Lists!

    Lists are generic collections, which means that they have a defined type when
    created, and will only hold objects of that type. Other types will either be
    converted, or cause an error to be thrown if there is no available conversion.
    However, all objects in PowerShell inherit from [PSObject] or [object], so a
    List with that typing will hold any mix of data types.

    There are several ways to create a List object, but we'll just cover the main
    methods. For more details, check out the available overloads, which you can
    see by executing the following line as-is in the PowerShell console:

    [System.Collections.Generic.List[psobject]]::new
#>
Describe 'Lists' {

    Context 'Strict Typing' {

        It 'can enforce strict typing on its contents' {
            # New integer-only List
            $IntList = New-Object System.Collections.Generic.List[int]
            $IntList.Add(7)
            $IntList.Add(5.34)

            # Items are accessed by index just like arrays.
            __ | Should -Be $IntList[0]
            __ | Should -Be $IntList[1]
        }

        It 'will convert items to its data type when possible' {
            $StringList = [System.Collections.Generic.List[string]]::new()
            $StringList.Add('____')
            $StringList.Add(12) # What happens if we add a number to a string-typed list?

            'hello!' | Should -Be $StringList[0]
            '____' | Should -Be $StringList[1]
        }
    }

    Context 'Loose Typing' {

        It 'can accept loose typing' {
            <#
                We can convert from an array by casting.
                [object] or [PSObject] typed lists hold any type(s) of items.
            #>
            $List = [System.Collections.Generic.List[Object]]@(1, 2)

            <#
                Items must be added to Lists using their .Add() or .AddRange() method.
                .AddRange() takes an array or other collection object.
            #>
            $List.AddRange(@(12, 1, 2, 3))
            $List.Add(12.5)

            __ | Should -Be $List[0]
            $List[6] -eq 12.5 | Should -BeTrue
        }
    }

    Context 'Removing List Entries' {

        It 'allows you to remove entries' {
            <#
                Lists have a few methods for removing entries:
                .Remove($value), .RemoveAt($Index) and .RemoveRange($Index,$Count) (among others)
            #>
            $List = [System.Collections.Generic.List[string]]@(12, 15, 15, 18, 'hello', 19, 4, 12, 5, 10)

            $List[3] | Should -Be '18'
            $List.RemoveAt(3)
            '____' | Should -Be $List[3]

            $List[1] | Should -Be '15'
            <#
                The .Remove() method returns $true if the item was removed, and $false if it couldn't be
                found or removed.
            #>
            $List.Remove('15') | Should -BeTrue
            __ | Should -Be $List[1]

            <#
                Now see if you can reduce the list down to only two values using the .RemoveRange($Index, $Count)
                method. Feel free to add additional `$value | Should -Be $expectedValue` tests if you need them
                to guide the way!
            #>
            $List | Should -Be @('12', '10')
        }

        It 'allows you to remove multiple entries based on conditions' {
            $List = [System.Collections.Generic.List[string]]@(1..11)
            <#
                This method takes a lambda expression in C#, which translates to a script block for
                PowerShell. Each item is fed into the script one at a time, and all items for which the
                script gives a $true or truthy value are deleted from the list.

                It also outputs a $true or $false depending on whether elements were removed, which we
                can use to check if any items were actually removed.
            #>
            $Filter = {
                # The input variable representing each entry must be named, or use $args[0].
                param($Item)

                # Remove everything that contains the number 9, essentially.
                $Item -match '9'
                # The output must boil down to a $true/$false, or will be coerced to it.
            }
            $List.RemoveAll($Filter) | Should -BeTrue

            $RemainingEntries = @('1', '2', '__', '__', '5', '__', '7', '__', '__', '11')
            $List | Should -Be $RemainingEntries

            $Filter = {
                param($Item)
                # Fill in this script block to make the below assertions true!

            }
            $List.RemoveAll($Filter) | Should -BeTrue

            $List | Should -Be @(1, 3, 5, 7, 11)
        }
    }
}
