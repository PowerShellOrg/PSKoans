function Register-Advice {
    <#
    .SYNOPSIS
        Causes powershell to write a random piece of advice on each start.

    .DESCRIPTION
        Causes powershell to write a random piece of advice on each start.
        This is done by creating / modifying the powershell profile to call `Show-Advice` on each session start.

    .PARAMETER TargetProfile
        Specify a named profile to modify.

    .EXAMPLE
        Register-Advice

        Causes powershell to write a random piece of advice on each start.

    .NOTES
        Author: Friedrich Weinmann (@FriedrichWeinmann)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/Show-Advice.md

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low',
        HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Register-Advice.md')]
    [OutputType([void])]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('AllUsersAllHosts', 'AllUsersCurrentHost', 'CurrentUserAllHosts', 'CurrentUserCurrentHost')]
        [string]
        $TargetProfile = 'CurrentUserCurrentHost'
    )

    $ProfilePath = $Profile.$TargetProfile

    if ($PSCmdlet.ShouldProcess("$TargetProfile PowerShell profile", 'Register Show-Advice')) {
        $ProfileFolder = Split-Path -Path $ProfilePath

        if (-not (Test-Path $ProfileFolder)) {
            New-Item $ProfileFolder -ItemType Directory -Force > $null
        }

        if (-not (Test-Path $ProfilePath)) {
            Set-Content -Path $ProfilePath -Value 'Show-Advice'
        }
        elseif (-not (Select-String  -Path $ProfilePath -Pattern '(Show|Get)-Advice' -Quiet)) {
            'Show-Advice' | Add-Content $ProfilePath
        }
    }
}
