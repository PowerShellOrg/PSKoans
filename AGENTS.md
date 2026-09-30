## Build & test

Build is psake-driven via `build.ps1`, which wraps `psakeFile.ps1` (PowerShellBuild-based).

- First-time setup (installs PSDepend/PowerShellBuild/Pester into the current user scope): `.\build.ps1 -Bootstrap -Task Init`. Without `-Task Init`, `-Bootstrap` still installs deps but then falls through to the `Default` task (`Test`).
- Run the full test suite (stages the module, then runs PSScriptAnalyzer + Pester): `.\build.ps1 -Task Test`
- Run only Pester, without analysis: `.\build.ps1 -Task Pester`
- Stage the module without testing: `.\build.ps1 -Task Build`
- List all available tasks: `.\build.ps1 -Help`
- No `-Task` runs the `Default` task, which depends on `Test`.

Test results land at `out/testResults.xml` (JUnitXml). PSScriptAnalyzer failures at `Error` severity fail the build.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (PowerShellOrg/PSKoans) via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
