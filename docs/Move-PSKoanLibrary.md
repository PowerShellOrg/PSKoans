---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Move-PSKoanLibrary.md
schema: 2.0.0
---

# Move-PSKoanLibrary

## SYNOPSIS

Move your entire current PSKoans library folder to another location and update your KoanLocation setting to reflect the new location.

## SYNTAX

```powershell
Move-PSKoanLibrary [-Path] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

`Move-PSKoanLibrary` takes your current PSKoans library location and moves the folder to the specified destination.
Then, it updates the current KoanLocation setting to point to the new location.

## EXAMPLES

### Example

```powershell
PS C:\> Move-PSKoanLibrary -Path C:\Users\Joe\OneDrive
```

Moves Joe's koan library into his OneDrive directory.

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

### -Path

The path to the new library location.
This path can be relative to the current session location, but cannot contain wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath, Folder, Destination, TargetPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

### None

## OUTPUTS

### System.Void

## NOTES

Author: Joel Sallow (@vexx32)

## RELATED LINKS

[Set-PSKoanSetting](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Set-PSKoanSetting.md)

[Get-PSKoanSetting](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoanSetting.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
