using namespace System.Collections.Generic
using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

class Machine {
    [Indicator]
    $Indicator

    [Button[]]
    $Buttons

    [bool]
    $IsRunning

    [int]
    $PressedButtons

    Machine([string] $manualEntry) {
        $indicatorLights, $wiringSchematic, $joltageRequirements = $manualEntry -split '\]\s|\s\{' -replace '\[|\}'

        $this.Indicator = $indicatorLights
        $this.Buttons = foreach ($schematic in $wiringSchematic -split '\) \(') {
            [Button]::new($schematic, $this)
        }
    }

    [void] Mash([int[]] $buttons) {
        foreach ($i in $buttons) {
            $this.Buttons[$i].Press()
        }
    }

    [void] Reset() {
        $this.Indicator.Current = 0
        $this.IsRunning = $false
        $this.PressedButtons = 0

        foreach ($button in $this.Buttons) {
            $button.Pressed = 0
        }
    }
}

class Indicator {
    [string]
    $Value

    [ushort]
    $Current

    [ushort]
    $Desired

    [int]
    $Length

    Indicator([string] $desired) {
        $this.Value = $desired
        $this.Length = $desired.Length
        $this.Desired = [Convert]::ToUInt16(
            $desired.
                Replace('.', '0').
                Replace('#', '1'),
            2
        )
    }

    [string] ToString() {
        return '[{0}]' -f [Convert]::ToString($this.Current, 2).PadLeft($this.Length, '0').
            Replace('0', '.').
            Replace('1', '#')
    }
}

class Button {
    [string]
    $Schematic

    [int[]]
    $Lights

    [Machine]
    $Machine

    [ushort]
    $Mask

    [int]
    $Pressed

    Button(
        [string] $schematic,
        [Machine] $machine
    ) {
        $this.Schematic = $schematic -replace '[()]'
        $this.Machine = $machine
        $binaryMask = [string]::new([char]'0', $machine.Indicator.Length)

        $this.Lights = $this.Schematic -split ','
        foreach ($light in $this.Lights) {
            $binaryMask = $binaryMask.Remove($light, 1).Insert($light, '1')
        }
        $this.Mask = [Convert]::ToUInt16($binaryMask, 2)
    }

    [void] Press() {
        $this.Pressed++
        $this.Machine.PressedButtons++

        $this.Machine.Indicator.Current = $this.Machine.Indicator.Current -bxor $this.Mask
        $this.Machine.IsRunning = $this.Machine.Indicator.Current -eq $this.Machine.Indicator.Desired
    }

    [string] ToString() {
        return '({0})' -f $this.Schematic
    }
}

function Get-Combination {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int[]]
        $Values,

        [Parameter(Mandatory)]
        [int]
        $Length,

        [int]
        $Position,

        [int[]]
        $Combination = @()
    )

    if ($Values.Count -eq $Length) {
        return @{ Values = $Values }
    }

    if ($Combination.Count -eq $Length) {
        return @{ Values = $Combination }
    }

    for ($i = $position; $i -lt $Values.Count; $i++) {
        $value = $values[$i]

        $params = @{
            Values      = $Values
            Position    = $i + 1
            Combination = @(
                $Combination
                $value
            )
            Length      = $Length
        }
        Get-Combination @params
    }
}

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

[Machine[]]$machines = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName))

$cache = @{}

$sum = 0
foreach ($machine in $machines) {
    if (-not $cache.Contains($machine.Buttons.Count)) {
        $cache[$machine.Buttons.Count] = @{}
        $buttonIndexes = 0..($machine.Buttons.Count - 1)
        for ($i = 1; $i -le $machine.Buttons.Count; $i++) {
            $cache[$machine.Buttons.Count][$i] = Get-Combination $buttonIndexes -Length $i
        }
    }
    $combinations = $cache[$machine.Buttons.Count]

    :ButtonMashing
    for ($i = 1; $i -le $machine.Buttons.Count; $i++) {
        foreach ($combination in $combinations[$i]) {
            $machine.Mash($combination['Values'])

            if ($machine.IsRunning) {
                break ButtonMashing
            }

            $machine.Reset()
        }
    }

    $sum += $machine.PressedButtons
}
$sum
