# Contributing to the PSKoans Project

Welcome to PSKoans and thank you for your interest in contributing!

There are many ways that you can contribute, beyond writing or coding. The goal of this document is to provide a high-level overview of how you can get involved and how to interact.

## Table of Contents

- [Contributing to the PSKoans Project](#contributing-to-the-pskoans-project)
  - [Table of Contents](#table-of-contents)
  - [Asking Questions](#asking-questions)
  - [Providing Feedback](#providing-feedback)
  - [Reporting Issues](#reporting-issues)
  - [Check for existing issues first](#check-for-existing-issues-first)
    - [Submitting Bug Reports and Feature Requests](#submitting-bug-reports-and-feature-requests)
  - [Contributing](#contributing)
    - [PSKoans Contribution Checklist](#pskoans-contribution-checklist)
    - [Recommended Tools](#recommended-tools)
    - [Getting Started](#getting-started)
      - [Fork the Repository](#fork-the-repository)
      - [Github Desktop](#github-desktop)
      - [PowerShell Git](#powershell-git)
      - [VSCode](#vscode)
    - [Writing Koans](#writing-koans)
      - [Use of Comments](#use-of-comments)
      - [Use of Whitespace](#use-of-whitespace)
      - [Use of Blanks](#use-of-blanks)
    - [Writing Advice Snippets](#writing-advice-snippets)
    - [Notes for Contributors](#notes-for-contributors)

## Asking Questions

Have a question? Open an new issue using the relevant template.
The community will be happy to assist you.
There are no stupid questions! :blush:

## Providing Feedback

Your comments and feedback are welcome, and the PSKoans team is monitoring this GitHub regularly.

## Reporting Issues

Please share any of the following:

- Reproducible problem(s)
- Feature request(s)
- Comments, observations, notations, etc.

## Check for existing issues first

- Enter and monitor PSKoans issues via the [PSKoans GitHub Issues tab][pskoans-issues]. You can sort by author, contributor, label (class), and more here.
- Before you begin creating new issues, search first! Be sure to check out Github's [Advanced Search][advanced-search].
- If you find your issue already exists, contribute relevant comments and add your reaction.

> ProTip: Use a **reaction** response (👍 / 👎) rather than submitting a "+1" comment response.

If you cannot find an existing issue similar to your bug or feature, create a **new** issue using the guidelines below.

### Submitting Bug Reports and Feature Requests

- Please only one issue or feature request per submission.
- Do **not** enumerate multiple bugs or feature requests in the same issue.
- Do not add your issue as a comment to an existing issue unless it's for the identical input.
- Many issues look similar, but may have different causes.
- More information is better, provide sufficient details to reproduce or narrow down the problem.

## Contributing

We have a great many topics to cover, including the near-infinite slew of PowerShell cmdlets that _all_ deserve koan coverage.
Naturally, we're happy to accept any and _all_ help that comes our way!

There are two main ways you can contribute:

1. Feel more than free to clone the repository, make some changes, and submit a pull request!
1. Submit any small changes you'd like make to any of the koans as an issue on the repository, and either myself or one of the helpers here will be happy to talk it over and get it sorted out.

### PSKoans Contribution Checklist

Please remember to do the following:

- [ ] **Search** the issue repository before submitting new issues.
- [ ] **Recreate** the issue to ascertain if it is repeatable.
- [ ] **Simplify** your scenario and isolate the problem if possible.
- [ ] **Document** your findings by providing logs, log snippets and/or screen shots.
- [ ] **Comment** add your comments and observations to existing issues.
- [ ] **Vote** add your vote (via reactions) to existing issues.
- [ ] **Track** your submission and monitor the submission workflow.

### Recommended Tools

If you want to contribute, at the very least, you'll need [a GitHub account][github].
Your development environment is entirely up to you, but the following tools are recommended:

- [ ] [GitHub Desktop][github-desktop]
- [ ] [Visual Studio Code][vscode]

If you're using VS Code, you may find the following extensions useful:

- [ ] [PowerShell Extension for VSCode][vscode-powershell]
- [ ] [PowerShell Preview Extension for VSCode][vscode-powershell-preview]
- [ ] [Code Spell Checker Extension for Visual Studio Code][code-spellcheck]

### Getting Started

The below steps will cover a few possible approaches to a contributing workflow with various popular tools.

#### Fork the Repository

Before getting started, you will need to create your own fork of the PSKoans repository.
To do so, go to [the main page of the repo][pskoans] and click the Fork button at the top right hand side of the page.

#### Github Desktop

1. Setup
    - Download and Install [GitHub Desktop][github-desktop]
    - Sign in to GitHub Desktop with your GitHub account information
    - Configure Git by entering the name and email address you want to make commits with.
1. Clone Repository
    - Option 1
        - On your forked repository page (it should be `https://github.com/$YOURNAME/PSKoans`), click the green "Clone or download" button and then click "Open in Desktop"
    - Option 2
        - Open Desktop and click "Clone a repository from the Internet..."
        - You should see your repositories and should choose the fork you just created.
        - Alternatively, you can hit the URL tab and paste in your URL (`https://github.com/$YOURNAME/PSKoans`)
1. Make Changes!
    - Fix some bugs, write some code! Save your work!
1. Commit
    - Committing saved changes to current branch
        - Once you've made a change and saved it, GitHub Desktop will show the diffs
        - Enter a Summary and Description of your commit and then hit "Commit to main"
            - This with add the changes to a commit on your main branch of your local git copy.
1. Push Origin
    - Hit the "Push origin" button in GitHub Desktop to merge your local repository copy with the copy stored on GitHub.
1. Pull Request
    - Option 1
        - From GitHub Desktop, click the blue "Create Pull Request" button that appears after you hit "Push origin"
        - This will take you to the "Open a pull request" GitHub page comparing your repo / branch against the PSKoans / main branch
    - Option 2
        - Go to Github and do a pull request from the PSKoans main page. the process is the same!
1. Collaborate and have your change approved and merged into the main branch!

#### PowerShell Git

1. Setup
    - Download and Install [Git][git]
        - The only non-default you may want is selecting which editor you want to use as your default.
    - Configure the username you will use for your commit messages.
        - from powershell type: `git config --global user.name "Username"`
    - Configure the email address you will use for your commit messages.
        - from powershell type: `git config --global user.email emailname@email.address`
    - Git is now set up!
1. Clone Repository
    - Create a folder where you would like to put your local repository and Change your PowerShell directory to that location
    - Find the URL of your fork and run: `git clone https://github.com/$YOURNAME/PSKoans`
        - This will make a local copy of your fork.
1. Make Changes!
    - Fix some bugs, write some code! Save your work!
1. Commit
    - Committing saved changes to current branch
        - Committing changes with git directly is a little more work.
        - Run: `git add file.ps1 file2.ps1`
            - This adds the files to the next commit you run, as by default no files are included.
        - Run: `git commit -m "commit summary" -m "commit description"`
            - This takes the files that you ran `git add` against and commits them to your local git repo with -m for your message.
1. Push Origin
    - Check what your origin is by Changing your directory to your repository and running: `git remote -v`
        - This should display `origin https://github.com/$Username/PSKoans`
    - Push
        - Run: `git push origin main` to push your local repo commits to your Github repo.
            - Running this command will pop up a dialog box to log into GitHub to authenticate your push.
1. Pull Request
    - Go to Github and do a pull request from the PSKoans main page.
1. Collaborate and have your change approved and merged into the main branch!

#### VSCode

1. Setup.
    - Download and Install [VSCode][vscode].
    - Download and Install [Git][git] (Follow the setup instructions from the git setup).
1. Clone Repository.
    - Follow the options from either [GitHub Desktop](#github-desktop) or [PowerShell Git](#powershell-git) sections.
1. Make Changes!
    - Fix some bugs, write some code! Save your work!
1. Commit.
    - Hit the "Source Control" button on the left hand side of the VSCode window.
    - Stage your changes.
        - Hit the ➕ on the right side of the files you want to commit.
    - Add a commit message in the "message" box.
    - Hit the ✔️ above the files to commit them to the local repo.
1. Push Origin
    - In the lower left hand corner you should see 0⬇️1⬆️
    - This will push your commits up to the main branch of your fork.
1. Pull Request
    - Go to Github and do a pull request from the PSKoans main page.
1. Collaborate and have your change approved and merged into the main branch!

Your submissions and contributions will be reviewed and processed by the PSKoans maintainers.
You will be notified if any further action is required once your pull request has been reviewed.

There are some questions that do not include any of the above prompts.
These questions implicitly request the Seeker of Enlightenment to remove data that is already in place to pass the test.
In some instances there are comments announcing this fact, but in other there are not.

### Writing Koans

When writing a new koan file, the header of the file _must_ follow this format.

```powershell
using module PSKoans
[Koan(Position = $Index)]
param()
```

`$Index` should be an unsigned integer.
The index indicates the order in which the koans should be sorted.
Try to pick an index that is unused and makes sense in the progression of lessons.
If you think it should be placed between two existing koan files, make sure to modify other indexes as necessary so that we can properly review the pull request.

#### Use of Comments

Always add some introductory comments for the topic being covered just after the header section, so students know what to expect.
Add further comments wherever required.
**All** comments must be written in clear English.

Comments may consist of flavour-text, hints for specific koans, or explanations.

- Flavour-text comments can vary, but should in general be at least tangentially related to the topic at hand.
- Hints may be obtuse where appropriate, but should be clearly relating to the topic at hand.
- Explanatory comments may be as detailed as necessary for individual koans.
- Topic summary / introduction comments may consist of a combination of the above, but should _always_ contain a large proportion of explanatory comments

Both single-line and multi-line comments are acceptable.
For multi-line comments, please use PowerShell's multi-line comment syntax, with the following style:

```powershell
It 'demonstrates comment style' {
    <#
        Comments go here.
        More comments.
    #>
    $true | Should -BeTrue
}
```

Do not use multi-line comment syntax where only a single line of comments is needed.

#### Use of Whitespace

1. Use 4 **spaces** per level of indentation.
2. Use blank lines:
    - Between each `It` block.
    - After an opening `Describe` or `Context` (if it does not contain block comments on the next line).
    - Semantically to separate expected answers from code that does not need to be modified, and to group related lines of code.

#### Use of Blanks

In PSKoans, each question requires the student to insert answers into blank spaces, which will allow the pester tests to pass successfully.
Please utilise the following blank formats when writing koans:

|  Blank   |                 Format                 | Used For                                                                                   |
| :------: | :------------------------------------: | :----------------------------------------------------------------------------------------- |
|   `__`   |           **2** underscores            | Answers that expect numeric input.                                                         |
| `'____'` | **4** underscores in **single quotes** | Answers that expect string inputs.                                                         |
| `"____"` | **4** underscores in **double quotes** | Answers that expect string inputs which may **also** include variables.                    |
| `$____`  |      **$** with **4** underscores      | Answers that expect variable name inputs.                                                  |
|  `____`  |          **four** underscores          | Answers that expect bare strings: command names, hashtable keys, parameter arguments, etc. |

### Writing Advice Snippets

Advice snippets are stored in [the Data/Advice folder][advice] and contain short tips on working with PowerShell or popular modules.
An advice snippet can be retrieved by name or at random with the `Show-Advice` command;
users can use the `Register-Advice` command to automatically add a `Show-Advice` call to your PowerShell Profile script,
which will display a random piece of advice on every PowerShell session start.

All Advice snippets are written in JSON format and stored in category folders under `Data/Advice` in the module directory with an `.Advice.json` suffix.
The JSON files must have the following structure:

```json
{
  "Title": "Snippet Title",
  "Content": [
    "Paragraph 1",
    "Paragraph 2. Additional sentences.",
    "Etc.",
  ]
}
```

Each line of `"Content"` must be a complete paragraph.
A new line will be automatically inserted between each line of the json file when the advice content is written to the console.
Line breaks and one level of indentation are automatically added by the `Write-ConsoleLine` internal function.

If an empty line is desired, enter a line in the json with only a single newline character encoded in JSON notation: `"\n"`.
Do not mix in additional newlines by adding them to the beginning or end of another line.
Where it can be avoided, do not add newlines or other control characters in the middle of advice content lines.

Only one advice snippet can be included in a single JSON file; multiple snippets will require multiple files, each named appropriately.
File names should reflect the `"Title"` element in the JSON, with any spaces and special characters removed.

### Notes for Contributors

The goal of the koans is to help those who have very limited knowledge learn PowerShell.
In order to do that, simplicity and accessibility are key.
There are some advanced topics out there that deserve coverage, and in order to cover them effectively we need to deal with them as clearly and simply as possible.
If you need a hand, don't be afraid to simply submit the pull request before it's ready.
You're more than welcome to submit WIP pull requests for early feedback and to ask for help if you're not sure how to proceed.
We're more than happy to offer our own suggestions and help for your ideas!

> **Note on Compatibility**
>
> PSKoans is designed to function on PowerShell 6 and above, although Windows PowerShell is still supported.
> Please be aware that new users may be working with Linux or Mac operating systems, and that not all features are available on these operating systems.
> For example, the CIM cmdlets are presently only available on Windows.
>
> While we do want to cover platform- or version-specific features, we want to ensure that the module will still function appropriately on other platforms and versions, within reason.
> When covering platform- or version-dependent features of PowerShell, please ensure that you add an appropriate `-Skip` condition to any individual koans that require it.
> If covering in detail a platform-dependent segment, it is recommended that these be confined to individual koan 'Modules' with appropriate restrictions in each file using `#Requires` statements.

If you just want to make a general comment, some recommendations, or if you want to suggest a koan topic to cover, feel free to submit your thoughts as an issue.
I try to keep up to speed with those as best I can. :smile:

**Thank You!**
Your contributions and involvement will help to ensure the growth and success of PSKoans! :blush:

[advanced-search]: https://github.com/search/advanced
[advice]: PSKoans/Data/Advice
[code-spellcheck]: https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker
[git]: https://git-scm.com/downloads
[github]: http://github.com
[github-desktop]: https://desktop.github.com
[pskoans]: https://github.com/PowerShellOrg/PSKoans
[pskoans-issues]: https://github.com/PowerShellOrg/PSKoans/issues
[vscode]: https://code.visualstudio.com
[vscode-powershell]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell
[vscode-powershell-preview]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell-Pre
