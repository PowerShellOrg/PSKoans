#Requires -Modules dbatools
using module PSKoans
[Koan(Position = 1002, Module = 'dbatools')]
param()
<#
    Invoke-DbaQuery

    The default language for querying SQL Server is T-SQL. To run explicit T-SQL commands or files,
    the function Invoke-DbaQuery was created.

    Based off of Invoke-Sqlcmd, Invoke-DbaQuery was designed to be more convenient to use in a pipeline
    and behave in a way that is consistent with the rest of the dbatools functions.
#>
Describe "Invoke-DbaQuery" {

    #region Mocks
    <#
        Let's setup the environment for you. Unless you want the Koans to nearly always fail, I would
        suggest not messing with this bit.
    #>
    BeforeAll {
        Mock -CommandName Invoke-DbaQuery -MockWith {
            Import-Clixml -Path .\PSKoans\Koans\dbatools\Mocks\BasicInvokeDbaQuery.xml
        } -ParameterFilter { $_.Query -eq "SELECT DB_NAME() AS database_name;" }
        Mock -CommandName Invoke-DbaQuery -MockWith {
            Import-Clixml -Path .\PSKoans\Koans\dbatools\Mocks\StudentTable.xml
        } -ParameterFilter { $_.Query -eq "SELECT PersonName FROM Student" }
        Mock -CommandName Invoke-DbaQuery -MockWith {
            Import-Clixml -Path .\PSKoans\Koans\dbatools\Mocks\SqlParamInvokeDbaQueryBob.xml
        } -ParameterFilter { $_.Query -eq 'SELECT PersonName FROM Student WHERE PersonName = @name' -and $_.SqlParameters.name -eq 'Bob' }
        Mock -CommandName Invoke-DbaQuery -MockWith {
            Import-Clixml -Path .\PSKoans\Koans\dbatools\Mocks\SqlParamInvokeDbaQueryFrank.xml
        } -ParameterFilter { $_.Query -eq 'SELECT PersonName FROM Student WHERE PersonName = @name' -and $_.SqlParameters.name -eq 'Robert' }
        Mock -CommandName Invoke-DbaQuery -MockWith {
            Import-Clixml -Path .\PSKoans\Koans\dbatools\Mocks\StudentTableBobbySafe.xml
        } -ParameterFilter {
            $_.Query -eq 'INSERT INTO Student (PersonName) VALUES (@name); SELECT PersonName FROM Student;' -and
            $_.SqlParameters.name -eq "Robert'); DROP TABLE Student;--"
        }
        Mock -CommandName Invoke-DbaQuery -MockWith {
            $null
        } -ParameterFilter {
            $_.Query -eq "INSERT INTO Student (PersonName) VALUES ('$name')" -and
            $name -eq "ROBERT'); DROP TABLE Student;--"
        }
    }
    #endregion

    It 'Queries a SQL Server instance...' {
        <#
            Invoke-DbaQuery can be used to connect to the SQL Server, in much the same way that Get-DbaDatabase
            does, by using the -SqlInstance parameter.
            Complete the below command to query "localhost" using Invoke-DbaQuery.
        #>
        $Bar = Invoke-DbaQuery -SqlInstance __ -Query "SELECT DB_NAME() AS database_name;"
        $Bar.database_name | Should -Be 'primary'
    }

    It 'Queries multiple SQL Server instances...' {
        <#
            Invoke-DbaQuery allows you to query a single database, multiple databases, or even multiple
            servers.
            The T-SQL command @@SERVERNAME returns the name of the server that the database is on. We can
            use this to see what instance we are connected to.
        #>
        $ManyServers = 'localhost', 'localhost\SQLDEV2K14' | Invoke-DbaQuery -Query "SELECT @@SERVERNAME AS __;"
        $ManyServers.server_name | Should -BeIn 'localhost', 'localhost\SQLDEV2K14'
    }

    It 'queries a database from a named sql file' {
        <#
            It is possible to save T-SQL scripts into files. Invoke-DbaQuery has the ability to use the
            -File parameter, by passing in the location of the file, to run the T-SQL scripts against the
            instance.
            We've created a file called SimpleTSQL.sql that contains a T-SQL statement, which we want to
            run against the tempdb database on the localhost instance.
        #>
        Out-File -FilePath TestDrive:\SimpleTSQL.sql -InputObject "SELECT 'From a File' AS Origin;"
        $InvokeDbaQueryParams = @{
            SqlInstance = 'localhost'
            Database    = 'tempdb'
            File        = '__'
        }
        $DbResult = Invoke-DbaQuery @InvokeDbaQueryParams
        $DbResult.Origin | Should -Be 'From a File'
    }

    It 'queries a database with passing values to parameters' {
        <#
            T-SQL may seem like a strict, rigid language. We have a script that returns a value or values.
            If we want to get different values then we will have to change the full query.
            From
                "SELECT PersonName FROM Student WHERE PersonName = 'Bob';"
            to
                "SELECT PersonName FROM Student WHERE PersonName = 'Robert';"
            In the above example, we only want to change what the name is equal to. Invoke-DbaQuery allows
            you to specify what this value is equal to by passing in a parameter.
            All we have to do is pass in a hashtable with the name of the parameter and the value we want.
        #>
        $InvokeDbaQueryParam01 = @{
            SqlInstance = 'localhost'
            Database = 'tempdb'
            Query = 'SELECT PersonName FROM Student WHERE PersonName = @name'
            SqlParameters = @{ name = 'Bob' }
        }
        $SqlParamResult01 = Invoke-DbaQuery @InvokeDbaQueryParam01
        $SqlParamResult01.PersonName | Should -Be 'Bob'

        $InvokeDbaQueryParam02 = @{
            SqlInstance = 'localhost'
            Database = 'tempdb'
            Query = 'SELECT PersonName FROM Student WHERE PersonName = @name'
            SqlParameters = @{ name = __ }
        }
        $SqlParamResult02 = Invoke-DbaQuery @InvokeDbaQueryParam02
        $SqlParamResult02.PersonName | Should -Be 'Robert'
    }

    It 'shows Little Bobby Tables...' {
        <#
            You may ask "Why would I want to use parameters? I can just pass in a variable from PowerShell!"
            If you are familiar with Little Bobby Tables (https://xkcd.com/327/) then you are aware of the
            dangers of un-sanitized inputs.
            However, an example is nearly always better than a lecture.

            Take these 3 lines of code below.

            The first code sample returns data from a table called Students.
            The second code sample inserts the name "Robert'); DROP TABLE Student;--" into the table using
            parameters and then returns the results.
            The third code sample inserts the name "Robert'); DROP TABLE Student;--" into the table using
            PowerShell variables and then returns the results.
        #>
        $InvokeDbaQueryParamStudents = @{
            SqlInstance = 'localhost'
            Database = 'tempdb'
            Query = 'SELECT PersonName FROM Student;'
        }
        $StudentResult01 = Invoke-DbaQuery @InvokeDbaQueryParamStudents
        $StudentResult01 | Should -Contain 'Bob', 'Robert'

        $InvokeDbaQueryInsertParamStudents = @{
            SqlInstance = 'localhost'
            Database = 'tempdb'
            Query = 'INSERT INTO Student (PersonName) VALUES (@name); SELECT PersonName FROM Student;'
            SqlParameters = @{ name = "Robert'); DROP TABLE Student--" }
        }
        $StudentResult02 = Invoke-DbaQuery @InvokeDbaQueryInsertParamStudents
        $StudentResult02 | Should -Contain 'Bob', 'Robert', "Robert'); DROP TABLE Student--"

        $InvokeDbaQueryInsertUnsafeParamStudents = @{
            SqlInstance = 'localhost'
            Database = 'tempdb'
            Query = "INSERT INTO Student (PersonName) VALUES ('$Name'); SELECT PersonName FROM Student;"
        }
        $Name = "Robert'); DROP TABLE Student--"
        { Invoke-DbaQuery @InvokeDbaQueryInsertUnsafeParamStudents -EnableException} | Should -Throw
        <#
            Using PowerShell variable replacement in the above query expands the statement to:
                "INSERT INTO Student (PersonName) VALUES ('Robert'); DROP TABLE Student--'); SELECT PersonName FROM Student"
            T-SQL uses the syntax "--" to say everything after this is a comment.

            So our expected syntax
                "INSERT INTO Student (PersonName) VALUES [...]
                SELECT PersonName FROM Student"
            becomes
                "INSERT INTO Student (PersonName) VALUES ('Robert')
                DROP TABLE Student"

            dbatools by default tries to return errors as warnings so beginners to PowerShell don't
            get overwhelmed by red error messages.
            We use the switch -EnableException to return an error since the table "Student" no longer exists.
        #>
    }
}
