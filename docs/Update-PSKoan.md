---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version:
schema: 2.0.0
---

# Update-PSKoan

## SYNOPSIS

Update the user Koan directory with new topics and koans.

## SYNTAX

### TopicOnly (Default)

```powershell
Update-PSKoan [-Topic <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ModuleOnly

```powershell
Update-PSKoan [-Topic <String[]>] -Module <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### IncludeModule

```powershell
Update-PSKoan [-Topic <String[]>] -IncludeModule <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Update the user Koan directory with new topics.
Topics will be moved to new directories if appropriate.
Old files will be removed.

Existing koan topics are updated with new koans.
Progress is preserved as much as possible.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-PSKoan -Topic AboutCompareObject
```

The topic AboutCompareObject will be added if it is not already present.
If it is already present, the current copy will be compared to the base module copy.
If any koans are missing from the user's copy, they will be added.
If any koans have been removed from the module copy, they will be removed from the user's copy.

### Example 2

```powershell
PS C:\> Update-PSKoan
```

All missing topics and koans will be copied from the module.

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeModule

Update the default PowerShell Koans as well as Koans for the specified module.
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

### -Module

Update Koans in the specified module only.
Wildcards are supported.

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

Updates the specified topic from the module.
Wildcards are supported.

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

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Void

## NOTES

Author: Chris Dent (@indented-automation)

## RELATED LINKS

[Get-PSKoan](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoan.md)

[Reset-PSKoan](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Reset-PSKoan.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
