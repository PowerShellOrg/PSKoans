#Requires -Modules ActiveDirectory
using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    'sid',
    Justification = 'Consumed by the ActiveDirectory -Filter string, which the AD provider expands by variable name at runtime rather than PowerShell interpolating it.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    'homeDirectory',
    Justification = 'Consumed by the ActiveDirectory -Filter string, which the AD provider expands by variable name at runtime rather than PowerShell interpolating it.'
)]
[Koan(Position = 101, Module = 'ActiveDirectory')]
param()
<#
    About Filtering

    The ActiveDirectory module offers support for two different styles of filtering via two different parameters.

    The Filter parameter supports a PowerShell-style expression as the filter. The expression is converted into
    an LDAP filter by the ActiveDirectory module before being sent to the AD web services gateway.

    It is possible, although not easy, to run the filter converter independently. The function in the following
    gist does so:

        https://gist.github.com/indented-automation/66e07bc76fdb6cf0be6743ed0b24575c

    PowerShell-style filters have a number of quirks and occasionally do not behave as they should. Any failures
    are assumed to be problems caused when converting the filter.
#>
Describe 'About Filtering' {

    Context 'PowerShell-style filtering' {
        <#
            The Filter parameter expects a string. Several of the examples use a ScriptBlock to write the filter.

                Get-ADUser -Filter { name -eq "Dave" }

            The filter above can also be written using single quotes, a literal or non-expanding string. The two filters
            are identical except in appearance

                Get-ADUser -Filter 'name -eq "Dave"'

            Using a script block can be misleading. It implies support for more complex expressions which is not present.
        #>

        It 'often uses script blocks in examples' {
            # Fill in your username to show that both filters return the same result.

            Get-ADUser -Filter { samAccountName -eq '____' } |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $env:USERNAME

            Get-ADUser -Filter 'samAccountName -eq "____"' |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $env:USERNAME
        }

        It 'expands variables in literal strings' {
            <#
                Variable expansion in filters is a feature of the ActiveDirectory module.

                Sub-expressions are not supported. Values from providers, such as the Environment provider, for example
                $env:USERNAME, are not supported.

                The variable below is in single quotes. PowerShell will not expand this variable, the ActiveDirectory
                module will.
            #>

            $username = '____'
            Get-ADUser -Filter 'samAccountName -eq $username' |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $env:USERNAME
        }

        It 'is often useful to let the Active Directory module expand a variable' {
            <#
                The AD module uses a mixture of hard-coded data and information from the AD schema to figure out the
                format an attribute expects in a filter.

                For example, if a filter is written based on a SID the ActiveDirectory module will happily convert the
                SID into an appropriate format. The author of the query no longer needs to care about exactly
                how the filter should be written.

                The same approach can be used for dates, GUIDs, byte arrays, and so on.
            #>

            $username = '____'
            # The statement below will only work on Windows
            $sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
            Get-ADUser -Filter 'objectSID -eq $sid' |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $username

            <#
                The SID will be converted into an appropriate format for an LDAP filter. Similar to the example below:

                    (objectSid=\01\05\00\00\00\00\00\05\15\00\00\00\11\22\33\44\55\66\77\88\99\AA\BB\CC\DD\EE\FF\00)
            #>
        }

        It 'can expand properties of objects from variables' {
            <#
                Filters do not support sub-expressions but the Filter parameter does support property expansion.

                The catch is that the ActiveDirectory module can only expand properties of .NET types. It cannot read
                NoteProperty values from PSCustomObject, it cannot read NoteProperty members added by Add-Member.

                Get-Item will return a System.IO.DirectoryInfo object if the path is a directory. The DirectoryInfo
                object has a Name property which can be expanded.
            #>

            $homeDirectory = Get-Item -Path '____'
            Get-ADUser -Filter 'samAccountName -eq $homeDirectory.Name' |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $env:USERNAME
        }

        It 'can sometimes be better to let PowerShell expand variables' {
            <#
                In some cases it can be better to treat the filter as a string and let PowerShell expand any
                variable values.

                If PowerShell is expanding values, quotes must be added around the value in the filter.
            #>

            $username = '____'
            Get-ADUser -Filter "samAccountName -eq '$username'" |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $env:USERNAME
        }

        It 'has aliases for certain attributes' {
            <#
                The ActiveDirectory module provides aliases for a large number of attributes. In some cases this is
                just convenient. In others, it is used to hide complexity.

                Enabled is a commonly used alias which masks a query against the userAccountControl attribute.
            #>

            $username = '____'
            Get-ADUser -Filter 'samAccountName -eq $username -and Enabled -eq $true' |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $env:USERNAME

            <#
                Whether or not an account is enabled is described by a single flag in the userAccountControl attribute.

                The query used above can also be written as shown below.
            #>


            Get-ADUser -Filter 'samAccountName -eq $username -and -not userAccountControl -band 2' |
                Select-Object -ExpandProperty SamAccountName |
                Should -Be $env:USERNAME

            <#
                In both cases, the filter is converted to the following LDAP filter.

                    (&(samAccountName=<Username>)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

                Other common aliases include LastLogonDate, an alias for lastLogonTimestamp.

                The possible aliases can be read from the ActiveDirectory module although they are not easily
                available. The function in in the gist below does so:

                    https://gist.github.com/indented-automation/629a00167a74e9cb3329eabd6662bc0c
            #>
        }
    }
}
