using namespace System.Collections.Generic
using namespace System.Threading

param (
    [switch]
    $Show
)

class GridLogger {
    static [GridLogger] $_instance
    static [bool] $Enabled

    hidden [string[]] $Grid
    hidden [int] $Max
    hidden [int] $Lines = 5
    hidden [Queue[string]] $Log

    hidden GridLogger([string[]] $grid) {
        $this.Init($grid)
    }

    hidden GridLogger([int] $maxX, [int] $maxY) {
        $gridLines = for ($y = 0; $y -le $maxY; $y++) {
            '.' * ($maxX + 1)
        }
        $this.Init($gridLines)
    }

    hidden Init([string[]] $grid) {
        [GridLogger]::Enabled = $false

        $this.Grid = $grid
        $this.Max = $grid.Count
        $this.Log = @('') * $this.Lines
    }

    static [void] Create([string[]] $grid) {
        [GridLogger]::_instance = [GridLogger]::new($grid)
    }

    static [void] Create([int] $maxX, [int] $maxY) {
        [GridLogger]::_instance = [GridLogger]::new($maxX, $maxY)
    }

    static [void] Enable() {
        [GridLogger]::Enabled = $true
    }

    static [void] SetLogLines([int] $lines) {
        [GridLogger]::_instance.Lines = $lines
        [GridLogger]::_instance.Log = @('') * $lines
    }

    static [void] Show() {
        if (-not [GridLogger]::Enabled) {
            return
        }

        Clear-Host

        foreach ($value in [GridLogger]::_instance.Grid) {
            $value = $value -replace '#', ('{0}$0' -f $Global:PSStyle.Foreground.BrightCyan)
            $value = $value -replace '\.', ('{0}$0' -f $Global:PSStyle.Foreground.White)

            [Console]::WriteLine(('{0}{1}' -f $value, $Global:PSStyle.Reset))
        }
    }

    static [void] WriteConsoleObject([int] $x, [int] $y, [string] $object) {
        if (-not [GridLogger]::Enabled) {
            return
        }

        [GridLogger]::WriteConsoleObject($x, $y, $object, 'White')
    }

    static [void] WriteConsoleObject([int] $x, [int] $y, [string] $object, [string] $Colour) {
        if (-not [GridLogger]::Enabled) {
            return
        }

        [Console]::SetCursorPosition($x, $y)

        $consoleColour = $Global:PSStyle.Foreground.$Colour

        [Console]::Write(('{0}{1}{2}' -f $consoleColour, $object, $Script:PSStyle.Reset))
        [Console]::SetCursorPosition(0, [GridLogger]::_instance.Max + [GridLogger]::_instance.Lines + 3)
    }

    static [void] WriteConsoleLog([string] $message, [object[]] $arguments) {
        if (-not [GridLogger]::Enabled) {
            return
        }

        [GridLogger]::WriteConsoleLog($message -f $arguments)
    }

    static [void] WriteConsoleLog([string] $message) {
        if (-not [GridLogger]::Enabled) {
            return
        }

        [Console]::SetCursorPosition(0, [GridLogger]::_instance.Max + 2)
        if ([GridLogger]::_instance.Log.Count -gt [GridLogger]::_instance.Lines) {
            [GridLogger]::_instance.Log.Dequeue()
        }
        [GridLogger]::_instance.Log.Enqueue($message)
        foreach ($entry in [GridLogger]::_instance.Log) {
            [Console]::WriteLine('{0}{1}' -f @(
                $Global:PSStyle.Reset,
                $entry.PadRight($Global:host.UI.RawUI.WindowSize.Width)
            ))
        }

        [Console]::SetCursorPosition(0, [GridLogger]::_instance.Max + [GridLogger]::_instance.Lines + 2)
    }
}

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

        [GridLogger]::WriteConsoleLog('{0}: From {1}. Cost: {2}', @(
            $current.Number
            $current
            $current.Cost
        ))

        [GridLogger]::WriteConsoleObject($current.x, $current.y, 'X', 'Green')

        $current.Visited = $true

        if ($current.Name -eq [Map]::End.Name) {
            return $current.Cost
        }

        $neighbours = $current.GetNeighbours()

        foreach ($neighbour in $neighbours) {
            [GridLogger]::WriteConsoleObject($neighbour.x, $neighbour.y, '?', 'BrightBlue')

            if ($current.Cost -lt $neighbour.Cost) {
                $neighbour.Cost = $current.Cost + 1
                $neighbour.Number = $current.Number + 1

                [GridLogger]::WriteConsoleLog('{0}:   Try {1}: {2}', @(
                    $neighbour.Number
                    $neighbour.Name
                    $neighbour.Cost
                ))

                $neighbour.LastPoint = $current
            }

            if ($neighbour.Cost -ne [int]::MaxValue) {
                $queue.Enqueue($neighbour, $neighbour.Cost)
            }
        }

        foreach ($neighbour in $neighbours) {
            [GridLogger]::WriteConsoleObject($neighbour.x, $neighbour.y, '.')
        }

        [GridLogger]::WriteConsoleObject($current.x, $current.y, '.')
    }

    [Map]::End.Cost
}

[Map]::Points.Clear()
[CorruptSpace]::Points.Clear()

$bytes = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
for ($i = 0; $i -lt $bytes.Count; $i++) {
    $x, $y = $bytes[$i] -split ','
    [CorruptSpace]::Create($x, $y, $i)

    [Map]::MaxX = [Math]::Max([Map]::MaxX, $x)
    [Map]::MaxY = [Math]::Max([Map]::MaxY, $y)
}

[Map]::Start = [Space]::new(0, 0)
[Map]::Start.Cost = 0
[Map]::End = [Space]::new([Map]::MaxX, [Map]::MaxY)

[GridLogger]::Create([Map]::MaxX, [Map]::MaxY)
if ($Show) {
    [GridLogger]::Enable()
    [GridLogger]::Show()
}

[Space]::Time = 1024

if ($Show) {
    foreach ($point in [Map]::Points.Values) {
        if ($point -is [CorruptSpace] -and $point.Time -lt [Space]::Time) {
            [GridLogger]::WriteConsoleObject($point.x, $point.y, '#', 'BrightRed')
        }
    }
}

Invoke-Dijkstra

if ($Show) {
    $point = [Map]::End
    do {
        [GridLogger]::WriteConsoleObject($point.x, $point.y, 'O', 'Green')
        $point = $point.LastPoint
    } while ($point)
}