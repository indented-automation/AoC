using namespace System.Collections.Generic
using namespace System.Threading

param (
    [switch]
    $Show
)

class GridLogger {
    static [GridLogger] $_instance = [GridLogger]::new()
    static [bool] $Enabled

    [string[]]
    $Grid

    [int]
    $Max

    [int]
    $Lines

    hidden [Queue[string]] $Log

    hidden GridLogger() { }

    GridLogger([string[]] $grid) {
        $this.Init($grid, 5)
    }

    GridLogger([string[]] $grid, [int] $lines) {
        $this.Init($grid, $lines)
    }

    hidden Init([string[]] $grid, [int] $lines) {
        $this.Grid = $grid
        $this.Max = $grid.Count
        $this.Lines = $lines
        $this.Log = @('') * $this.Lines
    }

    static [void] Create([string[]] $grid) {
        [GridLogger]::_instance = [GridLogger]::new($grid)
    }

    static [void] Create([string[]] $grid, [int] $lines) {
        [GridLogger]::_instance = [GridLogger]::new($grid, $lines)
        [GridLogger]::_instance.Enabled = $true
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

class Step {
    static [Hashtable] $Steps = @{}
    static [Step] $Start
    static [Step] $End

    hidden static [Hashtable] $directions = @{
        N = 0, -1
        S = 0, 1
        E = 1, 0
        W = -1, 0
    }

    [string]
    $Name

    [int]
    $x

    [int]
    $y

    [int]
    $Cost = [int]::MaxValue

    [string]
    $Facing

    [bool]
    $Visited

    [int]
    $Number

    Step([int] $x, [int] $y, [string] $value) {
        $this.x = $x
        $this.y = $y
        $this.Name = '{0},{1}' -f $x, $y

        if ($value -eq 'S') {
            $this.Cost = 0
            $this.Number = 0
            $this.Facing = 'E'
            [Step]::Start = $this
        }
        if ($value -eq 'E') {
            [Step]::End = $this
        }

        [Step]::Steps[$this.Name] = $this
    }

    static [void] Create([string] $x, [string] $y, [string] $value) {
        [Step]::new($x, $y, $value)
    }

    [StepInDirection[]] GetNeighbours() {
        $neighbours = foreach ($direction in [Step]::directions.Keys) {
            $nextName = '{0},{1}' -f @(
                $this.x + [Step]::directions[$direction][0]
                $this.y + [Step]::directions[$direction][1]
            )
            if ([Step]::Steps.Contains($nextName) -and -not [Step]::Steps[$nextName].Visited) {
                [StepInDirection]@{
                    Direction = $direction
                    Step      = [Step]::Steps[$nextName]
                }
            }
        }

        return $neighbours
    }

    [string] ToString() {
        return $this.Name
    }
}

class StepInDirection {
    [string]
    $Direction

    [Step]
    $Step
}

function Invoke-Dijkstra {
    param ( )

    $queue = [PriorityQueue[Step, int]]::new()
    $queue.Enqueue([Step]::Start, 0)

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

        if ($current.Name -eq [Step]::End.Name) {
            return $current.Cost
        }

        $neighbours = $current.GetNeighbours()

        foreach ($neighbour in $neighbours) {
            [GridLogger]::WriteConsoleObject($neighbour.Step.x, $neighbour.Step.y, '?', 'BrightBlue')

            if ($current.Cost -lt $neighbour.Step.Cost) {
                $neighbour.Step.Facing = $neighbour.Direction

                if ($current.Facing -ne $neighbour.Direction) {
                    $neighbour.Step.Cost = $current.Cost + 1001
                } else {
                    $neighbour.Step.Cost = $current.Cost + 1
                }

                $neighbour.Step.Number = $current.Number + 1

                [GridLogger]::WriteConsoleLog('{0}:   Try {1} {2}: {3}', @(
                    $neighbour.Step.Number
                    $neighbour.Step
                    $neighbour.Direction
                    $neighbour.Step.Cost
                ))
            }

            if ($neighbour.Step.Cost -ne [int]::MaxValue) {
                $queue.Enqueue($neighbour.Step, $neighbour.Step.Cost)
            }
        }

        foreach ($neighbour in $neighbours) {
            [GridLogger]::WriteConsoleObject($neighbour.Step.x, $neighbour.Step.y, '.')
        }

        if ($current.Number -eq 0) {
            [GridLogger]::WriteConsoleObject($current.x, $current.y, 'S')
        } else {
            [GridLogger]::WriteConsoleObject($current.x, $current.y, '.')
        }
    }

    [Step]::End.Cost
}

$maze = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

[GridLogger]::Create($maze)
[GridLogger]::Enabled = $Show
[GridLogger]::Show()

[Step]::Steps.Clear()

for ($y = 0; $y -lt $maze.Count; $y++) {
    for ($x = 0; $x -lt $maze[$y].Length; $x++) {
        if ($maze[$y][$x] -ne '#') {
            [Step]::Create($x, $y, $maze[$y][$x])
        }
    }
}

Invoke-Dijkstra