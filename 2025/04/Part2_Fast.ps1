using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$directions = @{
    n = @(0, 1)
    ne = @(1, 1)
    e  = @(1, 0)
    se = @(1, -1)
    s  = @(0, -1)
    sw = @(-1, -1)
    w  = @(-1, 0)
    nw = @(-1, 1)
}

$paper = @{}

$grid = [File]::ReadAllLines(([System.IO.Path]::Combine($PSScriptRoot, $fileName)))

for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[0].Length; $x++) {
        if ($grid[$y][$x] -eq '@') {
            $paper["$x,$y"] = $x, $y
        }
    }
}

$totalRemoved = 0
do {
    $accessible = 0
    $toRemove = foreach ($position in $paper.GetEnumerator()) {
        $x, $y = $position.Value

        $paperRolls = 0
        foreach ($direction in $directions.GetEnumerator()) {
            $n = '{0},{1}' -f @(
                $x + $direction.Value[0]
                $y + $direction.Value[1]
            )

            if ($paper.Contains($n)) {
                $paperRolls++
            }
        }
        if ($paperRolls -lt 4) {
            $accessible++
            $position.Key
        }
    }
    $totalRemoved += $accessible

    foreach ($position in $toRemove) {
        $paper.Remove($position)
    }
} while ($accessible)
$totalRemoved