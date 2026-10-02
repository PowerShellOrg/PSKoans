---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Register-Advice.md
schema: 2.0.0
---

# Register-Advice

## SYNOPSIS

Causes powershell to write a random piece of advice on each start.

## SYNTAX

```powershell
Register-Advice [[-TargetProfile] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Causes powershell to write a random piece of advice on each start.
This is done by creating / modifying the powershell profile to call `Show-Advice` on each session start.

## EXAMPLES

### EXAMPLE 1

```powershell
Register-Advice
```

Causes powershell to write a random piece of advice on each start.

## PARAMETERS

### -Confirm

Prompts you for confirmation before modifying your profile.

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

### -TargetProfile

Specify a named profile to modify.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AllUsersAllHosts, AllUsersCurrentHost, CurrentUserAllHosts, CurrentUserCurrentHost

Required: False
Position: 0
Default value: CurrentUserCurrentHost
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

## NOTES

Author: Friedrich Weinmann (@FriedrichWeinmann)

## RELATED LINKS

[Show-Advice](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Show-Advice.md)

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
