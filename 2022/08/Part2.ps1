# Part 1 was kind of interesting, but I went off the rails by attempting to visit nodes the smallest number of times... so let's simplify and follow the trees.

$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$trees = @{}
for ($y = 0; $y -lt $data.Count; $y++) {
    $rowOfTrees = $data[$y]

    for ($x = 0; $x -lt $rowOfTrees.Length; $x++) {
        $trees["$x $y"] = [PSCustomObject]@{
            Position = $x, $y
            Size     = [int][string]$data[$y][$x]
            N        = 0
            E        = 0
            S        = 0
            W        = 0
            Total    = 0
        }
    }
}

$directions = @{
    N = 0, -1
    S = 0, 1
    E = 1, 0
    W = -1, 0
}

$mostVisible = 0
foreach ($tree in $trees.Values) {
    foreach ($direction in $directions.Keys) {
        $position = $tree.Position
        while ($true) {
            $position = @(
                $position[0] + $directions[$direction][0]
                $position[1] + $directions[$direction][1]
            )

            if (-not $trees.Contains("$position")) {
                break
            }
            $tree.$direction++

            if ($trees["$position"].Size -ge $tree.Size) {
                break
            }
        }
    }

    $tree.Total = $tree.N * $tree.S * $tree.E * $tree.W

    if ($tree.Total -gt $mostVisible) {
        $mostVisible = $tree.Total
    }
}
$mostVisible
