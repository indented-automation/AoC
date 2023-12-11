$image = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$image = foreach ($row in $image) {
    $row
    if ($row -notmatch '#') {
        $row
    }
}
$columns = for ($i = 0; $i -lt $image[0].Length; $i++) {
    $column = foreach ($row in $image) {
        $row[$i]
    }
    ,$column
    if (-not ($column -match '#')) {
        ,$column
    }
}
$image = for ($i = 0; $i -lt $columns.Count; $i++) {
    $row = foreach ($column in $columns) {
        $column[$i]
    }
    -join $row
}

$galaxies = for (($y = 0), ($i = 0); $y -lt $image.Count; $y++) {
    $row = $image[$y]
    for ($x = 0; $x -lt $image[0].Length; $x++) {
        $point = $image[$y][$x]
        if ($point -eq '#') {
            [PSCustomObject]@{ id = (++$i); x = $x; y = $y; Closest = 0; Distance = [int]::MaxValue }
        }
    }
}
$distance = 0
for ($i = 0; $i -lt $galaxies.Count; $i++) {
    $a = $galaxies[$i]

    for ($j = $i; $j -lt $galaxies.Count; $j++) {
        $b = $galaxies[$j]

        if ($a.id -eq $b.id) {
            continue
        }

        $distance += [Math]::Abs($a.x - $b.x) + [Math]::Abs($a.y - $b.y)
    }
}
$distance
