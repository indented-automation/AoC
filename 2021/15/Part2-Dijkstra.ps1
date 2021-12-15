function Get-Neighbours {
    param (
        [object]$Node
    )

    $directions = @(
        @(1, 0),
        @(-1, 0),
        @(0, 1),
        @(0, -1)
    )

    foreach ($direction in $directions) {
        $x = $Node.x + $direction[0]
        $y = $Node.y + $direction[1]

        if ($nodes.Contains("$x,$y")) {
            $nodes["$x,$y"]
        }
    }
}

function Invoke-Dijkstra {
    param (
        [Hashtable]$nodes,
        [string]$target
    )

    $next = [System.Collections.Generic.PriorityQueue[object, int]]::new()
    $next.Enqueue($nodes["0,0"], 0)

    while ($next.Count -gt 0) {
        $current = $next.Dequeue()

        if ($current.Visited) {
            continue
        }
        $current.Visited = $true

        if ($current.Name -eq $target) {
            return $current.Cost
        }

        foreach ($node in Get-Neighbours -Node $current) {
            $cost = $current.Cost + $node.Risk
            if ($cost -lt $node.Cost) {
                $node.Cost = $cost
            }

            if ($node.Cost -ne [int]::MaxValue) {
                $next.Enqueue($node, $node.Cost)
            }
        }
    }

    $nodes[$target].Cost
}

$content = Get-Content "$PSScriptRoot\input.txt"

$maxX = $content[0].Length * 5 - 1
$maxY = $content.Count * 5 - 1

$nodes = @{}
$y = 0
for ($row = 0; $row -lt 5; $row++) {
    $content | ForEach-Object {
        $x = 0
        for ($column = 0; $column -lt 5; $column++) {
            foreach ($char in [char[]]$_) {
                $node = [PSCustomObject]@{
                    Name    = "$x,$y"
                    x       = $x
                    y       = $y
                    Risk    = [int]::Parse($char) + $row + $column
                    Cost    = [int]::MaxValue
                    Visited = $false
                }
                if ($node.Risk -gt 9) {
                    $node.Risk -= 9
                }
                $nodes["$x,$y"] = $node
                $x++
            }
        }
        $y++
    }
}
$nodes["0,0"].Cost = 0

Invoke-Dijkstra -Nodes $nodes -Target "$maxX,$maxY"
