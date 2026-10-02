---
external help file: PSKoans-help.xml
Module Name: PSKoans
online version: https://github.com/PowerShellOrg/PSKoans/tree/main/docs/Get-Blank.md
schema: 2.0.0
---

# Get-Blank

## SYNOPSIS

Gets a blank item that does not equal anything.

## SYNTAX

```powershell
Get-Blank [[-|PipeInput] <Object>] [[-|ParameterInput] <Object[]>] [<CommonParameters>]
```

## DESCRIPTION

Get-Blank returns an object of type [Blank] as defined in the PSKoans module.
This object is not equivalent to any other type of object, including itself, when compared
with a standard `-eq` comparison.

The only exception, which is unavoidable, is that it is considered equal to $true when
$true is on the left-hand side of the comparison. This kind of comparison may sometimes
need to be carefully avoided when framing a koan assertion.

For instance,an assertion such as `____ | Should -BeTrue` WILL pass, although it should not.

## EXAMPLES

### EXAMPLE 1

```powershell

Get-Blank
```

Returns a blank object.

### EXAMPLE 2

```powershell
__
```

Returns a blank object.

## PARAMETERS

### -|PipeInput

Used to capture the input in a pipeline context, to avoid erroring out in those contexts.
This parameter is not intended to be used directly, and captures all pipeline input.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -|ParameterInput

Used to capture parameter names and arguments when used as a substitute for any other cmdlet.
This parameter is not intended to be used directly, and collects all argument names and values.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Blank

An object that has no value, and is generally considered to be not equal to any value, including null.

## NOTES

Author: Joel Sallow (@vexx32)

## RELATED LINKS

[PSKoans](https://github.com/PowerShellOrg/PSKoans/tree/main/docs/PSKoans.md)
