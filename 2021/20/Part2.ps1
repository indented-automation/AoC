$algorithm, $pixels = (Get-Content "$PSScriptRoot\input.txt" -Raw) -split '(\r?\n){2,}' -match '#' | ForEach-Object Trim

$algorithm = $algorithm -split '\r?\n' -join ''
$pixels = $pixels -split '\r?\n'

$maxX = $pixels[0].Length - 1
$maxY = $pixels.Count - 1
$minX = $minY = 0

$tracker = @{}
for ($x = 0; $x -le $maxX; $x++) {
    for ($y = 0; $y -le $maxY; $y++) {
        if ($pixels[$y][$x] -eq '#') {
            $tracker["$x,$y"] = 1
        } else {
            $tracker["$x,$y"] = 0
        }
    }
}

$minX -= 2
$minY -= 2
$maxX += 2
$maxY += 2

$default = $true
for ($step = 1; $step -le 50; $step++) {
    $default = $default -bxor $true

    $state = $tracker.Clone()

    for ($x = $minX; $x -le $maxX; $x++) {
        for ($y = $minY; $y -le $maxY; $y++) {
            $pixel = "$x,$y"

            $positions = @(
                @(($x - 1), ($y - 1)),
                @($x, ($y - 1)),
                @(($x + 1), ($y - 1)),
                @(($x - 1), $y),
                @($x, $y),
                @(($x + 1), $y),
                @(($x - 1), ($y + 1)),
                @($x, ($y + 1)),
                @(($x + 1), ($y + 1))
            )

            $bits = foreach ($position in $positions) {
                $position = $position -join ','
                $state.Contains($position) ? $state[$position] : $default
            }
            $binary = '0b{0}' -f (-join $bits)
            $index = $binary -as [ushort]

            if ($algorithm[$index] -eq '#') {
                $tracker[$pixel] = 1
            } else {
                $tracker[$pixel] = 0
            }
        }
    }

    $minX--
    $minY--
    $maxX++
    $maxY++
}

($tracker.Keys | Where-Object { $tracker[$_] }).Count
