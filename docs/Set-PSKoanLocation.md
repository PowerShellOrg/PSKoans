---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Set-PSKoanLocation.md
schema: 2.0.0
---

# Set-PSKoanLocation

## SYNOPSIS

Sets the PSKoans folder location where koan lesson files will be stored and retrieved.

## SYNTAX

```powershell
Set-PSKoanLocation [-Path] <String> [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Sets the `KoanLocation` configuration setting in order to modify where the module looks for and stores its koan lesson files.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-PSKoanLocation -Path C:\PSKoans

Measure-Karma
```

Sets the koan folder location to 'C:\PSKoans' and then invokes Measure-Karma to examine that location for koan files.

## PARAMETERS

### -Confirm

Prompts for confirmation before changing the koan location.

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

### -PassThru

Whether the function should pass the provided `-Path` value down the pipe when the configuration has been changed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specify the path to set the koan location to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath, Folder

Required: True
Position: 0
Default value: None
Accept pipeline input: False
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

### System.String

If `-PassThru` is specified, the command will emit the input path value back to the output stream.

## NOTES

Author: Joel Sallow (@vexx32)

The PSKoans folder specified will become the location to look for koans files.
If this location is empty or nonexistent, it will be created and populated with a pristine copy of the koans library when Measure-Karma is run next.

You can optionally populate it yourself by running `Show-Karma -Reset` following use of this cmdlet.

## RELATED LINKS

[Get-PSKoanLocation](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoanLocation.md)

[Move-PSKoanLibrary](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Move-PSKoanLibrary.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
