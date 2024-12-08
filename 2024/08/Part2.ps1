using namespace System.Collections.Generic

class Node {
    [string]
    $ID

    [int]
    $x

    [int]
    $y

    static [void] Reset() {
        [Antenna]::Reset()
        [AntiNode]::Reset()
    }

    Node([int]$x, [int]$y) {
        $this.x = $x
        $this.y = $y
    }

    [string] ToString() {
        return $this.ID
    }
}

class AntiNode : Node {
    hidden static [HashSet[string]] $unique = [HashSet[string]]::new()
    static [List[AntiNode]] $All = [List[AntiNode]]::new()

    static [void] Add([int]$x, [int]$y) {
        [AntiNode]::new($x, $y)
    }

    static [void] Reset() {
        [AntiNode]::unique.Clear()
        [AntiNode]::All.Clear()
    }

    AntiNode([int]$x, [int]$y) : base($x, $y) {
        $this.ID = '{0},{1}' -f $x, $y

        if ([AntiNode]::unique.Add($this.ID)) {
            [AntiNode]::All.Add($this)
        }
    }
}

class Antenna : Node {
    static [Dictionary[string,Antenna[]]] $All = [Dictionary[string,Antenna[]]]::new()

    [string]
    $Frequency

    static [void] Add([string]$frequency, [int]$x, [int]$y) {
        [Antenna]::new($frequency, $x, $y)
    }

    static [void] Reset() {
        [Antenna]::All.Clear()
    }

    Antenna([string]$frequency, [int]$x, [int]$y) : base($x, $y) {
        $this.ID = '{0},{1},{2}' -f $frequency, $x, $y
        $this.Frequency = $frequency

        [Antenna]::All[$frequency] += @($this)
    }
}

[Node]::Reset()

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$maxX = $grid[0].Length - 1
$maxY = $grid.Count - 1

for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        if ($grid[$y][$x] -notmatch '[.#]') {
            [Antenna]::Add($grid[$y][$x], $x, $y)
        }
    }
}

foreach ($frequency in [Antenna]::All.Keys) {
    $all = [Antenna]::All[$frequency]

    $pairs = for ($i = 0; $i -lt $all.Count; $i++) {
        for ($j = $i + 1; $j -lt $all.Count; $j++) {
            ,$all[$i,$j]
        }
    }

    foreach ($pair in $pairs) {
        $a, $b = $pair

        $dx = $a.x - $b.x
        $dy = $a.y - $b.y

        if ($a.x - $dx -eq $b.x) {
            $dx = -$dx
        }
        if ($a.y - $dy -eq $b.y) {
            $dy = -$dy
        }

        [AntiNode]::Add($a.x, $a.y)
        [AntiNode]::Add($b.x, $b.y)

        $ax = $a.x - $dx
        $ay = $a.y - $dy

        while ($ax -ge 0 -and $ax -le $maxX -and $ay -ge 0 -and $ay -le $maxY) {
            [AntiNode]::Add($ax, $ay)
            $ax -= $dx
            $ay -= $dy
        }

        $bx = $b.x + $dx
        $by = $b.y + $dy

        while ($bx -ge 0 -and $bx -le $maxX -and $by -ge 0 -and $by -le $maxY) {
            [AntiNode]::Add($bx, $by)
            $bx += $dx
            $by += $dy
        }
    }
}
[AntiNode]::All.Count
