class Button {
    [int]
    $x

    [int]
    $y

    [long]
    $n

    [string] ToString() {
        return '{0},{1}' -f $this.x, $this.y
    }
}

class Machine {
    [int]
    $Number

    [Button]
    $a

    [Button]
    $b

    [long]
    $x

    [long]
    $y

    [bool]
    $Won
}

$content = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt")
$pattern = 'Button\sA:\s*X(?<ax>[+-]\d+),\s*Y(?<ay>[+-]\d+)\s*Button\sB:\s*X(?<bx>[+-]\d+),\s*Y(?<by>[+-]\d+)\s*.+X=(?<px>\d+),\s*Y=(?<py>\d+)'

$i = 0
$machines = foreach ($match in [Regex]::Matches($content, $pattern)) {
    [Machine]@{
        Number = ++$i
        a      = @{ x = $match.Groups['ax'].Value; y = $match.Groups['ay'].Value }
        b      = @{ x = $match.Groups['bx'].Value; y = $match.Groups['by'].Value }
        x      = 10000000000000 + $match.Groups['px'].Value
        y      = 10000000000000 + $match.Groups['py'].Value
    }
}

$tokens = 0
foreach ($machine in $machines) {
    # This is derived from Cramer's rule. I ended trying to read as little as possible of
    # https://www.reddit.com/r/adventofcode/comments/1hd7irq/2024_day_13_an_explanation_of_the_mathematics/
    $an = ($machine.x * $machine.b.y - $machine.y * $machine.b.x) / ($machine.a.x * $machine.b.y - $machine.a.y * $machine.b.x)
    $bn = ($machine.y * $machine.a.x - $machine.x * $machine.a.y) / ($machine.a.x * $machine.b.y - $machine.a.y * $machine.b.x)

    if ($an % 1 -ne 0 -or $bn % 1 -ne 0) {
        continue
    }

    $x = $machine.a.x * $an + $machine.b.x * $bn
    $y = $machine.a.y * $an + $machine.b.y * $bn

    if ($x -eq $machine.x -and $y -eq $machine.y) {
        $machine.Won = $true
        $machine.a.n = $an
        $machine.b.n = $bn

        $tokens += 3 * $an + $bn

    }
}
$tokens