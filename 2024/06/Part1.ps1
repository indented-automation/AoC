param (
    [switch]$Show
)

function Show-Grid {
    Clear-Host
    $rows = for ($y = 0; $y -lt $maxY; $y++) {
        $chars = for ($x = 0; $x -lt $maxX; $x++) {
            $point = '{0},{1}' -f $x, $y
            if ($obstacle.Contains($point)) {
                '#'
            } elseif ($visited.Contains($point)) {
                'X'
            } elseif ($guard -join ',' -eq $point) {
                '^'
            } else {
                '.'
            }
        }
        -join $chars
    }
    [Array]::Reverse($rows)
    foreach ($row in $rows) {
        [Console]::WriteLine($row)
    }
}

function Set-Visited {
    param (
        [int[]]$xy
    )

    if (-not $Show) { return }

    $y = $maxY - $xy[1] - 1

    [Console]::SetCursorPosition($xy[0], $y)
    $colour = $PSStyle.Foreground.Green
    [Console]::Write("${colour}X")
    [System.Threading.Thread]::Sleep(1)
}

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

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$visited = @{}
$obstacle = @{}
$guard = @()

# Just to help visualize.
[Array]::Reverse($grid)

for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        if ($grid[$y][$x] -eq '#') {
            $obstacle['{0},{1}' -f $x, $y] = $true
        }
        if ($grid[$y][$x] -eq '^') {
            $visited['{0},{1}' -f $x, $y] = $true
            $guard = $current = $x, $y
        }
    }
}

$maxX = $grid[0].Length - 1
$maxY = $grid.Count - 1

$direction = 'n'
$directions = @{
    n = 0, 1
    e = 1, 0
    s = 0, -1
    w = -1, 0
}

if ($Show) {
    Show-Grid
}
while ($true) {
    $next = @(
        $current[0] + $directions[$direction][0]
        $current[1] + $directions[$direction][1]
    )
    if ($next[0] -lt 0 -or $next[0] -gt $maxX -or $next[1] -lt 0 -or $next[1] -gt $maxY) {
        break
    }

    $nextPoint = '{0},{1}' -f $next

    if ($obstacle.Contains($nextPoint)) {
        $direction = Get-NextDirection $direction
        continue
    }

    $visited[$nextPoint] = $true
    $current = $next
    if ($Show) {
        Set-Visited -xy $current
    }
}

if ($Show) { [Console]::SetCursorPosition(0, $maxY + 1) }
$visited.Count