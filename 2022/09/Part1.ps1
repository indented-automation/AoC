$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$directions = @{
    R = 1, 0
    U = 0, 1
    L = -1, 0
    D = 0, -1
}

$visited = [System.Collections.Generic.HashSet[string]]::new()
$head = 0, 0
$tail = 0, 0
foreach ($move in $data) {
    $direction, [int]$distance = $move -split '\s'

    for ($i = 1; $i -le $distance; $i++) {
        $head = @(
            $head[0] + $directions[$direction][0]
            $head[1] + $directions[$direction][1]
        )

        $xDistance = $tail[0] - $head[0]
        $yDistance = $tail[1] - $head[1]

        if ($xDistance -in 2, -2 -or $yDistance -in 2, -2) {
            if ($xDistance -ne 0) {
                $tail[0] += $xDistance / [Math]::Abs($xDistance) * -1
            }
            if ($yDistance -ne 0) {
                $tail[1] += $yDistance / [Math]::Abs($yDistance) * -1
            }
        }

        $null = $visited.Add($tail -join ',')
    }
}
$visited.Count
