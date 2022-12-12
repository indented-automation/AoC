param (
    [switch]$Draw
)

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

        $incline = $nodes["$x,$y"].Height - $Current.Height
        if ($incline -gt 1) {
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
                $node.Last = $current.Name
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

        $icon = '.'
        if ($data[$y][$x] -ceq 'S') {
            $start = "$x,$y"
            $height = 1
            $icon = 'S'
        }
        if ($data[$y][$x] -ceq 'E') {
            $end = "$x,$y"
            $height = 26
            $icon = 'E'
        }

        $nodes["$x,$y"] = [PSCustomObject]@{
            Name    = "$x,$y"
            Value   = $data[$y][$x]
            x       = $x
            y       = $y
            Height  = $height
            Last    = ''
            Icon    = $icon
            Cost    = [int]::MaxValue
            Visited = $false
        }
    }
}

$endNode = Invoke-Dijkstra -Start $start -End $end -Nodes $nodes
$endNode.Cost

if (-not $draw) {
    return
}

while ($node.Last) {
    $last = $nodes[$node.Last]

    if ($last.y -gt $node.y) {
        $last.Icon = '^'
    } elseif ($last.y -lt $node.y) {
        $last.Icon = 'v'
    } elseif ($last.x -gt $node.x) {
        $last.Icon = '<'
    } else {
        $last.Icon = '>'
    }

    $node = $last
}

for ($y = 0; $y -lt $data.Count; $y++) {
    $row = for ($x = 0; $x -lt $data[$y].Length; $x++) {
        $nodes["$x,$y"].Icon
    }
    -join $row
}

