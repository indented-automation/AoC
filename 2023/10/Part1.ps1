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

    $length = 0
    do {
        $next = $pipe.GetNext($direction)
        if (-not $next) {
            continue direction

        }
        if (-not $pipe.IsPipeConnected($next, $direction)) {
            continue direction
        }

        if ($next.Type -ne 'S') {
            $direction = [Pipe]::Connections[$next.Type][$direction]
            $pipe = $next
        }

        $length++
    } until ($next.Type -eq 'S')

    return $length / 2
}
