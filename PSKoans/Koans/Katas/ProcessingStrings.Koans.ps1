using module PSKoans
using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'Data',
    Justification = 'Get-GreatestVarianceDate is a solution stub the learner implements; $Data is unused until solved.'
)]
[Koan(Position = 150)]
param()
<#
    Kata: Processing Strings

    Below is a list containing comma separated data about Microsoft's stock prices
    during March of 2012. Without modifying the list, programatically find the day
    with the greatest variance between the opening and closing price.

    The following operations may be of use:

    [double] $value           # Casts (converts) the value into numerical data
    $String -split ','        # Creates an array by splitting the string

    Be sure to review AboutStrings, AboutArrays and the other foundation Koans
    you've done so far if you get stuck!

    Testimonial:
    "Can someone give me a hint on how to do this, I feel stupid."
    -Puzzled PowerShell Newbie

    "I might have to steal this for a 'testimonials' section; that's exactly what the katas are meant for :D."
    -Joel
#>
Describe "The Stock Challenge" {

    BeforeAll {
        $script:StockData = @(
            "Date,Open,High,Low,Close,Volume,Adj Close"
            "2012-03-30,32.40,32.41,32.04,32.26,31749400,32.26"
            "2012-03-29,32.06,32.19,31.81,32.12,37038500,32.12"
            "2012-03-28,32.52,32.70,32.04,32.19,41344800,32.19"
            "2012-03-27,32.65,32.70,32.40,32.52,36274900,32.52"
            "2012-03-26,32.19,32.61,32.15,32.59,36758300,32.59"
            "2012-03-23,32.10,32.11,31.72,32.01,35912200,32.01"
            "2012-03-22,31.81,32.09,31.79,32.00,31749500,32.00"
            "2012-03-21,31.96,32.15,31.82,31.91,37928600,31.91"
            "2012-03-20,32.10,32.15,31.74,31.99,41566800,31.99"
            "2012-03-19,32.54,32.61,32.15,32.20,44789200,32.20"
            "2012-03-16,32.91,32.95,32.50,32.60,65626400,32.60"
            "2012-03-15,32.79,32.94,32.58,32.85,49068300,32.85"
            "2012-03-14,32.53,32.88,32.49,32.77,41986900,32.77"
            "2012-03-13,32.24,32.69,32.15,32.67,48951700,32.67"
            "2012-03-12,31.97,32.20,31.82,32.04,34073600,32.04"
            "2012-03-09,32.10,32.16,31.92,31.99,34628400,31.99"
            "2012-03-08,32.04,32.21,31.90,32.01,36747400,32.01"
            "2012-03-07,31.67,31.92,31.53,31.84,34340400,31.84"
            "2012-03-06,31.54,31.98,31.49,31.56,51932900,31.56"
            "2012-03-05,32.01,32.05,31.62,31.80,45240000,31.80"
            "2012-03-02,32.31,32.44,32.00,32.08,47314200,32.08"
            "2012-03-01,31.93,32.39,31.85,32.29,77344100,32.29"
            "2012-02-29,31.89,32.00,31.61,31.74,59323600,31.74"
        )

        <#
            For the purposes of the exercise, use of cmdlets will be disabled for the solving function.
            You're on your own here, use your knowledge of arrays and string operators to get you to
            the finish line!
        #>

        $script:Verification = {
            $Functions = [Hashset[string]]::new([StringComparer]::OrdinalIgnoreCase)
            $Ast = (Get-Command 'Get-GreatestVarianceDate' -CommandType Function).ScriptBlock.Ast
            $Ast.FindAll(
                {
                    param($node)
                    if ($node -is [CommandAst] -and ($name = $node.GetCommandName()) -and !$Functions.Contains($name)) {
                        throw 'Usage of external cmdlets and functions is not permitted.'
                    }

                    if ($node -is [FunctionDefinitionAst]) {
                        $Functions.Add($node.Name) > $null
                        return
                    }

                    if ($node.Left -is [VariableExpressionAst] -and $node.Left.VariablePath.DriveName -eq 'Function') {
                        $Functions.Add($node.Left.VariablePath.UserPath -replace '^function:') > $null
                    }
                }, $true
            )
        }

        function Get-GreatestVarianceDate {
            param([string[]]$Data)

            # Add the solution code here!

        }
    }

    <#
        Feel free to add extra It/Should tests here to write tests for yourself and
        experiment along the way!
    #>

    It 'should not use any cmdlets or external commands' {
        $Verification | Should -Not -Throw -Because "You must not rely on the power of others here."
    }

    It 'should determine the correct answer' {
        Get-GreatestVarianceDate -Data $StockData | Should -Be "2012-03-13"
    }
}
