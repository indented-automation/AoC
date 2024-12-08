function Get-OnNeighbour {
    param (
        $x,
        $y
    )

    $count = 0
    foreach ($direction in $directions) {
        $nx = $x + $direction['x']
        $ny = $y + $direction['y']

        if ($nx -lt 0 -or $ny -lt 0 -or $nx -ge $grid[0].Count -or $ny -ge $grid.Count) {
            continue
        }

        if ($grid[$ny][$nx] -eq '#') {
            $count++
        }
    }
    $count
}

$directions = @(
    @{ x = 0;  y = 1 }  # N
    @{ x = 1;  y = 1 }  # NE
    @{ x = 1;  y = 0 }  # E
    @{ x = 1;  y = -1 } # SE
    @{ x = 0;  y = -1 } # S
    @{ x = -1; y = -1 } # SW
    @{ x = -1; y = 0 }  # W
    @{ x = -1; y = 1 }  # NW
)

$grid = foreach ($line in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    ,$line.ToCharArray()
}

for ($i = 0; $i -lt 100; $i++) {
    $turnOn = [List[int[]]]::new()
    $turnOff = [List[int[]]]::new()

    for ($y = 0; $y -lt $grid.Count; $y++) {
        for ($x = 0; $x -lt $grid[$y].Length; $x++) {
            $neighbours = Get-OnNeighbour -x $x -y $y
            if ($grid[$y][$x] -eq '#') {
                if ($neighbours -notin 2, 3) {
                    $turnOff.Add(@($y, $x))
                }
            } else {
                if ($neighbours -eq 3) {
                    $turnOn.Add(@($y, $x))
                }
            }
        }
    }

    foreach ($yx in $turnOn) {
        $grid[$yx[0]][$yx[1]] = '#'
    }
    foreach ($yx in $turnOff) {
        $grid[$yx[0]][$yx[1]] = '.'
    }
}

$count = 0
for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        if ($grid[$y][$x] -eq '#') {
            $count++
        }
    }
}
$count
