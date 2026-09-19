[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'Command',
    Justification = 'false positive'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'Parameter',
    Justification = 'false positive'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'CommandAst',
    Justification = 'false positive'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'FakeBoundParams',
    Justification = 'false positive'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    'WordToComplete',
    Justification = 'used only inside a nested .Where{} scriptblock, which PSScriptAnalyzer does not trace back to the enclosing param'
)]
param()

$CommandName = @(
    'Get-Karma'
    'Get-PSKoan'
    'Reset-PSKoan'
    'Show-Karma'
    'Update-PSKoan'
)

$AdviceCommandName = @(
    'Show-Advice'
    'Get-Advice'
)

#region Topic completer

$RegisterParams = @{
    CommandName   = $CommandName
    ParameterName = 'Topic'
    ScriptBlock   = {
        param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

        $Values = (Get-PSKoan -Scope Module -IncludeModule * -SkipAttributeParsing).Topic
        return @($Values) -like "$WordToComplete*"
    }
}
Register-ArgumentCompleter @RegisterParams

#endregion

#region Module / IncludeModule completer

$RegisterParams = @{
    CommandName   = $CommandName
    ParameterName = 'Module'
    ScriptBlock   = {
        param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

        $Values = $script:ModuleRoot |
            Join-Path -ChildPath 'Koans/Modules' |
            Get-ChildItem -Directory |
            Select-Object -ExpandProperty Name

        return @($Values) -like "$WordToComplete*"
    }
}
Register-ArgumentCompleter @RegisterParams

$RegisterParams.ParameterName = 'IncludeModule'
Register-ArgumentCompleter @RegisterParams

#endregion

#region Name completer for *-Advice command names

$RegisterParams = @{
    CommandName   = $AdviceCommandName
    ParameterName = 'Name'
    ScriptBlock   = {
        param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

        $Values = $script:ModuleRoot |
            Join-Path -ChildPath 'Data/Advice' |
            Get-ChildItem -File -Recurse |
            Select-Object @{
                Name       = 'Name';
                Expression = { $_.BaseName.Replace('.Advice', '') }
            } |
            Select-Object -ExpandProperty Name

        return @($Values) -like "$WordToComplete*"
    }
}
Register-ArgumentCompleter @RegisterParams

#endregion

#region Setting completer

$RegisterParams = @{
    CommandName   = 'Get-PSKoanSetting', 'Set-PSKoanSetting'
    ParameterName = 'Name'
    ScriptBlock   = {
        param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

        $Settings = & (Get-Module PSKoans) { $script:DefaultSettings }
        return $Settings.Keys.Where{ $_ -like "$WordToComplete*" }.ForEach{
            [System.Management.Automation.CompletionResult]::new(
                $_, <# completionText #>
                $_, <# listItemText #>
                'ParameterValue', <# completionResultType #>
                $_ <# toolTip #>
            )
        }
    }
}
Register-ArgumentCompleter @RegisterParams

#endregion
