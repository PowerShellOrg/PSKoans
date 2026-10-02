---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoanSetting.md
schema: 2.0.0
---

# Get-PSKoanSetting

## SYNOPSIS

Retrieves the configuration settings for PSKoans.

## SYNTAX

```powershell
Get-PSKoanSetting [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION

Retrieves configuration data from the locally stored json file in `$HOME/.config/PSKoans`.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-PSKoanSetting
```

Retrieves all module settings.

### EXAMPLE 2

```powershell
Get-PSKoanSetting -Name LibraryFolder
```

Retrieves the library folder location (also retrievable with `Get-PSKoanLocation`).

### EXAMPLE 3

```powershell
Get-PSKoanSetting -Name Editor
```

Retrieves the text editor that PSKoans will use for `Show-Karma -Contemplate`.

## PARAMETERS

### -Name

Specifies which setting value to retrieve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

When a specific setting is requested, returns only the value of that setting, which will usually be a string.

### System.Management.Automation.PSObject

When all settings are requested, returns an object with properties representing each setting.

## NOTES

Author: Joel Sallow (@vexx32)

## RELATED LINKS

[Set-PSKoanSetting](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Set-PSKoanSetting.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
