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
[CmdletBinding(DefaultParameterSetName = 'task')]
param(
    [parameter(ParameterSetName = 'task', Position = 0)]
    [ArgumentCompleter( {
            param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            try {
                Get-PSakeScriptTasks -BuildFile (Join-Path $PSScriptRoot 'psakeFile.ps1') -ErrorAction 'Stop' |
                    Where-Object { $_.Name -like "$WordToComplete*" } |
                    Select-Object -ExpandProperty 'Name'
            }
            catch {
                @()
            }
        })]
    [string[]]$Task = 'default',
    [switch]$Bootstrap,
    [parameter(ParameterSetName = 'Help')]
    [switch]$Help
)

$ErrorActionPreference = 'Stop'
$requirementsFile = Join-Path $PSScriptRoot 'requirements.psd1'
$psakeFile = Join-Path $PSScriptRoot 'psakeFile.ps1'

$requirements = Import-PowerShellDataFile -Path $requirementsFile
$pesterRequirement = $requirements.Pester
$requirements.Remove('Pester')

if ($Bootstrap) {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
    }
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Install-Module -Name PSDepend -Repository PSGallery -Scope CurrentUser -Force -RequiredVersion '0.3.8'
    }
}

Import-Module -Name PSDepend -Verbose:$false
if ($Bootstrap) {
    Invoke-PSDepend -Path $requirementsFile -Install -Force -WarningAction SilentlyContinue
}

# PowerShellBuild requires Pester without an upper bound. Load the pinned version
# first, then import the remaining dependencies without re-importing Pester.
Import-Module -Name Pester -RequiredVersion $pesterRequirement.Version
Invoke-PSDepend -InputObject $requirements -Import -Force -WarningAction SilentlyContinue

if ($PSCmdlet.ParameterSetName -eq 'Help') {
    Get-PSakeScriptTasks -BuildFile $psakeFile |
        Format-Table -Property Name, Description, Alias, DependsOn
}
else {
    Set-BuildEnvironment -Force
    Invoke-Psake -BuildFile $psakeFile -TaskList $Task -NoLogo
    exit ([int](-not $psake.build_success))
}
