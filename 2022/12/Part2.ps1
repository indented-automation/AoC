function Get-Neighbour {
    param (
        [Parameter(Mandatory)]
        [object]$Current
    )

    $directions = @(
        @(1, 0),
        @(-1, 0),
        @(0, 1),
        @(0, -1)
    )

    foreach ($direction in $directions) {
        $x = $Current.x + $direction[0]
        $y = $Current.y + $direction[1]

        if (-not $nodes.Contains("$x,$y")) {
            continue
        }

        # Starting at the end.
        $decline = $Current.Height - $nodes["$x,$y"].Height
        if ($decline -gt 1) {
            continue
        }

        $nodes["$x,$y"]
    }
}

function Invoke-Dijkstra {
    param (
        [Parameter(Mandatory)]
        [string]$Start,

        [Parameter(Mandatory)]
        [string]$End,

        [Parameter(Mandatory)]
        [Hashtable]$Nodes
    )

    $nodes[$Start].Cost = 0

    $next = [System.Collections.Generic.PriorityQueue[object, int]]::new()
    $next.Enqueue($nodes[$Start], 0)

    while ($next.Count -gt 0) {
        $current = $next.Dequeue()

        if ($current.Visited) {
            continue
        }
        $current.Visited = $true

        if ($current.Name -eq $End) {
            return $current
        }

        foreach ($node in Get-Neighbour -Current $current) {
            $cost = $current.Cost + 1
            if ($cost -lt $node.Cost) {
                $node.Cost = $cost
            }

            if ($node.Cost -ne [int]::MaxValue) {
                $next.Enqueue($node, $node.Cost)
            }
        }
    }
}

$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$nodes = @{}
for ($y = 0; $y -lt $data.Count; $y++) {
    for ($x = 0; $x -lt $data[$y].Length; $x++) {
        $height = [int]$data[$y][$x] - 96

        if ($data[$y][$x] -ceq 'S') {
            $start = "$x,$y"
            $height = 1
        }
        if ($data[$y][$x] -ceq 'E') {
            $end = "$x,$y"
            $height = 26
        }

        $nodes["$x,$y"] = [PSCustomObject]@{
            Name    = "$x,$y"
            Value   = $data[$y][$x]
            x       = $x
            y       = $y
            Height  = $height
            Cost    = [int]::MaxValue
            Visited = $false
        }
    }
}

# Run this backwards to capture all destinations in one pass.
# All viable "a" values will be visited while exploring the path to the original start.
$null = Invoke-Dijkstra -Start $end -End $start -Nodes $nodes

($nodes.Values | Where-Object Value -eq 'a' | Sort-Object Cost | Select-Object -First 1).Cost
