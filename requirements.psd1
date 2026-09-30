@{
    PSDependOptions = @{
        Target = 'CurrentUser'
    }
    'psake' = @{
        Version = '4.9.1'
    }
    'PowerShellBuild' = @{
        Version = '0.8.2'
    }
    'Pester' = @{
        Version = '5.9.0'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    'PSScriptAnalyzer' = @{
        Version = '1.19.1'
    }
    'BuildHelpers' = @{
        Version = '2.0.16'
    }
    'EZOut' = @{
        Version = '2.0.6'
    }
}
