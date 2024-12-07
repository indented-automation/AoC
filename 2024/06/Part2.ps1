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

        [switch]
        $GetVisited
    )

    $directions = @{
        n = 0, 1
        e = 1, 0
        s = 0, -1
        w = -1, 0
    }

    $obstacles = @{}
    if ($GetVisited) {
        '{0},{1},{2}' -f $x, $y, $direction
    }

    while ($true) {
        $nextX = $x
        $nextY = $y
        $next = $null

        do {
            if ($GetVisited -and $next) {
                $next
            }
            $x = $nextX
            $y = $nextY

            $nextX += $directions[$Direction][0]
            $nextY += $directions[$Direction][1]

            if ($nextX -lt 0 -or
                $nextX -gt $maxX -or
                $nextY -lt 0 -or
                $nextY -gt $maxY
            ) {
                if ($GetVisited) {
                    return
                } else {
                    return $true
                }
            }

            $next = '{0},{1},{2}' -f $nextX, $nextY, $direction
        } until ($grid[$nextY][$nextX] -eq '#')

        if ($obstacles.Contains($next)) {
            if ($GetVisited) {
                return
            } else {
                return $false
            }
        }

        $obstacles[$next] = $true
        $Direction = Get-NextDirection $Direction
    }
}

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
# Just to help visualize.
[Array]::Reverse($grid)

$guard = @()
$grid = for ($y = 0; $y -lt $grid.Count; $y++) {
    $row = $grid[$y].ToCharArray()
    if (-not $guard) {
        for ($x = 0; $x -lt $row.Count; $x++) {
            if ($row[$x] -eq '^') {
                $guard = $x, $y
            }
        }
    }
    ,$row
}

$maxX = $grid[0].Count - 1
$maxY = $grid.Count - 1

$route = Test-Route -x $guard[0] -y $guard[1] -GetVisited

$count = 0
$hasTested = [HashSet[string]]::new()
for ($i = 1; $i -lt $route.Count; $i++) {
    $point, $direction = $route[$i] -split ',', -2

    if (-not $hasTested.Add($point)) {
        continue
    }

    $currentX, $currentY = $point -split ','

    # Add an obstacle in the current position.
    $grid[$currentY][$currentX] = '#'

    $x, $y, $direction = $route[$i - 1] -split ','
    if (-not (Test-Route -x $x -y $y -Direction $direction)) {
        $count++
    }

    # Remove the obstacle.
    $grid[$currentY][$currentX] = '.'
}
$count