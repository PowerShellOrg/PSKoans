using module PSKoans
[Koan(Position = 210)]
param()
<#
    Group-Object

    Group-Object can group objects based on essentially any criteria
    you need. Its primary focus is complex objects with properties,
    but it's perfectly possible to employ custom groupings on any
    data set.
#>
Describe 'Group-Object' {
    BeforeAll {
        $script:Files = Get-ChildItem -Path $home -Recurse -Depth 2 -File
    }

    It 'groups items based on specified properties' {
        $Extensions = $Files | Group-Object -Property Extension
        <#
            The structure of the grouped objects is as follows:
                Count (Number of items in this group)
                Name  (Property that they are grouped by)
                Group (All the objects in the group)
        #>
        '____' | Should -Be $Extensions[3].Name
        __ | Should -Be $Extensions[2].Count
    }

    It 'can group on any custom expression' {
        $NameLengths = $Files |
            Group-Object -Property {$_.Name.Length} |
            Sort-Object -Property {[int]$_.Name} # The 'name' here is the group name

        $ShortestFileNames = $NameLengths[0].Group.Name
        __ | Should -Be $ShortestFileNames.Length
    }
}
