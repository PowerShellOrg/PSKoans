using module PSKoans
[Koan(Position = 305)]
param()
<#
    Splatting

    'Splatting' is a term of indistinct origin in programming, but the general idea is that rather
    than passing parameters to a function or method individually, you collect the values together
    in some form of collection, and then 'splat' the various parameters all at once into the
    command. This can help minimise code duplication and significantly improve readability in
    PowerShell

    PowerShell supports two kinds of splatting; one utilising arrays, and the other, hashtables.
    In both cases, the parameter object is first defined and stored in a $Variable. This is then
    'splatted' into the command by specifying the variable name with an @ symbol: @Variable
#>
Describe 'Splatting' {

    BeforeAll {
        $script:PSKoansFolder = Get-PSKoanLocation
    }

    Context 'Hashtable Splatting' {
        <#
            Splatting truly shines when it comes to hashtables. All cmdlet parameters, including
            switches, can be folded into a hashtable.
        #>
        It 'helps keep code tidy' {
            # Here are a few common ways a detailed command to find files in a folder might be written:

            # 1. Super long lines; hard to follow along with.
            $LongLines = Get-ChildItem -Path $PSKoansFolder -Include '*.ps1' -Depth 2

            # 2. Escaping linebreaks; more readable, but very fragile and prone to errors
            $Escaping = Get-ChildItem `
                -Path $PSKoansFolder `
                -Include '*.ps1' `
                -Depth 2

            # 3. Splatting using a hashtable. Note the similarity to #2 and fill in missing values.
            $Parameters = @{
                Path    = $PSKoansFolder
                Include = '__'
                Depth   = __
            }
            $Splatted = Get-ChildItem @Parameters
            <#
                All above approaches are equal in effect, but splatting is a much tidier and more
                maintainable approach.
            #>
            $Splatted.Count | Should -Be $Escaping.Count
            $Splatted.Name | Should -Be $Escaping.Name

            $Escaping.Count | Should -Be $LongLines.Count
            $Escaping.Name | Should -Be $LongLines.Name

            $LongLines.Count | Should -Be $Splatted.Count
            $LongLines.Name | Should -Be $Splatted.Name
        }

    }

    Context 'Advanced Splatting Techniques' {

        It 'can be built up in parts' {
            $Parameters = @{Path = $PSKoansFolder }

            $Value = __
            if ($Value -eq 7) {
                $Parameters.Add('File', $true)
                $Parameters.Add('Recurse', $true)
            }
            else {
                $Parameters.Add('Directory', $true)
            }

            Get-ChildItem @Parameters |
                Select-Object -First 1 |
                Should -BeOfType 'System.IO.FileInfo'
        }

        It 'can be built from automatic hashtables' {
            $String = "Folders:__"
            $Parameters = if ($String -match 'Folders:(?<Filter>[_\d\w ]*)$') {
                <#
                    Matches is automaticed populated by the -match operater in the if statement
                    If $String = "Folders:00_TheBasics"
                    Then $Matches holds the following:
                    Name                           Value
                    ----                           -----
                    Filter                         00_TheBasics
                    0                              Folders:00_TheBasics
                #>
                $Matches.Remove(0) # Remove the 'whole' match and keep only the portions we asked for
                # Clone() copies the remaining matches, so we can store them with the $Parameters assignment above.
                $Matches.Clone()
            }
            $Parameters.Add('Path', $PSKoansFolder)
            $Parameters.Add('Directory', $true)

            (Get-ChildItem @Parameters).Count | Should -Be __
        }
    }
}
