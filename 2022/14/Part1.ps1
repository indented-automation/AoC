$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$caves = @{}
$maxY = 0
foreach ($wall in $data) {
    $fromTo = $wall -split '\s->\s'
    for ($i = 0; $i -lt $fromTo.Count - 1; $i++) {
        $fromX, $fromY = $fromTo[$i] -split ',' -as [int[]]
        $toX, $toY = $fromTo[$i + 1] -split ',' -as [int[]]

        $x = $fromX
        foreach ($y in $fromY..$toY) {
            $caves["$x $y"] = '#'

            if ($y -gt $maxY) {
                $maxY = $y
            }
        }

        $y = $fromY
        foreach ($x in $fromX..$toX) {
            $caves["$x $y"] = '#'
        }
    }
}

$unit = 0
do {
    ++$unit

    $position = 500, 0
    while ($position[1] -le $maxY) {
        $down = @(
            $position[0]
            $position[1] + 1
        )
        $left = @(
            $position[0] - 1
            $position[1] + 1
        )
        $right = @(
            $position[0] + 1
            $position[1] + 1
        )

        if (-not $caves.Contains("$down")) {
            $position = $down
            continue
        }
        if (-not $caves.Contains("$left")) {
            $position = $left
            continue
        }
        if (-not $caves.Contains("$right")) {
            $position = $right
            continue
        }
        $caves["$position"] = 'o'
        break
    }
} until ($position[1] -ge $maxY)
$unit - 1
