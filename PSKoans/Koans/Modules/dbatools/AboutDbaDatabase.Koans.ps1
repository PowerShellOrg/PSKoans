#Requires -Modules dbatools
using module PSKoans
[Koan(Position = 1001, Module = 'dbatools')]
param()
<#
    Get-DbaDatabase

    The Get-DbaDatabase command gets SQL database information for each database
    that is present on the target instance(s) of SQL Server by default. If the
    name of the database is provided, the command will return only the specific
    database.
#>
Describe 'Get-DbaDatabase' {

    #region Mocks
    <#
        Let's setup the environment for you. Unless you want your Koans to
        nearly always fail I'd suggest not messing with this bit.
    #>
    BeforeAll {
        Mock -CommandName Get-DbaDatabase -MockWith {
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'testdb'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'LogBackup'
                SizeMB             = '95.275'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:56:36'
                LastDiffBackup     = '26/02/2019 13:00:31'
                LastLogBackup      = '26/02/2019 20:00:02'
            },
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'tempdb'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '46.13'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:57:35'
                LastDiffBackup     = '26/02/2019 13:03:43'
                LastLogBackup      = '26/02/2019 20:02:57'
            },
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'primary'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '29.56'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:59:39'
                LastDiffBackup     = '26/02/2019 13:01:29'
                LastLogBackup      = '26/02/2019 20:04:34'
            },
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'model'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '39.68'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 20:01:03'
                LastDiffBackup     = '26/02/2019 13:02:30'
                LastLogBackup      = '26/02/2019 20:01:19'
            },
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'msdb'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '79.29'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:59:54'
                LastDiffBackup     = '26/02/2019 13:05:07'
                LastLogBackup      = '26/02/2019 20:04:01'
            }
        } -ParameterFilter { $_.SqlInstance -eq 'localhost' }

        Mock -CommandName Get-DbaDatabase -MockWith {
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'testdb'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'LogBackup'
                SizeMB             = '95.275'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:56:36'
                LastDiffBackup     = '26/02/2019 13:00:31'
                LastLogBackup      = '26/02/2019 20:00:02'
            }
        } -ParameterFilter { $_.SqlInstance -eq 'localhost' -and $_.Database -eq 'testdb' }

        Mock -CommandName Get-DbaDatabase -MockWith {
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'tempdb'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '46.13'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:57:35'
                LastDiffBackup     = '26/02/2019 13:03:43'
                LastLogBackup      = '26/02/2019 20:02:57'
            },
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'primary'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '29.56'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:59:39'
                LastDiffBackup     = '26/02/2019 13:01:29'
                LastLogBackup      = '26/02/2019 20:04:34'
            },
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'model'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '39.68'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 20:01:03'
                LastDiffBackup     = '26/02/2019 13:02:30'
                LastLogBackup      = '26/02/2019 20:01:19'
            },
            [PSCustomObject]@{
                ComputerName       = 'Server01'
                InstanceName       = 'MSSQLSERVER'
                SqlInstance        = 'Server01'
                Name               = 'msdb'
                Status             = 'Normal'
                IsAccessible       = 'True'
                RecoveryModel      = 'Full'
                LogReuseWaitStatus = 'Nothing'
                SizeMB             = '79.29'
                Compatibility      = 'Version120'
                Collation          = 'Latin1_General_CI_AS'
                Owner              = 'sa'
                LastFullBackup     = '26/02/2019 19:59:54'
                LastDiffBackup     = '26/02/2019 13:05:07'
                LastLogBackup      = '26/02/2019 20:04:01'
            }
        } -ParameterFilter { $_.SqlInstance -eq 'localhost' -and $_.ExcludeUser }

        Mock -CommandName Get-DbaDatabase -MockWith {
            Import-Clixml -Path .\PSKoans\Koans\dbatools\Mocks\Database_TestDb.xml
        } -ParameterFilter { $_.SqlInstance -eq 'localhost' -and $_.ExludeSystem }
    }
    #endregion

    It 'Gathers databases by SQL Server instance...' {
        <#
            Get-DbaDatabase requires one thing; A SQL Server instance name.
            You can pass in "localhost" for the default name for a SQL Server
            instance.
            The simplest usage of Get-DbaDatabase is to run it and passing in the
            name of the SQL Server instance. This will get information about all
            the databases on the instance.
        #>
        $AllDatabases = Get-DbaDatabase -SqlInstance ____
        $AllDatabases.Count | Should -Be 5
    }

    It 'Gathers database by SQL Server instance and specific name...' {
        <#
            By passing in the SQL Server instance and the name of a specific
            database, using the -Database parameter, we can get information on
            that single database instead.
        #>
        $primaryDatabase = Get-DbaDatabase -SqlInstance localhost -Database ____
        $primaryDatabase.Name | Should -Be 'testdb'
    }

    It 'Gathers system databases only if specified...' {
        <#
            You may want to get only the system databases on an instance.
            While you can pass in the specific names of the system databases, it
            would be easier if there was a parameter you could add that would
            return the system databases.

            A switch parameter like -ExcludeUser.
        #>
        $UserDbParams = @{
            SqlInstance = 'localhost'
            ExcludeUser = $____
        }
        $UserDbsExcluded = Get-DbaDatabase @UserDbParams
        $UserDbsExcluded.Name | Should -BeIn 'tempdb', 'primary', 'model', 'msdb'
    }

    It 'Excludes system databases if specified...' {
        <#
            The same can be done to exclude system databases by providing the
            -ExcludeSystem parameter switch.
        #>
        $SystemDbParams = @{
            SqlInstance  = 'localhost'
            ExludeSystem = ____
        }
        $SystemDbsExluded = Get-DbaDatabase @SystemDbParams
        $SystemDbsExluded.Name | Should -Be 'testdb'
    }

    It 'Gathers databases based on their recovery model...' {
        <#
            Some common questions that people who work with databases
            may have getting databases that are in the 'Full', 'Simple', or
            'BulkLogged' recovery models.
        #>
        $FullRecoveryDbs = Get-DbaDatabase -SqlInstance localhost -RecoveryModel ____
        $FullRecoveryDbs.RecoveryModel | Should -Be 'Full'
    }
}
