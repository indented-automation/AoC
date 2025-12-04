using namespace System.IO
using namespace System.Collections.Generic

[CmdletBinding()]
param (
    [switch]
    $Sample,

    [switch]
    $Draw
)

class Position {
    static [Dictionary[Tuple[int,int],Position]] $Positions = [Dictionary[Tuple[int,int],Position]]::new()
    static [Hashtable] $Directions = @{
        n = @(0, 1)
        ne = @(1, 1)
        e  = @(1, 0)
        se = @(1, -1)
        s  = @(0, -1)
        sw = @(-1, -1)
        w  = @(-1, 0)
        nw = @(-1, 1)
    }

    [int]
    $x

    [int]
    $y
    
    [Tuple[int,int]]
    $ID

    [bool]
    $IsForklift

    [bool]
    $IsPaperRoll

    Position([int] $x, [int] $y, [string] $value) {
        $this.x = $x
        $this.y = $y
        $this.ID = [Tuple[int,int]]::new($x, $y)
        $this.IsPaperRoll = $value -eq '@'
    }

    static [void] Create([int] $x, [int] $y, [string] $value) {
        $position = [Position]::new($x, $y, $value)
        [Position]::Positions.Add($position.ID, $position)
    }

    [Position[]] GetNeighbours() {
        $neighbours = foreach ($direction in [Position]::Directions.GetEnumerator()) {
            $nx = $this.x + $direction.Value[0]
            $ny = $this.y + $direction.Value[1]

            $neighbour = $null
            if ([Position]::Positions.TryGetValue([Tuple[int,int]]::new($nx, $ny), [ref]$neighbour)) {
                $neighbour
            }
        }
        return $neighbours
    }

    [string] ToString() {
        if ($this.IsForklift) {
            return 'x'
        }
        if ($this.IsPaperRoll) {
            return '@'
        }
        return '.'
    }
}

function Show-Grid {
    $rows = [Position]::Positions.Values |
        Sort-Object @{ Expression = 'y'; Descending = $true }, x |
        Group-Object y

    foreach ($row in $rows) {
        Write-Host (-join ($row.Group | ForEach-Object ToString))
    }
}

[Position]::Positions.Clear()

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$grid = [File]::ReadAllLines(([Path]::Combine($PSScriptRoot, $fileName)))

for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[0].Length; $x++) {
        [Position]::Create($x, $y, $grid[$y][$x])
    }
}

if ($Draw) {
    Write-Host 'Initial state:'
    Show-Grid
}

$totalRemoved = 0
do {
    $accessible = 0
    $toRemove = foreach ($position in [Position]::Positions.Values) {
        if (-not $position.IsPaperRoll) {
            continue
        }

        $paperRolls = 0
        foreach ($neighbour in $position.GetNeighbours()) {
            if ($neighbour.IsPaperRoll) {
                $paperRolls++
            }
        }
        if ($paperRolls -lt 4) {
            $accessible++
            $position.IsForklift = $true
            $position
        }
    }
    $totalRemoved += $accessible

    if ($Draw -and $accessible) {
        Write-Host "Remove $accessible rolls of paper:"
        Show-Grid
        Write-Host
    }

    foreach ($position in $toRemove) {
        $position.IsPaperRoll = $position.IsForklift = $false
    }
} while ($accessible)
$totalRemoved