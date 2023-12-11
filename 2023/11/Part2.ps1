using namespace System.Collections.Generic

$multiplier = 1000000

$image = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$emptyX = [HashSet[int]]::new()
$emptyY = [HashSet[int]]::new()
$galaxies = [List[object]]::new()

for (($x = 0), ($id = 0); $x -lt $image[0].Length; $x++) {
    $isColumnEmpty = $true
    for ($y = 0; $y -lt $image.Count; $y++) {
        if ($image[$y] -notmatch '#') {
            $null = $emptyY.Add($y)
        }

        if ($image[$y][$x] -eq '#') {
            $isColumnEmpty = $false
            $galaxies.Add([PSCustomObject]@{ id = (++$id); x = $x; y = $y })
        }
    }
    if ($isColumnEmpty) {
        $null = $emptyX.Add($x)
    }
}

$allY = [HashSet[int]]$galaxies.y
$emptyYBetween = @{}
foreach ($i in $allY) {
    if ($i -in $emptyY) {
        continue
    }

    foreach ($j in $allY) {
        $min = [Math]::Min($i, $j)
        $max = [Math]::Max($i, $j)

        $emptyYBetween["$i-$j"] = @($emptyY | Where-Object { $_ -gt $min -and $_ -lt $max }).Count
    }
}

$allX = [HashSet[int]]$galaxies.x
$emptyXBetween = @{}
foreach ($i in $allX) {
    if ($i -in $emptyX) {
        continue
    }

    foreach ($j in $allX) {
        $min = [Math]::Min($i, $j)
        $max = [Math]::Max($i, $j)

        $emptyXBetween["$i-$j"] = @($emptyX | Where-Object { $_ -gt $min -and $_ -lt $max }).Count
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

        $distance += [Math]::Abs($a.x - $b.x) +
            $emptyXBetween["$($a.x)-$($b.x)"] * ($multiplier - 1) +
            [Math]::Abs($a.y - $b.y) +
            $emptyYBetween["$($a.y)-$($b.y)"] * ($multiplier - 1)
    }
}
$distance
