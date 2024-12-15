using namespace System.Collections.Generic
using namespace System.IO
using namespace System.Threading

param (
    [switch]
    $Sample,

    [switch]
    $Show,

    [int]
    $Delay = 1
)

class Warehouse {
    [Robot] $Robot
    [List[Box]] $Boxes = [List[Box]]::new()

    hidden [object[][]] $Map
    hidden [Queue[string]] $Log = [Queue[string]]@('', '' ,'', '', '')

    static [Hashtable] $Directions = @{
        '^' = 0, -1
        '>' = 1, 0
        'V' = 0, 1
        '<' = -1, 0
    }
    static [bool] $Show
    static [int] $Delay

    Warehouse([string] $map) {
        $rows = $map.Trim() -split '\r?\n'

        if ([Warehouse]::Show) {
            Clear-Host
        }

        $this.Map = for ($y = 0; $y -lt $rows.Count; $y++) {
            $objects = for ($x = 0; $x -lt $rows[$y].Length; $x++) {
                $object = switch ($rows[$y][$x]) {
                    'O' {
                        $box = [Box]::new($x, $y)
                        $this.Boxes.Add($box)
                        $box
                    }
                    '@' {
                        $this.Robot = [Robot]::new($x, $y)
                        $this.Robot
                    }
                    default {
                        $rows[$y][$x]
                    }
                }
                $object
                $this.WriteConsoleObject($x, $y, $object, 0)
            }
            ,$objects
        }

        if ([Warehouse]::Show) {
            $this.WriteConsoleLog('Initialized')
        }
    }

    [int[]] GetPointInDirection([int] $x, [int] $y, [string] $direction) {
        return @(
            $x + [Warehouse]::Directions[$direction][0]
            $y + [Warehouse]::Directions[$direction][1]
        )
    }

    [string] GetMap() {
        $rows = foreach ($row in $this.Map) {
            -join $row
        }
        return $rows -join "`n"
    }

    [bool] TryMoveRobot() {
        $direction = $this.Robot.GetNextMove()
        if (-not $direction) {
            return $false
        }

        $x, $y = $this.GetPointInDirection($this.Robot.x, $this.Robot.y, $direction)

        if ($this.IsWall($x, $y)) {
            # The move is complete even if the robot does not move.
            $this.WriteConsoleLog('Cannot move robot, wall')
            return $true
        }

        if (-not $this.IsBox($x, $y) -or $this.TryMoveBox($x, $y, $direction)) {
            $this.MoveRobot($x, $y)
        }

        return $true
    }

    [void] MoveRobot([int] $x, [int] $y) {
        $this.WriteConsoleLog(('Moving robot from {0},{1} to {2},{3}' -f $this.Robot.x, $this.Robot.y, $x, $y))

        $this.Map[$this.Robot.y][$this.Robot.x] = '.'
        $this.WriteConsoleObject($this.Robot.x, $this.Robot.y, '.', 0)

        $this.Robot.x = $x
        $this.Robot.y = $y
        $this.Map[$y][$x] = $this.Robot

        $this.WriteConsoleObject($this.Robot.x, $this.Robot.y, $this.Robot)
    }

    [bool] IsBox([int] $x, [int] $y) {
        return $this.Map[$y][$x] -is [Box]
    }

    [bool] TryMoveBox([int] $x, [int] $y, [string] $direction) {
        $box = $this.Map[$y][$x]

        $nextX, $nextY = $this.GetPointInDirection($x, $y, $direction)

        if ($this.IsWall($nextX, $nextY)) {
            $this.WriteConsoleLog('Cannot move box, wall')
            return $false
        }

        if (-not $this.IsBox($nextX, $nextY) -or $this.TryMoveBox($nextX, $nextY, $direction)) {
            $this.MoveBox($box, $nextX, $nextY)
            return $true
        }

        return $false
    }

    [void] MoveBox([Box] $box, [int] $x, [int] $y) {
        $this.WriteConsoleLog(('Moving box from {0},{1} to {2},{3}' -f $box.x, $box.y, $x, $y))

        $this.Map[$box.y][$box.x] = '.'
        $this.WriteConsoleObject($box.x, $box.y, '.', 0)

        $box.x = $x
        $box.y = $y
        $this.Map[$y][$x] = $box

        $this.WriteConsoleObject($box.x, $box.y, $box)
    }

    [bool] IsWall([int] $x, [int] $y) {
        return $this.Map[$y][$x] -eq '#'
    }

    [void] WriteConsoleObject([int] $x, [int] $y, [string] $object) {
        $this.WriteConsoleObject($x, $y, $object, [Warehouse]::Delay)
    }

    [void] WriteConsoleObject([int] $x, [int] $y, [string] $object, [int] $delay) {
        if (-not [Warehouse]::Show) {
            return
        }

        [Console]::SetCursorPosition($x, $y)

        $consoleColour = switch ($object) {
            '#'     { $Script:PSStyle.Foreground.BrightBlue }
            'O'     { $Script:PSStyle.Foreground.BrightMagenta }
            '@'     { $Script:PSStyle.Foreground.Green }
            default { $Script:PSStyle.Foreground.White }
        }

        [Console]::Write(('{0}{1}{2}' -f $consoleColour, $object, $Script:PSStyle.Reset))
        [Thread]::Sleep($delay)
    }

    [void] WriteConsoleLog([string] $message) {
        if (-not [Warehouse]::Show) {
            return
        }

        [Console]::SetCursorPosition(0, $this.Map.Count + 2)
        if ($this.Log.Count -gt 4) {
            $this.Log.Dequeue()
        }
        $this.Log.Enqueue($message)
        foreach ($entry in $this.Log) {
            [Console]::WriteLine($entry.PadRight($Script:host.UI.RawUI.WindowSize.Width))
        }

        [Console]::SetCursorPosition(0, $this.Map.Count + $this.Log.Count + 2)
    }

    [string] ToString() {
        return $this.GetMap()
    }
}

class Box {
    [int]
    $x

    [int]
    $y

    Box([int] $x, [int] $y) {
        $this.x = $x
        $this.y = $y
    }

    [string] ToString() {
        return 'O'
    }
}

class Robot {
    [int]
    $x

    [int]
    $y

    [string[]]
    $Moves

    hidden [int] $move

    Robot([string] $x, [string] $y) {
        $this.x = $x
        $this.y = $y
    }

    [string] GetNextMove() {
        return $this.Moves[$this.move++]
    }

    [void] SetMoves([string] $moves) {
        $this.Moves = $moves -replace '[^^<>v]' -split '(?<=.)(?=.)'
    }

    [string] ToString() {
        return '@'
    }
}

if ($Sample) {
    $file = 'sample.txt'
} else {
    $file = 'input.txt'
}
$map, $moves = [File]::ReadAllText([Path]::Combine($PSScriptRoot, $file)) -split '(\r?\n){2}'

[Warehouse]::Show = $Show
[Warehouse]::Delay = $Delay

$warehouse = [Warehouse]::new($map)
$warehouse.Robot.SetMoves($moves)

while ($warehouse.TryMoveRobot()) { }
$warehouse.WriteConsoleLog('Done!')

$sum = 0
foreach ($box in $warehouse.Boxes) {
    $sum += 100 * $box.y + $box.x
}
if ($Show) {
    $warehouse.WriteConsoleLog($sum)
} else {
    $sum
}