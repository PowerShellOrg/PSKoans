---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-Karma.md
schema: 2.0.0
---

# Get-Karma

## SYNOPSIS

Retrieves information about your progress in PSKoans.

## SYNTAX

### Default (Default)

```powershell
Get-Karma [-Topic <String[]>] [<CommonParameters>]
```

### ListKoans

```powershell
Get-Karma [-Topic <String[]>] [-Module <String[]>] [-List] [<CommonParameters>]
```

### ModuleOnly

```powershell
Get-Karma [-Topic <String[]>] -Module <String[]> [<CommonParameters>]
```

### IncludeModule

```powershell
Get-Karma [-Topic <String[]>] -IncludeModule <String[]> [<CommonParameters>]
```

## DESCRIPTION

Get-Karma executes Pester against the koans and outputs a short report on your current progress.

## EXAMPLES

### Example 1

```powershell
Get-Karma
```

```none
Name                           Value
----                           -----
KoansPassed                    6
TotalKoans                     279
CurrentTopic                   {Completed, Total, Name}
DescribeName                   Variable Assignment
Results                        {@{ErrorRecord=; Descri…
Meditation                     at <ScriptBlock>, C:\Us…
ItName                         infers types on its own
Expectation                    Expected the value to h…
```

Outputs a hashtable containing information about your progress.

### Example 2

```powershell
Get-Karma -List
```

Outputs a list of koan topics, including both the user file location and the module file location.

## PARAMETERS

### -IncludeModule

Get Karma for the default PowerShell Koans as well as Koans for the specified module.
Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: IncludeModule
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -List

Output a complete list of available koan topics.

```yaml
Type: SwitchParameter
Parameter Sets: ListKoans
Aliases: ListKoans, ListTopics

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Module

Get Karma for the specified module only.
Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: ListKoans
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

```yaml
Type: String[]
Parameter Sets: ModuleOnly
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Topic

Execute koans only from the selected Topic(s).
Wildcard patterns are permitted.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Koan, File

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PSKoans.Result

This is the result object type used during the user's journey.

### PSKoans.CompleteResult

This will be the result object type when all koans are completed.

## NOTES

Author: Joel Sallow (@vexx32)

## RELATED LINKS

[Get-Karma](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-Karma.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
