@{
    # PSKoans organization default PSScriptAnalyzer ruleset.
    # Run every rule PSScriptAnalyzer ships as part of its default (non-formatting) set, at every
    # severity, so nothing is silently hidden from `Invoke-psake Analyze`. Only exclude a rule here
    # when it is fundamentally inapplicable to this codebase; every exclusion carries a justification.
    #
    # NOTE: deliberately no `Severity` key -- setting one filters diagnostics by their own Severity
    # value, which silently drops ParseError-severity records (e.g. `using module` resolution
    # failures) with no way to see or document what was suppressed.
    IncludeDefaultRules = $true

    ExcludeRules        = @(
        # PSKoans is an interactive console teaching tool -- Write-ConsoleLine (and the koan output
        # it powers) uses Write-Host by design to render colored console text, not as ad-hoc logging.
        'PSAvoidUsingWriteHost',

        # PSKoans.psd1 sets VariablesToExport = '*' deliberately: koan/library-generated variables
        # aren't statically enumerable at manifest-authoring time.
        'PSUseToExportFieldsInManifest'
    )
}
