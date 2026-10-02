<# 

This is the answer file for PSKoans\IntroTraining\AboutOOP.koans.ps1

It provides a single function which, when given a test, will provide the correct answer.

#>
enum Test {
    NorwayFjordsSchematics
    Eyjafjallajokull
    CoventrySchematics
    Mars
    doggoNose
    doggoBark
    doggoWoof
    doggoTail
    phoneVibrating
    keyboardColour
    lightPower
    toast 
}

$ResultsHash = @{

        [Test]::NorwayFjordsSchematics = 'object';
        [Test]::Eyjafjallajokull = 'instance';
        [Test]::CoventrySchematics = 'object';
        [Test]::Mars = 'instance';
        [Test]::doggoNose = $true;
        [Test]::doggoBark = $false;
        [Test]::doggoWoof = $true;
        [Test]::doggoTail = $true;
        [Test]::phoneVibrating = $true;
        [Test]::keyboardColour = $false;
        [Test]::lightPower = $false;
        [Test]::toast = $true;
}
function OOPTestAnswers {
param(
[parameter(mandatory=$true)][Test]$Test
)
<#
.SYNOPSIS
Provides a mechanism for marking Koans in IntroTraining\AboutOOP.koans.ps1.

.PARAMETER Test
Specify the name of the test you want the result for. 
This must be of the enum type Test

.INPUTS 
None. You cannot pipe objects through to OOPTestAnswers.

.OUTPUTS
System.String or System.Boolean 
OOPTestAnswers will output a System.String for:

[Test]::NorwayFjordsSchematics
[Test]::Eyjafjallajokull
[Test]::CoventrySchematics 

And a System.Boolean for:

[Test]::doggoNose
[Test]::doggoBark
[Test]::doggoWoof
[Test]::doggoTail
[Test]::phoneVibrating
[Test]::keyboardColour
[Test]::lightPower
[Test]::toast


.EXAMPLE
PS> OOPTestAnswers -Test doggoNose

.LINK
https://github.com/Sudoblark/PSKoans

.LINK 
https://github.com/PowerShellOrg/PSKoans
#>
    return $ResultsHash[$Test]
}
