using namespace System.Collections.Generic
using namespace System.Threading

param (
    [switch]
    $Show
)

class Map {
    static [Dictionary[string,MapPoint]] $Points = [Dictionary[string,MapPoint]]::new()

    static [MapPoint] $Start
    static [MapPoint] $End

    static [int] $MaxX = 0
    static [int] $MaxY = 0

    static [Hashtable] $Directions = @{
        N = 0, -1
        S = 0, 1
        E = 1, 0
        W = -1, 0
    }
}

class MapPoint {
    [string]
    $Name

    [int]
    $Number

    [int]
    $x

    [int]
    $y

    [int]
    $Cost = [int]::MaxValue

    [bool]
    $Visited

    [MapPoint]
    $LastPoint

    MapPoint([int] $x, [int] $y) {
        $this.x = $x
        $this.y = $y
        $this.Name = '{0},{1}' -f $x, $y

        [Map]::Points[$this.Name] = $this
    }

    [string[]] GetNeighbourPoint() {
        $neighbours = foreach ($direction in [Map]::Directions.Keys) {
            $nextX = $this.x + [Map]::Directions[$direction][0]
            $nextY = $this.y + [Map]::Directions[$direction][1]

            if ($nextX -lt 0 -or $nextX -gt [Map]::MaxX) {
                continue
            }
            if ($nextY -lt 0 -or $nextY -gt [Map]::MaxY) {
                continue
            }

            '{0},{1}' -f $nextX, $nextY
        }

        return $neighbours
    }

    [string] ToString() {
        return $this.Name
    }
}

class Space : MapPoint {
    static [int] $Time

    Space([int] $x, [int] $y) : base($x, $y) { }

    static [void] Create([string] $x, [string] $y) {
        [Space]::new($x, $y)
    }

    [MapPoint[]] GetNeighbours() {
        $neighbours = foreach ($neighbour in $this.GetNeighbourPoint()) {
            $x, $y = $neighbour  -split ','

            $space = $null

            if (-not [Map]::Points.TryGetValue($neighbour, [ref]$space)) {
                [Space]::new($x, $y)
                continue
            }

            if ($space -is [CorruptSpace] -and [Space]::Time -gt $space.Time) {
                continue
            }

            # It is traversable at this time. Change this to a normal space.
            if ($space -is [CorruptSpace]) {
                [Space]::new($x, $y)
                continue
            }

            $space
        }

        return $neighbours
    }

    [string] ToString() {
        return $this.Name
    }
}

class CorruptSpace : MapPoint {
    static [Dictionary[string,MapPoint]] $Points = [Dictionary[string,MapPoint]]::new()

    static [int] $MaxX = 0
    static [int] $MaxY = 0

    [int]
    $Time

    CorruptSpace([int] $x, [int] $y, [int] $time) : base($x, $y) {
        $this.Time = $time

        [CorruptSpace]::Points[$this.Name] = $this
    }

    static [void] Create([string] $x, [string] $y, [string] $time) {
        [CorruptSpace]::new($x, $y, $time)
    }
}

function Invoke-Dijkstra {
    param ( )

    $queue = [PriorityQueue[MapPoint, int]]::new()
    $queue.Enqueue([Map]::Start, 0)

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()

        if ($current.Visited) {
            continue
        }

        $current.Visited = $true

        if ($current.Name -eq [Map]::End.Name) {
            return $current.Cost
        }

        $neighbours = $current.GetNeighbours()

        foreach ($neighbour in $neighbours) {
            if ($current.Cost -lt $neighbour.Cost) {
                $neighbour.Cost = $current.Cost + 1
                $neighbour.Number = $current.Number + 1
                $neighbour.LastPoint = $current
            }

            if ($neighbour.Cost -ne [int]::MaxValue) {
                $queue.Enqueue($neighbour, $neighbour.Cost)
            }
        }
    }

    [Map]::End.Cost
}

function Get-PathCost {
    param (
        [Parameter(Mandatory)]
        [int]
        $Time
    )

    [Map]::Points.Clear()
    [CorruptSpace]::Points.Clear()

    [Space]::Time = $Time

    for ($i = 0; $i -lt $bytes.Count; $i++) {
        $x, $y = $bytes[$i] -split ','
        [CorruptSpace]::Create($x, $y, $i)

        [Map]::MaxX = [Math]::Max([Map]::MaxX, $x)
        [Map]::MaxY = [Math]::Max([Map]::MaxY, $y)
    }

    [Map]::Start = [Space]::new(0, 0)
    [Map]::Start.Cost = 0
    [Map]::End = [Space]::new([Map]::MaxX, [Map]::MaxY)

    Invoke-Dijkstra
}

$bytes = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$time = $interval = [Math]::Floor($bytes.Count / 2)
while ($interval -gt 0) {
    $cost = Get-PathCost -Time $time
    if ($cost -eq [int]::MaxValue) {
        $interval = [Math]::Ceiling($interval / 2)

        $time -= $interval
    } else {
        $interval = [Math]::Floor($interval / 2)

        $time += $interval
    }
}

$null = Get-PathCost -Time ($time + 1)
[Map]::Points.Values |
    Where-Object Number -gt 0 |
    Sort-Object Number |
    Select-Object -Last 1 |
    ForEach-Object GetNeighbourPoint |
    ForEach-Object { [CorruptSpace]::Points[$_] } |
    Where-Object Time -eq $time |
    ForEach-Object Name