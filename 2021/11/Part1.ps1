$y = 0
$content = Get-Content "$PSScriptRoot\input.txt"
$grid = [int[][]]::new($content[0].Length, $content.Count)
$content | ForEach-Object {
    $x = 0
    foreach ($char in [char[]]$_) {
        $grid[$x][$y] = [int]::Parse($char)
        $x++
    }
    $y++
}
$maxX = $grid.Count - 1
$maxY = $grid[0].Count - 1

$directions = @(
    @( 0, -1 ), # N
    @( 1, -1 ), # NE
    @( 1, 0 ),  # E
    @( 1, 1 ),  # SE
    @( 0, 1 ),  # S
    @( -1, 1 ), # SW
    @( -1, 0 ), # W
    @( -1, -1 ) # NW
)

$total = 0
for ($step = 1; $step -le 100; $step++) {
    $flashed = @{}

    for ($x = 0; $x -le $maxX; $x++) {
        for ($y = 0; $y -le $maxY; $y++) {
            $grid[$x][$y]++

            if ($grid[$x][$y] -gt 9) {
                $flashed["$x,$y"] = @($x, $y)
            }
        }
    }

    $queue = [System.Collections.Generic.Queue[string]][string[]]$flashed.Keys
    while ($queue.Count -gt 0) {
        $octopus = $queue.Dequeue()
        $x, $y = $flashed[$octopus]

        $grid[$x][$y] = 0

        foreach ($direction in $directions) {
            $neighbourX, $neighbourY = @(
                $x + $direction[0]
                $y + $direction[1]
            )
            if ($neighbourX -lt 0 -or $neighbourX -gt $maxX) {
                continue
            }
            if ($neighbourY -lt 0 -or $neighbourY -gt $maxY) {
                continue
            }

            $position = "$neighbourX,$neighbourY"
            if (-not $flashed.Contains($position)) {
                $grid[$neighbourX][$neighbourY]++

                if ($grid[$neighbourX][$neighbourY] -gt 9) {
                    $flashed[$position] = $neighbourX, $neighbourY
                    $queue.Enqueue($position)
                }
            }
        }
    }
    $total += $flashed.Count
}
$total
