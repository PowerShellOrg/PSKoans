using module PSKoans
[Koan(Position = 306)]
param()

<#
    Advanced Functions

    A majority of functions you'll make use of in PowerShell fall into the broad
    category of "advanced functions." While simple functions are handy in a
    pinch, they can be quite fragile and afford neither protection nor automatic
    handling of any parameters like advanced functions allow you to create.

    Advanced functions have many pieces that make them work together, but in
    essence they are a way of keeping tight control of the kinds of input that
    your function will be handling. This allows you to write the code without
    worrying too much about how unexpected input might cause unexpected and
    problematic behaviour.
#>

Describe 'Advanced Functions' {

    Context 'CmdletBinding & Binding Parameters' {
        <#
            [CmdletBinding()] is an attribute that can be applied to PowerShell
            functions. It has the effect of turning them into "advanced" functions.

            What this actually means is a bit complex, but in essence it brings them
            significantly closer to behaving like a true compiled cmdlet.

            When using CmdletBinding, parameters must be explicitly defined. There
            is no usage of $args, nor any ability to handle unbound parameters.
            Parameters that can't be bound by position or name will result in an
            error.
        #>

        It 'does not strictly bind parameters for simple functions' {
            # Simple functions don't verify parameters passed to them.
            function Test-Function {
                param($Some)

                $args
            }

            $Results = Test-Function -Some "Values" -Passed 2 -TheFunction

            # Any undefined parameter names are assumed to be string arguments.
            $Values = @(
                '____'
                '-Passed'
                __
                '-____'
            )
            $Results | Should -BeExactly $Results
        }

        It 'strictly binds parameters for advanced functions' {
            function Test-Function {
                [CmdletBinding()]
                param($Some)

                $Some
                $args
            }

            $Message = '____'

            { Test-Function -Some Things -Are Strict } | Should -Throw -ExpectedMessage $Message
        }
    }

    Context 'Mandatory Parameters' {

    }

    Context 'Parameter Validation' {

    }

    Context 'Handling Pipeline Input' {

        Describe 'ValueFromPipeline' {

        }

        Describe 'ValueFromPipelineByPropertyName' {

        }
    }

    Context 'Permitting Arbitrary Arguments' {

    }

    Context 'Parameter Sets' {

        Describe 'DefaultParameterSetName' {

        }

        Describe '__AllParameterSets' {

        }

        Describe 'Mandatory Parameters & Parameter Sets' {

        }
    }
}
