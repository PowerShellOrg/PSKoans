---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Show-Advice.md
schema: 2.0.0
---

# Show-Advice

## SYNOPSIS

Prints a piece of advice to the screen.

## SYNTAX

```powershell
Show-Advice [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION

Prints a piece of advice to the screen.
Advice snippets are stored in a small library file in the module folder.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Advice
```

Print a random piece of advice to the screen.

## PARAMETERS

### -Name

The title or name of the specific advice snippet to display.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Void

While the command does emit text, it is only written to the Information stream and the host.
No data is emitted to the default output stream.

## NOTES

Author: Friedrich Weinmann (@FriedrichWeinmann)

## RELATED LINKS

[Register-Advice](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Register-Advice.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
