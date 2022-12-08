$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$trees = @{}
for ($y = 0; $y -lt $data.Count; $y++) {
    $rowOfTrees = $data[$y]

    for ($x = 0; $x -lt $rowOfTrees.Length; $x++) {
        $trees["$x $y"] = $tree = [PSCustomObject]@{
            Position    = $x, $y
            Size        = [int][string]$data[$y][$x]
            VisibleFrom = $visibleFrom = @{
                N = $y -eq 0
                E = $x -eq $rowOfTrees.Length - 1
                S = $y -eq $data.Count - 1
                W = $x -eq 0
            }
            MaxNeighbourSize = @{
                N = 0
                E = 0
                S = 0
                W = 0
            }
            IsVisible   = $visibleFrom.Values -contains $true
        }
    }
}

$midPoint = [Math]::Floor($data.Count / 2)
$end = "$midPoint $midPoint"

$directions = @{
    E = 1, 0
    S = 0, 1
    W = -1, 0
    N = 0, -1
}

$result = 0
do {
    $lastResult = $result
    foreach ($rotate in 'Clockwise', 'Anticlockwise') {
        $position = 1, 1
        $direction = $rotate -eq 'Clockwise' ? 'E' : 'S'

        $minMax = @{
            E = $data[0].Length - 2
            S = $data.Count - 2
            W = 1
            N = 2
        }

        do {
            $complete = "$position" -eq $end

            $tree = $trees["$position"]

            foreach ($neighbourDirection in 'N', 'S', 'E', 'W') {
                $neighbour = @(
                    $position[0] + $directions[$neighbourDirection][0]
                    $position[1] + $directions[$neighbourDirection][1]
                )
                $neighbourTree = $trees["$neighbour"]

                $tree.MaxNeighbourSize[$neighbourDirection] = [Math]::Max(
                    $neighbourTree.MaxNeighbourSize[$neighbourDirection],
                    $neighbourTree.Size
                )
                $tree.VisibleFrom[$neighbourDirection] = $tree.MaxNeighbourSize[$neighbourDirection] -lt $tree.Size
            }
            $tree.IsVisible = $tree.VisibleFrom.Values -contains $true

            if (-not $complete) {
                $shouldChangeDirection = switch ($direction) {
                    'E' { $position[0] -ge $minMax[$_] }
                    'S' { $position[1] -ge $minMax[$_] }
                    'W' { $position[0] -le $minMax[$_] }
                    'N' { $position[1] -le $minMax[$_] }
                }
                if ($shouldChangeDirection) {
                    if ($rotate -eq 'Clockwise') {
                        $direction = switch ($direction) {
                            'E' { 'S'; $minMax[$_]-- }
                            'S' { 'W'; $minMax[$_]-- }
                            'W' { 'N'; $minMax[$_]++ }
                            'N' { 'E'; $minMax[$_]++ }
                        }
                    } else {
                        $direction = switch ($direction) {
                            'E' { 'N'; $minMax[$_]-- }
                            'S' { 'E'; $minMax[$_]-- }
                            'W' { 'S'; $minMax[$_]++ }
                            'N' { 'W'; $minMax[$_]++ }
                        }
                    }
                }

                $position = @(
                    $position[0] + $directions[$direction][0]
                    $position[1] + $directions[$direction][1]
                )
            }
        } until ($complete)

        $result = ($trees.Values | Where-Object IsVisible | Measure-Object).Count
    }
} until ($result -eq $lastResult)
$result
