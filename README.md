# PowerShell Koans

[![PSKoans Logo][logo-64]][logo-svg]

## About the Author

### Joel Sallow

- [Blog][blog]
- [Twitter][twitter]

## Synopsis

Inspired by Chris Marinos' **fantastic** [F# koans][fsharp-koans], the goal of the PowerShell koans is to teach you PowerShell by presenting you with a set of questions.
Each [kōan][define-koan] (each question) is represented by a failing Pester test.
Your goal is to make those tests pass by filling out the correct answer, or writing the correct code.
The koans start very simple to get you familiar with the basic concepts and progress towards more difficult.
Teaching you multiple beginner, intermediate and advanced aspects of PowerShell in the process.

To get started please navigate to [prerequisites](#prerequisites) and [getting started](#getting-started).

## Command Reference

View the PSKoans [Command Reference Documentation][reference-docs].

## Prerequisites

- PowerShell version 5.1 / PowerShell 6+
- NuGet (Windows only)
- Pester v4.x

Windows only: If you've never installed PowerShell modules before, you need to first install the NuGet PackageProvider to enable modules to be installed:

```PowerShell
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
```

To install the latest version of Pester, use the appropriate command for your version of PowerShell:

```PowerShell
# PS 5.1 (upgrade to latest Pester)
Install-Module Pester -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion 5.0.2

# PS 6.0+ (Install Pester under current user)
Install-Module Pester -Scope CurrentUser -MinimumVersion 5.0.2
```

## Getting Started

### Install from Gallery

```PowerShell
Install-Module PSKoans -Scope CurrentUser
```

### Or Download the Repo

1. `git clone` the repository into your desired directory.
2. From a normal powershell session run `Get-ChildItem -Recurse | Unblock-File` in that directory to remove the "downloaded from internet" flag that blocks them from running.
3. Check `Get-ExecutionPolicy`: if it says 'Restricted' or 'Undefined', you need to also run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` in order to allow the scripts to run.
4. Add the repository folder to `$env:PSModulePath` so that PowerShell can see it.
   - From the repository main folder, run: `$env:PSModulePath = "$(Get-Location)$([IO.Path]::PathSeparator)${env:PSModulePath}"`

## Start your Journey

### 1. Run `Show-Karma` to start your journey towards PowerShell enlightenment

You will be presented with a page describing your goal:

![Show-Karma result screen, showing zero completed koans][show-karma-1]

Inspect the red messages carefully, most importantly the last one.
The error message contains path to the file that you need to edit in order to progress forward.
In this case, you'll need to examine `Introduction\AboutAssertions.Koans.ps1`.

### 2. Run `Show-Karma -Contemplate` to open your Koans folder

Navigate to `Introduction\AboutAssertions.Koans.ps1`. Near the top you'll see:

```powershell
It 'is a simple comparison' {
    # Some truths are absolute.
    $____ | Should -Be $true
}
```

The `$___` represents a blank for you to fill, and `| Should -Be $true` shows the expected result.
To pass this koan you need to replace `$____` with `$true` to fulfil the assertion: `$true | Should -Be $true`

### 3. Run `Show-Karma` again to see how you did

You passed your first koan!
You'll notice that your overall progress updated to `1/635` and you are presented with the next challenge.

![Show-Karma result screen after completing a single koan, showing one completed koan][show-karma-2]

 You are on your own from here, but the progression should be fairly smooth.
 If you need help, you can always ask around in the PowerShell communities:

- [Slack][ps-slack]
- [Discord][ps-discord]
- [Reddit][ps-reddit]
- [Twitter][ps-twitter]
- [PowerShell.org Forums][ps-forum]

Good luck!

## Backing Up Your Progress

You can see the current folder your copy of the koans is stored in by calling `Get-PSKoanLocation`.
If you want to save a backup of your current progress, simply make a copy of this folder and store it in a safe location.

For example:

```powershell
Get-PSKoanLocation | Copy-Item -Recurse -Destination "D:\Backups\PSKoans"
```

## Maintaining Multiple Koan Libraries

Just as you can `Get-PSKoanLocation`, you can also use `Set-PSKoanLocation` to change the directory that PSKoans will look for.
This allows you to have any number of in-progress libraries of koans on a single machine without moving any folders.

However, be aware that the module does not retain any information about _previous_ locations specified, only the current location.
To change the set location, call `Set-PSKoanLocation` with the path you would like to set.
If the specified folder does not exist, it will be created the next time you call `Show-Karma`.

```powershell
$oldLocation = Get-PSKoanLocation
Set-PSKoanLocation "~/New/PSKoans"

# Call Show-Karma to create the directory and populate it with a fresh koan library
Show-Karma

# Restore the old location
$newLocation = Get-PSKoanLocation
Set-PSKoanLocation $oldLocation

# Call Show-Karma again to check the progress on the old library once again
Show-Karma
```

## Uninstallation

You can uninstall the PSKoans module the usual way you uninstall PowerShell modules, with `Uninstall-Module -Name PSKoans`
This **will not** remove your copy of the koans themselves, which are stored in your user folder, and it will also not remove the configuration file.

To completely remove all of these files, call these commands _before_ you uninstall PSKoans:

```powershell
# To remove configuration settings
Remove-Item -Path "~/.config/PSKoans" -Recurse

# To remove your koan files (THIS WILL COMPLETELY DELETE YOUR PROGRESS)
Get-PSKoanLocation | Remove-Item -Recurse
```

## Contributing

If you would like to contribute to PSKoans, please check out the [Contributing][contributing] document.

## Support the Project

If you would like to support the project, you can:

- [Sponsor me on Github][github-sponsor]
- [Become a Patreon Patron][patreon]
- [Donate with Ko-fi][ko-fi]

[blog]: https://vexx32.github.io
[contributing]: CONTRIBUTING.md
[define-koan]: https://en.wikipedia.org/wiki/K%C5%8Dan
[fsharp-koans]: https://github.com/ChrisMarinos/FSharpKoans
[github-sponsor]: https://github.com/sponsors/vexx32
[ko-fi]: https://ko-fi.com/joelsallow
[logo-64]: images/logo-64px.png
[logo-128]: images/logo-128px.png
[logo-full]: images/logo.png
[logo-svg]: images/logo.svg
[patreon]: https://patreon.com/PSKoans
[ps-discord]: https://j.mp/psdiscord
[ps-forum]: https://powershell.org/forums/forum/windows-powershell-qa/
[ps-reddit]: https://www.reddit.com/r/PowerShell/
[ps-slack]: https://j.mp/psslack
[ps-twitter]: https://twitter.com/hashtag/powershell
[reference-docs]: docs/PSKoans.md
[show-karma-1]: images/Show-Karma_1.png
[show-karma-2]: images/Show-Karma_2.png
[twitter]: https://twitter.com/vexx32
