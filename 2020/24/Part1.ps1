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

$floor.Keys.Count
