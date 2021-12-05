# Add-Type -AssemblyName WindowsBase

$grid = gc "$PSScriptRoot\input.txt"

$y = 0
$x = 0

$asteroidField = [System.Collections.Generic.HashSet[string]]::new()
for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        if ($grid[$y][$x] -eq '#') {
            $null = $asteroidField.Add("$x,$y")
        }
    }
}

$highestCount = 0
$bestPosition = $null
foreach ($stationPosition in $asteroidField) {
    $stationX, $stationY = $stationPosition -split ',' -as [int[]]

    # $vectors = [System.Collections.Generic.HashSet[System.Windows.Vector]]::new()
    $asteroids = foreach ($asteroidPosition in $asteroidField) {
        if ($stationPosition -eq $asteroidPosition) {
            continue
        }

        $asteroidX, $asteroidY = $asteroidPosition -split ',' -as [int[]]
        # $vectorX = $asteroidX - $stationX
        # $vectorY = $asteroidY - $stationY

        # $vector = [System.Windows.Vector]::new(
        #     $vectorX,
        #     $vectorY
        # )
        # There's a precision problem here. It's including one asteroid it should not even if if works on all sample sets
        # $vector.Normalize()
        # $null = $vectors.Add($vector)

        $distanceX = [Math]::Abs($asteroidX - $stationX)
        $distanceY = [Math]::Abs($asteroidY - $stationY)

        # 4 | 1
        # - s -
        # 3 | 2
        $quadrant = switch ($true) {
            { $asteroidx -ge $stationX -and $asteroidY -lt $stationY } { 1; break }
            { $asteroidx -gt $stationX -and $asteroidY -ge $stationY } { 2; break }
            { $asteroidx -lt $stationX -and $asteroidY -le $stationY } { 4; break }
            { $asteroidx -le $stationX -and $asteroidY -ge $stationY } { 3; break }
        }

        if ($distanceX -eq 0 -or $distanceY -eq 0) {
            # It's a straight-line
            $angle = switch ($quadrant) {
                1 { 0; break }
                2 { 90; break }
                3 { 180; break }
                4 { 270; break }
            }
        } else {
            $angle = [Math]::Atan2($distanceX, $distanceY) * (180 / [Math]::Pi)
            $angle = switch ($quadrant) {
                1 { $angle; break }
                2 { 180 - $angle; break }
                3 { 180 + $angle; break }
                4 { 360 - $angle; break }
            }
        }

        [PSCustomObject]@{
            Station       = $stationPosition
            Asteroid      = $asteroidPosition
            X             = $asteroidX
            Y             = $asteroidY
            Quadrant      = $quadrant
            Angle         = $angle
            Distance      = $distanceX + $distanceY
        }
    }
    $asteroids = $asteroids | Sort-Object Distance | Group-Object Angle, Quadrant | ForEach-Object { $_.Group[0] }

    if ($asteroids.Count -gt $highestCount) {
        $highestCount = $asteroids.Count
        $bestPosition = "${stationPosition}: $($asteroids.Count)"
    }

    # if ($vectors.Count -gt $highestCount) {
    #     $highestCount = $vectors.Count
    #     $bestPosition = [PSCustomObject]@{
    #         StationPosition = $stationPosition
    #         Count           = $vectors.Count
    #     }
    # }
}

# $bestPosition
$highestCount
