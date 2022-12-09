$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$directions = @{
    R = 1, 0
    U = 0, 1
    L = -1, 0
    D = 0, -1
}

$visited = [System.Collections.Generic.HashSet[string]]::new()
$head = 0, 0
$rope = [Ordered]@{}
1..9 | ForEach-Object { $rope["$_"] = @(0, 0) }
foreach ($move in $data) {
    $direction, [int]$distance = $move -split '\s'

    for ($i = 1; $i -le $distance; $i++) {
        $head = @(
            $head[0] + $directions[$direction][0]
            $head[1] + $directions[$direction][1]
        )

        $follow = $head
        foreach ($section in $rope.Keys) {
            $xDistance = $rope[$section][0] - $follow[0]
            $yDistance = $rope[$section][1] - $follow[1]

            if ($xDistance -in 2, -2 -or $yDistance -in 2, -2) {
                if ($xDistance -ne 0) {
                    $rope[$section][0] += $xDistance / [Math]::Abs($xDistance) * -1
                }
                if ($yDistance -ne 0) {
                    $rope[$section][1] += $yDistance / [Math]::Abs($yDistance) * -1
                }
            }

            $follow = $rope[$section]
        }

        $null = $visited.Add($rope[-1] -join ',')
    }
}

$visited.Count
