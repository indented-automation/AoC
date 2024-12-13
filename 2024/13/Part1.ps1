class Button {
    [int]
    $x

    [int]
    $y

    [string] ToString() {
        return '{0},{1}' -f $this.x, $this.y
    }
}

class Machine {
    [Button]
    $a

    [Button]
    $b

    [int]
    $x

    [int]
    $y

    [int]
    $Tokens = [int]::MaxValue

    [bool]
    $Won
}

$content = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt")
$pattern = 'Button\sA:\s*X(?<ax>[+-]\d+),\s*Y(?<ay>[+-]\d+)\s*Button\sB:\s*X(?<bx>[+-]\d+),\s*Y(?<by>[+-]\d+)\s*.+X=(?<px>\d+),\s*Y=(?<py>\d+)'
$machines = foreach ($match in [Regex]::Matches($content, $pattern)) {
    [Machine]@{
        a = @{ x = $match.Groups['ax'].Value; y = $match.Groups['ay'].Value }
        b = @{ x = $match.Groups['bx'].Value; y = $match.Groups['by'].Value }
        x = $match.Groups['px'].Value
        y = $match.Groups['py'].Value
    }
}

$sum = 0
foreach ($machine in $machines) {
    # I expected more than one $an, but there's only one.
    for (($an = 0), ($x = 0), ($bn = 0); $x -le $machine.x -and $bn -ge 0 -and $an -lt 100; $an++) {
        $bn = ($machine.x - $machine.a.x * $an) / $machine.b.x
        if ($an * $machine.a.x -gt $machine.x) {
            break
        }
        if ($bn % 1 -ne 0) {
            continue
        }

        $x = $machine.a.x * $an + $machine.b.x * $bn
        $y = $machine.a.y * $an + $machine.b.y * $bn

        if ($x -ne $machine.x -or $y -ne $machine.y) {
            continue
        }

        $machine.Won = $true
        $machine.Tokens = [Math]::Min($machine.Tokens, 3 * $an + $bn)
    }

    if ($machine.Won) {
        $sum += $machine.Tokens
    }
}
$sum