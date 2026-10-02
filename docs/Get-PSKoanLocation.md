---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoanLocation.md
schema: 2.0.0
---

# Get-PSKoanLocation

## SYNOPSIS

Gets the folder location where the current user's copy of the PSKoans lessons are stored.

## SYNTAX

```powershell
Get-PSKoanLocation [<CommonParameters>]
```

## DESCRIPTION

Gets the current value of the PSKoans working library path.
This value defaults to `$HOME\PSKoans` but can be changed as you prefer.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-PSKoanLocation

C:\Users\Timmy\PSKoans
```

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

The location used to store the user's koan topic files.

## NOTES

Author: Joel Sallow (@vexx32)

## RELATED LINKS

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
