---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version:
schema: 2.0.0
---

# Reset-PSKoan

## SYNOPSIS

Reset one or more koans or koan topics to the initial state.

## SYNTAX

### NameOnly (Default)

```powershell
Reset-PSKoan [-Topic <String[]>] [-Name <String>] [-Context <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ModuleOnly

```powershell
Reset-PSKoan [-Topic <String[]>] -Module <String[]> [-Name <String>] [-Context <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### IncludeModule

```powershell
Reset-PSKoan [-Topic <String[]>] -IncludeModule <String[]> [-Name <String>] [-Context <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Replaces the koan in the user file set with the original copy of the koan from the module.

## EXAMPLES

### Example 1

```powershell
PS C:\> Reset-PSKoan
```

Completely reset all koans in the user folder to the initial state.
You will be prompted to confirm.

### Example 2

```powershell
PS C:\> Reset-PSKoan -Topic AboutArrays
```

Resets all koans in the AboutArrays topic.

### Example 3

```powershell
PS C:\> Reset-PSKoan -Topic AboutArrays, AboutComparison
```

Reset all koans in the AboutArrays and AboutComparison topics.

### Example 4

```powershell
PS C:\> Reset-PSKoan -Topic AboutArrays -Name 'allows the collection to be split into multiple parts'
```

Resets the "allows the collection to be split into multiple parts" koan in the AboutArrays topic.

### Example 5

```powershell
PS C:\> Reset-PSKoan -Topic AboutComparison -Name 'may coerce values to boolean' -Context '-and'
```

Resets the "may coerce values to boolean" koan in the "-and" context of the AboutComparison topic.

### Example 6

```powershell
PS C:\> Reset-PSKoan -Topic AboutComparison -Context '-and'
```

Resets all koans in the "-and" context of the AboutComparison topic.

### Example 7

```powershell
PS C:\> Reset-PSKoan -Topic AboutC* -Name returns*
```

Reset koans with names starting "returns" in topics matching the wildcard pattern "AboutC*".

## PARAMETERS

### -Confirm

Prompts for confirmation before making any changes. Use to always be prompted before any changes are made.

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

### -Context

Reset koans in the specified `Context` block.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeModule

Reset the default PowerShell Koans as well as Koans for the specified module.
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

Reset Koans for the specified module only.
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

### -Name

The name of the koan to reset.
Wildcards are supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Topic

Reset the specified topic or topics.
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

Displays what will be reset without actually resetting anything.

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

[Update-PSKoan](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Update-PSKoan.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
