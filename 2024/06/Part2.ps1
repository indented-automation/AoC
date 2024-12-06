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
        [Hashtable]
        $Obstacle,

        [switch]
        $GetVisited,

        [string[]]
        $Route
    )

    $adjacent = @{}
    $direction = 'n'
    $directions = @{
        n = 0, 1
        e = 1, 0
        s = 0, -1
        w = -1, 0
    }

    if ($GetVisited) {
        '{0},{1}' -f $guard
    }

    while ($true) {
        $next = @(
            $guard[0] + $directions[$direction][0]
            $guard[1] + $directions[$direction][1]
        )
        if ($next[0] -lt 0 -or $next[0] -gt $maxX -or $next[1] -lt 0 -or $next[1] -gt $maxY) {
            if ($GetVisited) {
                return
            } else {
                return $true
            }
        }

        $nextPoint = '{0},{1}' -f $next

        if ($adjacent.Contains($nextPoint) -and $adjacent[$nextPoint] -contains $direction) {
            if ($GetVisited) {
                return
            } else {
                return $false
            }
        }
        if ($Obstacle.Contains($nextPoint)) {
            $adjacent[$nextPoint] += @($direction)
            $direction = Get-NextDirection $direction
            continue
        }

        if ($GetVisited) {
            $nextPoint
        }
        $guard = $next
    }
}

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$visited = @{}
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
            $visited[$point] = @('n')
            $guard = $x, $y
        }
    }
}

$maxX = $grid[0].Length - 1
$maxY = $grid.Count - 1

# Started recording the route with the thinking I could just resume from a specific point.
# But loop detection state also needs capturing. I think I'll leave this alone despite how
# slow and rubbish this is.
$route = Test-Route -Obstacle $obstacle -GetVisited

$count = 0
$hasTested = [HashSet[string]]::new()
for ($i = 0; $i -lt $route.Count; $i++) {
    $point = $route[$i]

    if (-not $hasTested.Add($point)) {
        continue
    }

    $clone = $obstacle.Clone()
    $clone[$point] = $true
    if (-not (Test-Route -Obstacle $clone)) {
        $count++
    }
}
$count