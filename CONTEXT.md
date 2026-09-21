# PSKoans

A PowerShell learning framework, structured as a set of guided exercises ("koans") that teach the language by making failing tests pass.

## Language

### Core learning loop

**Koan**:
A single named Pester `It` test representing one question. The learner makes it pass by replacing its Blank(s) with the correct value or expression.
_Avoid_: exercise, question, test (unqualified)

**Blank**:
The placeholder token (`__`, `____`, `$____`, `'____'`) inside a Koan that the learner must replace to make it pass. Also the name of the `[Blank]` sentinel class used as the default value in some koans — every comparison against it fails until replaced.
_Avoid_: placeholder, stub

**Karma**:
The learner's aggregate progress: the count of Koans passed versus the total, across whatever scope was requested. Computed by running the Koans through Pester and reported by `Get-Karma` / `Show-Karma`.
_Avoid_: score, progress (unqualified)

**Meditation** / **Meditation Prompt**:
The console report `Show-Karma` displays after evaluating Karma: either the next failing Koan's context (Describe/It names, expectation, current line) or a completion message.
_Avoid_: results, report

### Content organization

**Topic**:
A `*.Koans.ps1` file holding a themed set of Koans (e.g. `AboutArrays`, `AboutComparison`). Identified by its base filename and tagged with a `[Koan(...)]` attribute.
_Avoid_: koan file, lesson, chapter

**Kata**:
An advanced Topic (under `Koans/Katas`) that applies several concepts together in a realistic problem, as opposed to the single-concept introductory Topics.
_Avoid_: exercise, challenge

**Module** (koan grouping):
A named grouping of Topics scoped to a third-party PowerShell module (e.g. `ActiveDirectory`, `dbatools`), stored under `Koans/Modules/<Name>`. The core, always-present Topics live in the reserved `_powershell` module.
_Avoid_: unqualified "module" when a real PowerShell module is meant — this repo overloads the word deliberately (`Get-PSKoan -Module ActiveDirectory`); qualify explicitly ("koan module" vs. "PowerShell module") when ambiguous.

**Position**:
The ordering value (`[Koan(Position = ...)]`) on a Topic file that controls where it falls in the learner's progression sequence within its Module.
_Avoid_: order, index

### Progress & environment

**Koan Library** / **Koan Location**:
The learner's local, mutable copy of Topic files (path returned by `Get-PSKoanLocation`), edited in place to solve Koans. Distinct from the module's own canonical copy, which `Update-PSKoan` and `Reset-PSKoan` treat as the source of truth.
_Avoid_: koans folder (ambiguous between the two copies)

**Advice**:
A short, standalone motivational or informational tip (stored as `*.Advice.json`), shown by `Show-Advice` / `Register-Advice` on session start. Unrelated to Koan content or progress.
_Avoid_: tip, hint (hint risks confusion with in-koan guidance)
