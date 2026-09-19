[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'ActualValue',
    Justification = 'Pester always passes the tested value as the first positional argument to a -Test scriptblock; this assertion ignores it because it always fails.'
)]
param()

if ('Fail' -notin (Get-ShouldOperator).Name) {
    Add-ShouldOperator -Name Fail -Test {
        param ($ActualValue, [switch] $Negate, [string] $Because)

        if ($Negate) {
            return [PSCustomObject]@{
                Succeeded      = $false
                FailureMessage = "Should -Not -Fail is not a valid assertion."
            }
        }

        if (-not $Because) {
            $Message = "The test failed, because the script reached the Should -Fail command call."
        }
        else {
            $Reason = ($Because.Trim().TrimEnd('.') -replace '^because\s', '')
            $Message = "The test failed, because $Reason."
        }

        [PSCustomObject]@{
            Succeeded      = $false
            FailureMessage = $Message
        }
    }
}
