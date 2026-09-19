#Requires -Modules dbatools
using module PSKoans
[Koan(Position = 1004, Module = 'dbatools')]
param()
<#
    Backup-DbaDatabase

    Backing up a database is crucially important to all who use databases.

    If there is a need to recover data from an earlier time, then backups get used to recover the data.

    There are many filters and options for backing up a database. dbatools helps you to take a backup
    with the Backup-DbaDatabase command.
#>
Describe "Backup-DbaDatabase" {
    
    #region Mocks
    <#
        Let's setup the environment for you. Unless you want the Koans to nearly always fail, I would
        suggest not messing with this bit.
    #>
    BeforeAll {
        Mock -CommandName Backup-DbaDatabase -MockWith {
            $StartDate = [Datetime]::new(2019, 01, 01, 12, 00, 00)
            1..10 | ForEach-Object -Process {
                $RestoreStart = $StartDate
                $RestoreEnd = $StartDate.AddSeconds(10)

                [PSCustomObject]@{
                    ComputerName = 'localhost'
                    SqlInstance  = $ENV:COMPUTERNAME
                    Database     = ('Database_{0:d2}' -f $_)
                    Type         = 'Full'
                    TotalSize    = ('{0}' -f ([Math]::PI * $_))
                    DeviceType   = 'Disk'
                    Start        = $RestoreStart
                    Duration     = $RestoreEnd - $RestoreStart
                    End          = $RestoreEnd
                }
                $StartDate = $RestoreEnd
            }
        }
        Mock -CommandName Backup-DbaDatabase -MockWith {
            $StartDate = [Datetime]::new(2019, 01, 01, 12, 00, 00)
            1..2 | ForEach-Object -Process {
                $RestoreStart = $StartDate
                $RestoreEnd = $StartDate.AddSeconds(15)

                [PSCustomObject]@{
                    ComputerName = 'localhost'
                    SqlInstance  = $ENV:COMPUTERNAME
                    Database     = ('Database_{0:d2}' -f $_)
                    Type         = 'Full'
                    TotalSize    = ('{0}' -f ([Math]::PI * $_))
                    DeviceType   = 'Disk'
                    Start        = $RestoreStart
                    Duration     = $RestoreEnd - $RestoreStart
                    End          = $RestoreEnd
                }

                $StartDate = $RestoreEnd
            }
        } -ParameterFilter {
            $_.Database -contains ('Database_01', 'Database_02')
        }
        Mock -CommandName Backup-DbaDatabase -MockWith {
            $StartDate = [Datetime]::new(2019, 01, 01, 12, 00, 00)
            $RestoreEnd = $StartDate.AddSeconds(5)
            [PSCustomObject]@{
                ComputerName = 'localhost'
                SqlInstance  = $ENV:COMPUTERNAME
                Database     = 'Database_01'
                Type         = 'Differential'
                TotalSize    = ('{0}' -f ([Math]::PI))
                DeviceType   = 'Disk'
                Start        = $StartDate
                Duration     = $RestoreEnd - $StartDate
                End          = $RestoreEnd
            }
        } -ParameterFilter {
            $_.Type -eq 'Differential'
        }
        Mock -CommandName Backup-DbaDatabase -MockWith {
            $StartDate = [Datetime]::new(2019, 01, 01, 12, 00, 00)
            $RestoreEnd = $StartDate.AddSeconds(5)
            [PSCustomObject]@{
                ComputerName = 'localhost'
                SqlInstance  = $ENV:COMPUTERNAME
                Database     = 'Database_01'
                Type         = 'Differential'
                TotalSize    = ('{0}' -f ([Math]::PI))
                DeviceType   = 'Disk'
                Start        = $StartDate
                Duration     = $RestoreEnd - $StartDate
                End          = $RestoreEnd
                Path         = 'E:\Backups\Database_01_201901011200.bak'
            }
        } -ParameterFilter {
            $_.Path -like 'E:\Backups\*'
        }
        Mock -CommandName Backup-DbaDatabase -MockWith {
            $StartDate = [Datetime]::new(2019, 01, 01, 12, 00, 00)
            $RestoreEnd = $StartDate.AddSeconds(5)
            [PSCustomObject]@{
                ComputerName = 'localhost'
                SqlInstance  = $ENV:COMPUTERNAME
                Database     = 'Database_01'
                Type         = 'Differential'
                TotalSize    = ('{0}' -f ([Math]::PI))
                DeviceType   = 'Disk'
                Start        = $StartDate
                Duration     = $RestoreEnd - $StartDate
                End          = $RestoreEnd
                Path         = 'E:\Backups\Database01-Full.bak'
            }
        } -ParameterFilter {
            $_.FilePath -eq 'dbname-backuptype.bak'
        }
    }
    #endregion

    It 'takes a database backup of all SQL Server databases' {
        <#
            By default, Backup-DbaDatabase will backup every database on the SQL Instance.
            These backups will get saved to the default backup directory.
            Complete the below command to backup all the databases on the localhost instance.
        #>
        $AllBackups = Backup-DbaDatabase -SqlInstance '____'
        $AllBackups.ComputerName | Should -Be 'localhost'
    }

    It 'takes a database backup of specific SQL Server databases' {
        <#
            By using the -Database parameter, you can backup a single or many databases.
            Complete the below command to backup the databases Database_01 and Database_02
        #>
        $SpecificBackups = Backup-DbaDatabase -SqlInstance localhost -Database '____','____'
        $SpecificBackups.Database | Should -Contain 'Database_01', 'Database_02'
    }

    It 'takes different types of SQL Server backups' {
        <#
            There are different types of database backups that can be taken. The 3 main ones
            are a Full backup (Full/Database), a Differential backup (Diff/Differential), and
            a Transaction Log backup (Log).
            Backup-DbaDatabase can take each of these types of backups.
            Complete the below command to take a differential backup of the Database_01 database.
        #>
        $DifferentialBackup = Backup-DbaDatabase -SqlInstance localhost -Database Database_01 -Type '____'
        $DifferentialBackup.Type | Should -Be 'Differential'
    }

    It 'takes backups and stores them at a specific location' {
        <#
            Managing where you store your backups is something that is unique to each person.
            Backup-DbaDatabase allows you to specify where you want the backups to be stored.
            It allows this specification by using the -Path parameter.
            Complete the below command to store the backup file in the E:\Backups\ folder.
        #>
        $SpecificPathBackup = Backup-DbaDatabase -SqlInstance localhost -Database Database_01 -Path '____'
        $SpecificPathBackup.Path | Should -BeLike 'E:\Backups\'
    }

    It 'takes backups and substitutes keywords such as database name and database backup type' {
        <#
            There are different conventions for specifying where the backup file will go to
            and what the backup file will be called. There are different keywords that 
            dbatools provides that can be used with the -FilePath and -ReplaceInName.
                instancename - will be replaced with the instance name
                servername - will be replaced with the server name
                dbname - will be replaced with the database name
                timestamp - will be replaced with the timestamp
                backuptype - will be replaced with Full, Log or Differential as appropriate.
            Complete the below command to backup the database "Database01" as "Database01-Full.bak"
        #>
        $KeywordBackup = Backup-DbaDatabase -SqlInstance localhost -Database Database01 -FilePath '____-____.bak' -ReplaceInName
        $BackupFileName = Split-Path $KeywordBackup.Path -Leaf
        $BackupFileName | Should -Be 'Database01-Full.bak'
    }
}
