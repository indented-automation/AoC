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

    static [AntiNode] Create([int]$x, [int]$y) {
        return [AntiNode]::new($x, $y)
    }

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

function Show-Grid {
    Clear-Host
    $grid -replace '[^.]', ('{0}$0{1}' -f $PSStyle.Foreground.Green, $PSStyle.Reset)
}

function Write-Antenna {
    param (
        [Antenna]$Antenna
    )

    [Console]::SetCursorPosition($Antenna.x, $Antenna.y)
    [Console]::Write(('{0}{1}{2}' -f $PSStyle.Foreground.Red, $Antenna.Frequency, $PSStyle.Reset))
    [Console]::SetCursorPosition(0, $maxY + 1)
}

function Write-AntiNode {
    param (
        [int]$x,
        [int]$y
    )

    [Console]::SetCursorPosition($x, $y)
    [Console]::Write(('{0}#{1}' -f $PSStyle.Foreground.Cyan, $PSStyle.Reset))
    [Console]::SetCursorPosition(0, $maxY + 1)
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

Show-Grid
pause

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

        Write-Antenna $a
        Write-Antenna $b
        [AntiNode]::Add($a.x, $a.y)
        [AntiNode]::Add($b.x, $b.y)

        $ax = $a.x - $dx
        $ay = $a.y - $dy

        while ($ax -ge 0 -and $ax -le $maxX -and $ay -ge 0 -and $ay -le $maxY) {
            if ($antinode = [AntiNode]::Create($ax, $ay)) {
                Write-AntiNode -x $antinode.x -y $antinode.y
            }
            $ax -= $dx
            $ay -= $dy
        }

        $bx = $b.x + $dx
        $by = $b.y + $dy

        while ($bx -ge 0 -and $bx -le $maxX -and $by -ge 0 -and $by -le $maxY) {
            if ($antinode = [AntiNode]::Create($bx, $by)) {
                Write-AntiNode -x $antinode.x -y $antinode.y
            }

            $bx += $dx
            $by += $dy
        }

        pause
        Show-Grid
    }
}
[Console]::SetCursorPosition(0, $maxY + 3)
Write-Host ("Count:", [AntiNode]::All.Count)
