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
                    Name = "$x,$y"
                    Risk = [int]::Parse($char) + $row + $column
                    Cost = [int]::MaxValue
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
$lowest = [int]::MaxValue
do {
    $pathHasChanged = $false

    for ($x = 0; $x -le $maxX; $x++) {
        for ($y = 0; $y -le $maxY; $y++) {
            $currentNode = $nodes["$x,$y"]

            $directions = @(
                @(0, -1),
                @(-1, 0),
                @(1, 0),
                @(0, 1)
            )

            $cost = [int]::MaxValue
            $lastNode = $null
            foreach ($direction in $directions) {
                $lastX, $lastY = @(
                    $x + $direction[0]
                    $y + $direction[1]
                )

                if ($lastX -lt 0 -or $lastX -gt $maxX -or $lastY -lt 0 -or $lastY -gt $maxY) {
                    continue
                }

                $node = $nodes["$lastX,$lastY"]

                if ($node.Cost -lt $cost) {
                    $cost     = $node.Cost
                    $lastNode = $node
                }
            }

            if ($lastNode) {
                if ($lastNode.Cost + $currentNode.Risk -lt $currentNode.Cost) {
                    $currentNode.Cost = $lastNode.Cost + $currentNode.Risk
                    $pathHasChanged = $true
                }
            }
        }
    }

    if ($nodes["$maxX,$maxY"].Cost -lt $lowest) {
        $lowest = $nodes["$maxX,$maxY"].Cost
    } else {
        break
    }
} while ($pathHasChanged)
$lowest
