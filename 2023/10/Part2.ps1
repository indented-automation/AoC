using namespace System.Collections.Generic

class Pipe {
    static [Dictionary[string,string]] $Pipes = [Dictionary[string,string]]::new()
    static [Hashtable] $Direction = @{
        n = @(0, 1)
        e = @(1, 0)
        s = @(0, -1)
        w = @(-1, 0)
    }
    static [Hashtable] $Connections = @{
        '|' = @{
            s = 's'
            n = 'n'
        }
        '-' = @{
            e = 'e'
            w = 'w'
        }
        'L' = @{
            s = 'e'
            w = 'n'
        }
        'J' = @{
            e = 'n'
            s = 'w'
        }
        '7' = @{
            n = 'w'
            e = 's'
        }
        'F' = @{
            n = 'e'
            w = 's'
        }
    }

    [string]
    $Type

    [int]
    $x

    [int]
    $y

    Pipe(
        [string] $position,
        [string] $type
    ) {
        $this.x, $this.y = $position -split ','
        $this.Type = $type
    }

    [Pipe] GetNext(
        [string] $direction
    ) {
        $change = [Pipe]::Direction[$direction]
        $next = '{0},{1}' -f @(
            $this.x + $change[0]
            $this.y + $change[1]
        )

        if ($nextType = [Pipe]::Pipes[$next]) {
            return [Pipe]::new(
                $next,
                $nextType
            )
        }

        return $null
    }

    [bool] IsPipeConnected(
        [Pipe]   $toPipe,
        [string] $direction
    ) {
        if ($toPipe.Type -eq 'S') {
            return $true
        }

        return [Pipe]::Connections[$toPipe.Type].ContainsKey($direction)
    }
}

$start = $null

$content = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$maxX = $content[0].Length - 1
$maxY = $content.Count - 1
for (($i = 0), ($y = $content.Count - 1); $i -lt $content.Count; ($i++), ($y--)) {
    $row = $content[$i]

    for ($x = 0; $x -lt $row.Length; $x++) {
        if ($row[$x] -eq '.') {
            continue
        }
        if ($row[$x] -eq 'S') {
            $start = "$x,$y"
        }
        [Pipe]::Pipes["$x,$y"] = [string]$row[$x]
    }
}

:direction
foreach ($direction in 'n', 'e', 's', 'w') {
    $pipe = [Pipe]::new(
        $start,
        [Pipe]::Pipes[$start]
    )

    $loop = @{}
    do {
        $null = $loop[('{0},{1}' -f $pipe.x, $pipe.y)] = $pipe

        $next = $pipe.GetNext($direction)
        if (-not $next) {
            continue direction
        }
        if (-not $pipe.IsPipeConnected($next, $direction)) {
            continue direction
        }
        if ($next.Type -ne 'S') {
            $direction = [Pipe]::Connections[$next.Type][$direction]
        }
        $pipe = $next
    } until ($next.Type -eq 'S')
    break
}

$flood = [Queue[int[]]]::new()
$exploded = for ($y = $maxY; $y -ge 0; $y--) {
    # Each line will write three lines then I can squeeze through pipes
    $a = ''
    $b = ''
    $c = ''

    for ($x = 0; $x -le $maxX; $x++) {
        # Each character will write three characters to each line.
        $point = '{0},{1}' -f $x, $y
        $pipe = $loop[$point]

        # Pick a bunch of points at the edge to start flood-filling.
        if (($x -eq 0 -or $y -eq 0) -and -not $pipe) {
            $flood.Enqueue(@(
                $x * 3 + 1
                ($maxY - $y) * 3 + 1
            ))
        }

        # Just do this the long and absurdly visible way
        switch ($pipe.Type) {
            'S' {
                $a += '---'
                $b += '---'
                $c += '---'
            }
            '|' {
                $a += '.|.'
                $b += '.|.'
                $c += '.|.'
            }
            '-' {
                $a += '...'
                $b += '---'
                $c += '...'
            }
            'L' {
                $a += '.|.'
                $b += '.L-'
                $c += '...'
            }
            'J' {
                $a += '.|.'
                $b += '-J.'
                $c += '...'
            }
            '7' {
                $a += '...'
                $b += '-7.'
                $c += '.|.'
            }
            'F' {
                $a += '...'
                $b += '.F-'
                $c += '.|.'
            }
            default {
                $a += '...'
                $b += '.x.'
                $c += '...'
            }
        }
    }

    ,[string[]][char[]]$a
    ,[string[]][char[]]$b
    ,[string[]][char[]]$c
}

$count = 0
$visited = [HashSet[string]]::new()
while ($flood.Count) {
    $current = $flood.Dequeue() | Write-Output
    $point = '{0},{1}' -f $current

    if ($visited.Contains($point)) {
        continue
    }
    $null = $visited.Add($point)

    $currentValue = $exploded[$current[1]][$current[0]]
    if ($currentValue -eq 'x') {
        $count++
    }
    $exploded[$current[1]][$current[0]] = 'O'

    foreach ($direction in [Pipe]::Direction.Values) {
        $next = @(
            $current[0] + $direction[0]
            $current[1] + $direction[1]
        )
        if ($next[0] -lt 0 -or $next[0] -ge $exploded[0].Count) {
            continue
        }
        if ($next[1] -lt 0 -or $next[1] -ge $exploded.Count) {
            continue
        }
        $nextValue = $exploded[$next[1]][$next[0]]

        if ($nextValue -notmatch '[x.]') {
            continue
        }
        $flood.Enqueue($next)
    }
}

$maze = foreach ($row in $exploded) {
    -join $row
}
(-join $maze -replace '[^x]').Length
