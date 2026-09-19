using module PSKoans
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSProvideCommentHelp',
    '',
    Justification = 'Test-ModuleFunction is throwaway scaffolding dynamically written to a demo module file for this exercise; formal help is not warranted.'
)]
[Koan(Position = 212)]
param()
<#
    Modules

    PowerShell is built from various types of modules, which come in three flavours:
        - Script modules
        - Manifest modules
        - Binary modules

    Manifest modules are the least common, consisting only of a single .psd1 file;
    their primary code is often stored in a core library of PowerShell and is not
    considered part of 'the module' itself, merely exposed by it.

    Binary modules are compiled from C# using the PowerShell libraries and tend to
    be in .dll formats with other files providing metadata.

    Script modules commonly consist of .psm1, .psd1, .ps1 and other files, and are
    one of the more common module types.
#>
Describe 'Get-Module' {
    <#
        Get-Module is used to find out which modules are presently loaded into
        the session, or to search available modules on the computer.
    #>
    It 'returns a list of modules in the current session' {
        <#
            By default, Get-Module returns modules currently in use.
            To get a list of all modules on the system, you can use the -ListAvailable switch.
        #>
        $Modules = Get-Module | Sort-Object -Property Name -Unique

        $FirstThreeModules = $Modules | Select-Object -First 3
        $VersionOfThirdModule = $FirstThreeModules[2].Version
        $TypeOfLastModule = $Modules |
            Select-Object -Last 1 |
            ForEach-Object -MemberName ModuleType

        @('____', '____', '____') | Should -Be $FirstThreeModules.Name
        '____' | Should -Be $VersionOfThirdModule
        '____' | Should -Be $TypeOfLastModule
    }

    It 'can filter by module name' {
        $Pester = Get-Module -Name 'Pester'
        $PesterCommands = $Pester.ExportedCommands.Values.Name

        @('____', '____', '____') | Should -BeIn $PesterCommands
    }

    It 'can list nested modules' {
        $AllModules = Get-Module -All

        $Axioms = $AllModules | Where-Object Name -eq 'Axiom'
        $AxiomsCommands = $Axioms.ExportedCommands.Values.Name

        $Commands = @('____', '____', '____')
        $Commands | Should -BeIn $AxiomsCommands
        <#
            Despite us being able to 'see' this module, we cannot use its commands;
            it is only available within the scope of the Pester module itself,
            since it's a nested module within Pester.
        #>
        {
            if ($Commands[1] -in $Axioms.ExportedCommands.Values.Name) {
                & $Commands[1]
            }
        } | Should -Throw
    }
}

Describe 'Find-Module' {
    <#
        Find-Module is very similar to Get-Module, except that it searches all
        registered PSRepositories in order to find a module available for
        install.
    #>
    BeforeAll {
        <#
            This will effectively produce similar output to the Find-Module cmdlet
            while only searching the local modules instead of online ones. 'Mock'
            is a Pester command that will be covered later.
        #>
        Mock Find-Module {
            Get-Module -ListAvailable -Name $Name |
                Select-Object -Property Version, Name, @{
                    Name       = 'Repository'
                    Expression = {'PSGallery'}
                }, Description
        }

        $script:Module = Find-Module -Name 'Pester' | Select-Object -First 1
    }

    It 'finds modules that can be installed' {
        '____' | Should -Be $Module.Name
    }

    It 'lists the latest version of the module' {
        '____' | Should -Be $Module.Version
    }

    It 'indicates which repository stores the module' {
        <#
            Unless an additional repository has been configured, all modules
            from Find-Module will come from the PowerShell Gallery.
        #>
        '____' | Should -Be $Module.Repository
    }
    It 'gives a brief description of the module' {
        '____' | Should -Match  $Module.Description
    }
}

Describe 'New-Module' {
    <#
        New-Module is rarely used in practice, but is capable of dynamically generating
        a module in-memory without needing a file on disk.
    #>
    BeforeAll {
        $script:Module = New-Module -Name 'PSKoans_TestModule' -ScriptBlock {}
    }

    It 'creates a dynamic module object' {
        $Module | Should -Not -BeNullOrEmpty
    }

    It 'has many properties with $null defaults' {
        <#
            RootModule is usually the script file or .dll that contains the main portion of the module's code.
            For a module like this, that property is meaningless -- there is no such file.
        #>
        $____ | Should -Be $Module.RootModule
    }

    It 'uses an existing filesystem location as the ModuleBase' {
        <#
            In most cases, the ModuleBase for a dynamically generated module will be the current location.
            This may not be accurate in all cases, depending on scoping.
        #>
        '____' | Should -Be $Module.ModuleBase
    }

    AfterAll {
        $Module | Remove-Module
    }
}

Describe 'Import-Module' {
    <#
        Import-Module is an auxiliary cmdlet that imports the requested module
        into the current session. It is capable of both importing
    #>
    Context 'Importing Installed Modules' {
        BeforeAll {
            $script:Module = New-Module -Name 'PSKoans_ImportModuleTest' { }
        }

        It 'does not produce output' {
            Import-Module $Module | Should -BeNull
        }

        It 'imports the module into the current session' {
            $ImportedModule = Get-Module -Name 'PSKoans_ImportModuleTest'

            $ImportedModule.ExportedCommands.Keys | Should -BeNull
            '____' | Should -Be $ImportedModule.Name
        }
    }

    Context 'Importing Module From File' {
        BeforeAll {
            $ModuleScript = {
                function Test-ModuleFunction {
                    '____' # Fill in the correct value here
                }
                Export-ModuleMember 'Test-ModuleFunction'
            }
            $ModuleScript.ToString() | Set-Content -Path 'TestDrive:\TestModule.psm1'
        }

        It 'does not produce output' {
            Import-Module 'TestDrive:\TestModule.psm1' | Should -BeNullOrEmpty
        }

        It 'imports the module into the current session' {
            $ImportedModule = Get-Module -Name '____'
            $ImportedModule | Should -Not -BeNullOrEmpty
        }

        It 'makes the exported commands from the module available for use' {
            $ImportedModule = Get-Module -Name '____'
            @('____') | Should -Be $ImportedModule.ExportedCommands.Values.Name

            Test-ModuleFunction | Should -BeExactly 'A successful test.'
        }
    }

    AfterAll {
        Remove-Module -Name 'TestModule', 'PSKoans_ImportModuleTest'
    }
}
<#
    Other *-Module Cmdlets

    Check out the other module cmdlets with:

        Get-Help *-Module
        Get-Command -Noun Module

    You'll need Install-Module to install new ones, at least!
#>
