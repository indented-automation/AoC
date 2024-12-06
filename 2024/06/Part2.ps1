using namespace System.Collections.Generic

function Get-NextDirection {
    param (
        $Direction
    )
    switch ($Direction) {
        'n' { return 'e' }
        'e' { return 's' }
        's' { return 'w' }
        'w' { return 'n' }
    }
}

function Test-Route {
    param (
        [int]
        $x,

        [int]
        $y,

        [string]
        $Direction = 'n',

        [Hashtable]
        $Obstacle,

        [switch]
        $GetVisited
    )

    $directions = @{
        n = 0, 1
        e = 1, 0
        s = 0, -1
        w = -1, 0
    }

    $visited = @{}
    $first = '{0},{1},{2}' -f $x, $y, $Direction
    $visited[$first] = $true
    if ($GetVisited) {
        $first
    }

    while ($true) {
        $next = @(
            $x + $directions[$Direction][0]
            $y + $directions[$Direction][1]
        )
        if ($next[0] -lt 0 -or $next[0] -gt $maxX -or $next[1] -lt 0 -or $next[1] -gt $maxY) {
            if ($GetVisited) {
                return
            } else {
                return $true
            }
        }

        $nextPoint = '{0},{1}' -f $next
        $pointWithDirection = '{0},{1}' -f $nextPoint, $direction

        if ($visited.Contains($pointWithDirection)) {
            if ($GetVisited) {
                return
            } else {
                return $false
            }
        }
        if ($Obstacle.Contains($nextPoint)) {
            $Direction = Get-NextDirection $Direction
            continue
        }

        if ($GetVisited) {
            $pointWithDirection
        }
        $visited[$pointWithDirection] = $true

        $x, $y = $next
    }
}

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$obstacle = @{}
$guard = @()

# Just to help visualize.
[Array]::Reverse($grid)

for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        $point = '{0},{1}' -f $x, $y

        $obstacle[$x] += @($point)
        if ($grid[$y][$x] -eq '#') {
            $obstacle[$point] = $true
        }
        if ($grid[$y][$x] -eq '^') {
            $guard = $x, $y
        }
    }
}

$maxX = $grid[0].Length - 1
$maxY = $grid.Count - 1

$route = Test-Route -x $guard[0] -y $guard[1] -Obstacle $obstacle -GetVisited

$count = 0
$hasTested = [HashSet[string]]::new()
for ($i = 1; $i -lt $route.Count; $i++) {
    $point, $direction = $route[$i] -split ',', -2

    if (-not $hasTested.Add($point)) {
        continue
    }

    $obstacle[$point] = $true
    # Restart the path from the last position.
    $x, $y, $direction = $route[$i - 1] -split ','
    if (-not (Test-Route -Obstacle $obstacle -x $x -y $y -Direction $direction)) {
        $count++
    }
    # Reset state
    $obstacle.Remove($point)
}
$count