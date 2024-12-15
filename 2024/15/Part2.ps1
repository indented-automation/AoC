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
    hidden [HashSet[PlanItem]] $Plan = [HashSet[PlanItem]]::new()

    static [Hashtable] $Directions = @{
        '^' = 0, -1
        '>' = 1, 0
        'V' = 0, 1
        '<' = -1, 0
    }
    static [bool] $Show
    static [int] $Delay

    Warehouse([string] $map) {
        [Box]::_id = 0

        $rows = $map.Trim() -split '\r?\n'

        if ([Warehouse]::Show) {
            Clear-Host
        }

        $box = $null
        $this.Map = for ($y = 0; $y -lt $rows.Count; $y++) {
            $objects = for ($x = 0; $x -lt $rows[$y].Length; $x++) {
                $write = $true

                $object = switch ($rows[$y][$x]) {
                    '[' {
                        $box = [Box]::new($x, $y)
                        $this.Boxes.Add($box)
                        $box
                    }
                    ']' {
                        # Write the same box to two indexes
                        $write = $false
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
                if ($write) {
                    $this.WriteConsoleObject($x, $y, $object, 0)
                }
            }
            ,$objects
        }

        if ([Warehouse]::Show) {
            [Thread]::Sleep([Warehouse]::Delay)
            $this.WriteConsoleLog('Initialized')
        }
    }

    [int[]] GetNextPosition([WarehouseObject] $object, [string] $direction) {
        return @(
            $object.Left + [Warehouse]::Directions[$direction][0]
            $object.Right + [Warehouse]::Directions[$direction][0]
            $object.y + [Warehouse]::Directions[$direction][1]
        )
    }

    [string] GetMap() {
        $rows = foreach ($row in $this.Map) {
            -join $row
        }
        return $rows -join "`n"
    }

    [bool] IsBox([int] $x, [int] $y) {
        return $this.Map[$y][$x] -is [Box]
    }

    [bool] IsWall([int] $x, [int] $y) {
        return $this.Map[$y][$x] -eq '#'
    }

    [bool] TryMoveRobot() {
        $direction = $this.Robot.GetNextMove()
        if (-not $direction) {
            return $false
        }

        $this.Plan.Clear()
        if ($this.CanMoveObject($this.Robot, $direction)) {
            $this.MoveObjects($direction)
        }

        return $true
    }

    [bool] CanMoveObject([int] $x, [int] $y, [string] $direction) {
        if ($this.Map[$y][$x] -eq '.') {
            return $true
        }

        return $this.CanMoveObject($this.Map[$y][$x], $direction)
    }

    [bool] CanMoveObject([WarehouseObject] $object, [string] $direction) {
        $xLeft, $xRight, $y = $this.GetNextPosition($object, $direction)

        $this.Plan.Add([PlanItem]::new($object, $xLeft, $y))

        if ($this.IsWall($xLeft, $y) -or $this.IsWall($xRight, $y)) {
            $this.WriteConsoleLog((
                '{0,-4}: Cannot move {0}, wall' -f @(
                    $this.Robot.move
                    $object.GetType().Name
                )
            ))

            return $false
        }

        if ($direction -eq '<') {
            # Eval left side only.
            if (-not $this.IsBox($xLeft, $y)) {
                return $true
            }
            return $this.CanMoveObject($xLeft, $y, $direction)
        }

        if ($direction -eq '>') {
            # Eval right side only.
            if (-not $this.IsBox($xRight, $y)) {
                return $true
            }
            return $this.CanMoveObject($xRight, $y, $direction)
        }

        # For north and south, evaluate both sides.
        if (-not $this.IsBox($xLeft, $y) -and -not $this.IsBox($xRight, $y)) {
            return $true
        }

        # One of these can be empty space.
        return $this.CanMoveObject($xLeft, $y, $direction) -and $this.CanMoveObject($xRight, $y, $direction)
    }

    [void] MoveObjects([string] $direction) {
        [PlanItem[]] $planItems = $this.Plan
        # Need to execute in order of direction *not* this
        $splat = @{}
        switch ($direction) {
            '^' { $splat['Property'] = 'y' }
            'v' { $splat['Property'] = 'y'; $splat['Descending'] = $true }
            '<' { $splat['Property'] = 'x' }
            '>' { $splat['Property'] = 'x'; $splat['Descending'] = $true }
        }

        foreach ($item in $planItems | Sort-Object @splat) {
            $this.WriteConsoleLog((
                '{0,-4}: Move {1} from {2},{3} to {4},{5}' -f @(
                    $this.Robot.move
                    $item.Entity.GetType().Name
                    $item.Entity.x
                    $item.Entity.y
                    $item.x
                    $item.y
                )
            ))

            $this.MoveObject($item.Entity, $item.x, $item.y)
        }
    }

    [void] MoveObject([WarehouseObject] $object, [int] $x, [int] $y) {
        # Clear the current location of the object
        $this.Map[$object.y][$object.Left] = '.'
        $this.Map[$object.y][$object.Right] = '.'

        # Write the object in it's new position to the screen
        $this.WriteConsoleObject($object.Left, $object.y, '.', 0)
        $this.WriteConsoleObject($object.Right, $object.y, '.', 0)

        # Update the objects x and y
        $object.x = $object.Left = $object.Right = $x
        $object.y = $y
        if ($object -is [Box]) {
            $object.Right = $object.Left + 1
        }

        # Write the object in it's new position to the screen
        $this.WriteConsoleObject($object.Left, $object.y, $object)

        # Update the map
        $this.Map[$object.y][$object.Left] = $this.Map[$object.y][$object.Right] = $object
    }

    [void] WriteConsoleObject([int] $x, [int] $y, [string] $object) {
        $this.WriteConsoleObject($x, $y, $object, [Warehouse]::Delay)
    }

    [void] WriteConsoleObject([int] $x, [int] $y, [string] $object, [int] $delay) {
        if (-not [Warehouse]::Show) {
            return
        }

        [Console]::SetCursorPosition($x, $y)

        $consoleColour = switch -Regex ($object) {
            '#'     { $Script:PSStyle.Foreground.BrightBlue }
            '[[\]]' { $Script:PSStyle.Foreground.BrightMagenta }
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

class WarehouseObject {
    [int]
    $x

    [int]
    $y

    [int]
    $Left

    [int]
    $Right

    WarehouseObject([int] $x, [int] $y) {
        $this.x = $this.Left = $this.Right = $x
        $this.y = $y
    }
}

class Box : WarehouseObject, IEquatable[object] {
    hidden static [int] $_id

    [int]
    $Left

    [int]
    $Right

    hidden [int] $id

    Box([int] $x, [int] $y) : base($x, $y) {
        $this.id = [Box]::_id++
        $this.Right = $x + 1
    }

    [bool] Equals([object] $object) {
        if ($object -isnot [Box]) {
            return $false
        }

        return $object.id -eq $this.id
    }

    [string] ToString() {
        return '[]'
    }
}

class Robot : WarehouseObject {
    [string[]]
    $Moves

    hidden [int] $move

    Robot([string] $x, [string] $y) : base($x, $y) { }

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

class PlanItem : IEquatable[object] {
    [WarehouseObject]
    $Entity

    [int]
    $x

    [int]
    $y

    PlanItem([WarehouseObject] $entity, [int] $x, [int] $y) {
        $this.Entity = $entity
        $this.x = $x
        $this.y = $y
    }

    [bool] Equals([object] $object) {
        if ($object -isnot [PlanItem]) {
            return $false
        }

        return $this.Entity -eq $object.Entity
    }

    [int] GetHashCode() {
        if ($this.Entity -eq [Box]) {
            return $this.Entity.id
        }

        return [int]::MaxValue
    }
}

if ($Sample) {
    $file = 'sample.txt'
} else {
    $file = 'input.txt'
}
$map, $moves = [File]::ReadAllText([Path]::Combine($PSScriptRoot, $file)) -split '(\r?\n){2}'
$map = $map -replace '#', '##' -replace '\.', '..' -replace 'O', '[]' -replace '@', '@.'

[Warehouse]::Show = $Show
[Warehouse]::Delay = $Delay

$warehouse = [Warehouse]::new($map)
$warehouse.Robot.SetMoves($moves)

while ($warehouse.TryMoveRobot()) { }
$warehouse.WriteConsoleLog('Done!')

$null = $warehouse.CanMoveObject($warehouse.Robot, 'v')


$sum = 0
foreach ($box in $warehouse.Boxes) {
    $sum += 100 * $box.y + $box.x
}
if ($Show) {
    $warehouse.WriteConsoleLog($sum)
} else {
    $sum
}
