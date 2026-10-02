using module PSKoans
[Koan(Position = 106)]
param()
<#

    Get-Member

    Following on from our last Koan about cmdlet verbs, lets cover the nouns.
    As previously stated, the noun portion indicates the target of a given command.
    If you use the "Get-Member" cmdlet on any object you'll see its type name, or data type.

    For example:

        PS C:\Users\Administrator\Documents\GitHub\Dev\PSKoans> Get-Process | Get-Member


            TypeName: System.Diagnostics.Process

        Name                       MemberType     Definition
        ----                       ----------     ----------
        Handles                    AliasProperty  Handles = Handlecount
        Name                       AliasProperty  Name = ProcessName
        NPM                        AliasProperty  NPM = NonpagedSystemMemorySize64
        PM                         AliasProperty  PM = PagedMemorySize64
        SI                         AliasProperty  SI = SessionId
        VM                         AliasProperty  VM = VirtualMemorySize64
        WS                         AliasProperty  WS = WorkingSet64

    You'll also see properties and methods. Together with the TypeName, this tells us everything
    we need to know in order to access the object's data and any actions it can perform.

    Accessing a property or method is done via dot notation, which boils down to:

    $Object.Property
    $Object.Method()

    We'll cover why we have to use parentheses with method calls later.
#>

Describe "Get Member" {

    Context 'Exploring Object Properties' {
        <#
            Let's look at some object properties!

            Properties define the state an object is in.

            Using any three cmdlets you like (make sure you use three different
            cmdlets!), use Get-Member in your console to peek at the properties
            on the object.

            Let's see an example; by sending the output from Get-Process into
            Get-Member we can inspect the objects Get-Process outputs. You can
            run the below command in your console:

                Get-Process | Get-Member -MemberType Property

            From the output of the above command, we will see that one of the
            properties is named "Threads", so using that cmdlet name and that
            property name will satisfy one of the tests below.

            The others are up to you! Get-* cmdlets will be most helpful here;
            if you're not sure which to try, you can use the following command
            to list Get-* cmdlets you can try out:

                Get-Command -Verb Get
        #>
        BeforeAll {
            $script:Cmdlets = [System.Collections.Generic.HashSet[string]]::new()
            $script:PropertyString = "property '{0}' should be present in output from {1}"
            $script:UniqueString = 'unique cmdlets should be used for each test'
        }

        It 'lists one of the properties of the first unique command' {
            $CmdletName = '____'
            $PropertyName = '____'

            $Parameters = @{
                <#
                    This is only needed if a cmdlet you provide has mandatory
                    parameters. Enter the parameter name and the value just
                    outside this comment block, but inside the @{ } like so:

                    ParameterName = "Value"
                #>

            }

            $Reason = $PropertyString -f $PropertyName, $CmdletName
            & (Get-Command -Name $CmdletName) @Parameters |
                Get-Member -MemberType Property -Name $PropertyName |
                Should -Not -BeNullOrEmpty -Because $Reason

            $Cmdlets.Add($CmdletName) | Should -BeTrue -Because $UniqueString
        }

        It 'lists one of the properties of the second unique command' {
            $CmdletName = '____'
            $PropertyName = '____'

            $Parameters = @{
                <#
                    This is only needed if a cmdlet you provide has mandatory
                    parameters. Enter the parameter name and the value just
                    outside this comment block, but inside the @{ } like so:

                    ParameterName = "Value"
                #>

            }

            $Reason = $PropertyString -f $PropertyName, $CmdletName
            & (Get-Command -Name $CmdletName) @Parameters |
                Get-Member -MemberType Property -Name $PropertyName |
                Should -Not -BeNullOrEmpty -Because $Reason

            $Cmdlets.Add($CmdletName) | Should -BeTrue -Because $UniqueString
        }

        It 'lists one of the properties of the third unique command' {
            $CmdletName = '____'
            $PropertyName = '____'

            $Parameters = @{
                <#
                    This is only needed if a cmdlet you provide has mandatory
                    parameters. Enter the parameter name and the value just
                    outside this comment block, but inside the @{ } like so:

                    ParameterName = "Value"
                #>

            }

            $Reason = $PropertyString -f $PropertyName, $CmdletName
            & (Get-Command -Name $CmdletName) @Parameters |
                Get-Member -MemberType Property -Name $PropertyName |
                Should -Not -BeNullOrEmpty -Because $Reason

            $Cmdlets.Add($CmdletName) | Should -BeTrue -Because $UniqueString
        }
    }

    Context 'Exploring Object Methods' {
        <#
            Now that we know how the state of an object is represented by the values of its properties,
            we can now take a look at methods. In contrast to properties, methods need parentheses.
            Inside the parentheses you can give additional parameters (oftentimes called arguments)
            to the method, similary to parameters for a function. In fact, this is how most
            programming languages treat functions and methods. If for example you want to
            know if a string ends with a certain character, it is necessary that the method knows
            which character you want to compare the string against.

            Similar to above, you can inspect the methods available from an
            object that a cmdlet outputs, by changing the -MemberType value
            you provide to Get-Member:

                Get-Process | Get-Member -MemberType Method

            If you don't provide a -MemberType option and value, it will simply
            list all the members, regardless of the kind of members they are.

            You can reuse the same set of cmdlets from above here if you wish,
            but you will need to check to see if there are methods available on
            the objects they output!
        #>
        BeforeAll {
            $script:Cmdlets = [System.Collections.Generic.HashSet[string]]::new()
            $script:MethodString = "property '{0}' should be present in output from {1}"
            $script:UniqueString = 'unique cmdlets should be used for each test'
        }

        It 'lists one of the methods of the first unique command' {
            $CmdletName = '____'
            $MethodName = '____'

            $Reason = $MethodString -f $MethodName, $CmdletName
            & (Get-Command -Name $CmdletName) |
                Get-Member -MemberType Method -Name $MethodName |
                Should -Not -BeNullOrEmpty -Because $Reason

            $Cmdlets.Add($CmdletName) | Should -BeTrue -Because $UniqueString
        }

        It 'lists one of the methods of the second unique command' {
            $CmdletName = '____'
            $MethodName = '____'

            $Reason = $MethodString -f $MethodName, $CmdletName
            & (Get-Command -Name $CmdletName) |
                Get-Member -MemberType Method -Name $MethodName |
                Should -Not -BeNullOrEmpty -Because $Reason

            $Cmdlets.Add($CmdletName) | Should -BeTrue -Because $UniqueString
        }

        It 'lists one of the methods of the third unique command' {
            $CmdletName = '____'
            $MethodName = '____'

            $Reason = $MethodString -f $MethodName, $CmdletName
            & (Get-Command -Name $CmdletName) |
                Get-Member -MemberType Method -Name $MethodName |
                Should -Not -BeNullOrEmpty -Because $Reason

            $Cmdlets.Add($CmdletName) | Should -BeTrue -Because $UniqueString
        }
    }
}
