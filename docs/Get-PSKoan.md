---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoan.md
schema: 2.0.0
---

# Get-PSKoan

## SYNOPSIS

Gets koan topic metadata for each topic.

## SYNTAX

### IncludeModule (Default)

```powershell
Get-PSKoan [-Topic <String[]>] [-IncludeModule <String[]>] [-Scope <String>] [-SkipAttributeParsing]
 [<CommonParameters>]
```

### ModuleOnly

```powershell
Get-PSKoan [-Topic <String[]>] [-Module <String[]>] [-Scope <String>] [-SkipAttributeParsing]
 [<CommonParameters>]
```

### ListModules

```powershell
Get-PSKoan [-Topic <String[]>] [-Scope <String>] [-SkipAttributeParsing] [-ListModules] [<CommonParameters>]
```

## DESCRIPTION

Get-PSKoan finds Koans in either the Module or User locations.
Koan information includes position and module information, as well as topic name.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PSKoan
```

Get all Koans in the PSKoans module, excluding koans for individual modules.

### Example 2

```powershell
PS C:\> Get-PSKoan -IncludeModule *
```

Get all Koans in the PSKoans module, include all koans for individual PowerShell modules.

### Example 3

```powershell
PS C:\> Get-PSKoan -Topic AboutArrays
```

Get information about the AboutArrays koans.

### Example 4

```powershell
PS C:\> Get-PSKoan -Module ActiveDirectory
```

Get koans from the ActiveDirectory module only.

### Example 5

```powershell
PS C:\> Get-PSKoan -Scope User
```

Get all Koans in the User location, excluding koans for individual modules.

## PARAMETERS

### -IncludeModule

Get default PowerShell Koans as well as Koans for the specified module.
Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: IncludeModule
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -ListModules

List the modules included with PSKoans.

```yaml
Type: SwitchParameter
Parameter Sets: ListModules
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Module

Get Koans for the specified module only.
Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: ModuleOnly
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Scope

Get koans from the specified scope.
The default scope is Module.
User scope gets Koan information from the location used by Get-PSKoanLocation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: User, Module

Required: False
Position: Named
Default value: Module
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipAttributeParsing

By default, Get-PSKoan attempts to retrieve the Position and Module information from the Koan attribute in each file.
This process may be skipped by using this parameter.

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

### -Topic

Reset the specified topic or topics.
Wildcards are supported.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

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

### PSKoans.KoanInfo

A simple object noting the topic name, koan topic position, and module the topic belongs to.

## NOTES

Author: Chris Dent (@indented-automation)

## RELATED LINKS

[Get-PSKoan](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-PSKoan.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
