using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseSingularNouns',
    '',
    Justification = 'Add-Numbers is a minimal in-exercise example function; naming is incidental to the order-of-operations lesson.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPositionalParameters',
    '',
    Justification = 'Positional argument passing is the exact subject of this lesson, and the __ blank is invoked as a bare positional command by design.'
)]
[Koan(Position = 118)]
param()
<#
    Order of Operations

    In PowerShell, the order of operations needs to be taken into account,
    sometimes even more so than other languages. Because all native functions
    and cmdlets take space-separated arguments, any expressions needing
    evaluation need to be explicitly separated with parentheses in many cases.

    In general, PowerShell follows PEMDAS, although it has no native exponential
    operator. Parentheses always get evaluated first (from inner to outer if
    nested), but expressions cannot be passed as arguments without being forced
    to evaluate first.
#>
Describe "Order of Operations" {

    It "requires parameter argument expressions to be enclosed in parentheses" {
        function Add-Numbers {
            param(
                [int]
                $Number1,
                [int]
                $Number2
            )
            return $Number1 + $Number2
        }
        # Be wary of open spaces when passing an expression as a function argument.
        $Sum = Add-Numbers (4 + 1) 18
        __ | Should -Be $Sum
        Add-Numbers 3 * 4 7 | Should -Be 19 # Add parentheses to the function call to make this true.
    }

    It "will evaluate an entire expression if it is the first element in a pipeline" {
        # A pipe character evaluates everything before it on the line before
        # passing along the value(s).
        __ + 7 | Should -Be 11
        __ * 3 + 11 | Should -Be 35
    }

    It "otherwise follows standard mathematical rules" {
        # Although PowerShell doesn't have a native exponentiation operator,
        # we do have [Math]::Pow($base, $power)
        $Value = 3 + 4 / [Math]::Pow(2, 3)
        __ | Should -Be $Value
    }
}
