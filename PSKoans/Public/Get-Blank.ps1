function Get-Blank {
    <#
    .SYNOPSIS
        Gets a blank item that does not equal anything.

    .DESCRIPTION
        Get-Blank returns an object of type [Blank] as defined in the PSKoans module.
        This object is not equivalent to any other type of object, including itself, when compared
        with a standard `-eq` comparison.

        The only exception, which is unavoidable, is that it is considered equal to $true when
        $true is on the left-hand side of the comparison. This kind of comparison may sometimes
        need to be carefully avoided when framing a koan assertion.

        For instance,an assertion such as `____ | Should -BeTrue` WILL pass, although it should not.

    .PARAMETER |PipeInput
        Used to capture the input in a pipeline context, to avoid erroring out in those contexts.
        This parameter is not intended to be used directly, and captures all pipeline input.

    .PARAMETER |ParameterInput
        Used to capture parameter names and arguments when used as a substitute for any other cmdlet.
        This parameter is not intended to be used directly, and collects all argument names and values.

    .EXAMPLE
        Get-Blank

        Returns a blank object.

    .EXAMPLE
        __

        Returns a blank object.

    .NOTES
        Author: Joel Sallow (@vexx32)

    .LINK
        https://github.com/vexx32/PSKoans/tree/main/docs/PSKoans.md
    #>
    [CmdletBinding(HelpUri = 'https://github.com/vexx32/PSKoans/tree/main/docs/Get-Blank.md')]
    [OutputType('Blank')]
    [Alias('__', '____', 'FILL_ME_IN')]
    param(
        [Parameter(ValueFromPipeline, DontShow)]
        [object]
        ${|PipeInput},

        [Parameter(ValueFromRemainingArguments, DontShow)]
        [object[]]
        ${|ParameterInput}
    )

    Write-Verbose "I AIN'T DOIN' NOTHIN'!!!"

    return [Blank]::New()
}
