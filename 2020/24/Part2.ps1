$directions = @{
    e =  @(1, -1, 0)
    ne = @(0, -1, 1)
    sw = @(0, 1, -1)
    w =  @(-1, 1, 0)
    nw = @(-1, 0, 1)
    se = @(1, 0, -1)
}

enum Colour {
    White
    Black
}

$floor = @{}
Get-Content $PSScriptRoot\input.txt | ForEach-Object {
    $x = $y = $z = 0

    for ($i = 0; $i -lt $_.Length; $i++) {
        $direction = $_[$i].ToString()
        if ($direction -in 'n', 's') {
            $direction = -join $_[$i, ++$i]
        }

        $x += $directions[$direction][0]
        $y += $directions[$direction][1]
        $z += $directions[$direction][2]
    }

    $tile = "$x,$y,$z"
    if ($floor.Contains($tile)) {
        $floor.Remove($tile)
    } else {
        $floor[$tile] = [Colour]::Black
    }
}

for ($iteration = 1; $iteration -le 100; $iteration++) {
    $currentState = $floor.Clone()
    $testedTiles = @{}
    foreach ($blackTile in $floor.Keys) {
        $x, $y, $z = $blackTile -split ',' -as [int[]]
        $flipCurrentTile = 0
        foreach ($direction in $directions.Values) {
            $neighbourX = $x + $direction[0]
            $neighbourY = $y + $direction[1]
            $neighbourZ = $z + $direction[2]

            $neighbourKey = $neighbourX, $neighbourY, $neighbourZ -join ','
            if ($floor.Contains($neighbourKey)) {
                $flipCurrentTile++
            } elseif (-not $testedTiles.Contains($neighbourKey)) {
                $flipNeighbouringTile = 0
                foreach ($direction in $directions.Values) {
                    $neighboursNeighbouringKey = '{0},{1},{2}' -f @(
                        $neighbourX + $direction[0]
                        $neighbourY + $direction[1]
                        $neighbourZ + $direction[2]
                    )
                    if ($floor.Contains($neighboursNeighbouringKey)) {
                        $flipNeighbouringTile++
                    }
                }

                if ($flipNeighbouringTile -eq 2) {
                    $currentState[$neighbourKey] = 'Black'
                }

                $testedTiles.Add($neighbourKey, $null)
            }
        }

        if ($flipCurrentTile -eq 0 -or $flipCurrentTile -gt 2) {
            $currentState.Remove($blackTile)
        }
    }

    $floor = $currentState
}

$floor.Keys.Count
