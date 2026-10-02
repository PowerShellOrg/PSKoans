---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Set-PSKoanSetting.md
schema: 2.0.0
---

# Set-PSKoanSetting

## SYNOPSIS

Modifies the configuration settings for PSKoans.

## SYNTAX

### Single (Default)

```powershell
Set-PSKoanSetting [-Name] <String> [-Value] <Object> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Multiple

```powershell
Set-PSKoanSetting [-Settings] <Hashtable> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Reset

```powershell
Set-PSKoanSetting [-Reset] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Sets module configuration data in a JSON file in the user's $HOME directory.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-PSKoanSetting -Name LibraryFolder -Value "./PSKoans"
```

Sets the library folder location to the `PSKoans` folder in the current directory.

### EXAMPLE 2

```powershell
Set-PSKoanSetting -Name Editor -Value "atom"
```

Sets the text editor used for `Show-Karma -Contemplate` to GitHub Atom. For a
list of text editors known to PSKoans, see Example 2 in the documentation for
[Show-Karma -Contemplate](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Show-Karma.md).

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

### -Name

Specifies which setting value to modify.

```yaml
Type: String
Parameter Sets: Single
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Reset

Resets the user's settings to the default values.

```yaml
Type: SwitchParameter
Parameter Sets: Reset
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Settings

A hashtable containing one or more settings to modify and their values.

```yaml
Type: Hashtable
Parameter Sets: Multiple
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Value

Provides a value to apply to the target setting.

```yaml
Type: Object
Parameter Sets: Single
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
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

## OUTPUTS

### System.Void

## NOTES

Author: Joel Sallow (@vexx32)

## RELATED LINKS

[Get-PSKoanSetting](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoanSetting.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
