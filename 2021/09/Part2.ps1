function Get-Neighbours {
    [CmdletBinding()]
    param (
        [int]$x,
        [int]$y,
        [int]$NotEqual,
        [int]$LessThanOrEqual,
        [int]$GreaterThan,
        [switch]$Recurse,
        [Hashtable]$HasVisited = @{}
    )

    $directions = @(
        @( 0, -1 ),  # Up
        @( 1, 0 ),  # Right
        @( 0, 1 ),  # Down
        @( -1, 0 )  # Left
    )

    foreach ($direction in $directions) {
        $neighbour = @(
            $x + $direction[0]
            $y + $direction[1]
        )
        if ($neighbour -lt 0 -or $neighbour[0] -gt $map.Count - 1 -or $neighbour[1] -gt $map[0].Count - 1) {
            continue
        }
        if ($hasVisited.Contains("$neighbour")) {
            continue
        }
        $hasVisited["$neighbour"] = 1

        $value = $map[$neighbour[0]][$neighbour[1]]

        if ($PSBoundParameters.ContainsKey('NotEqual') -and $value -eq $NotEqual) {
            continue
        }
        if ($PSBoundParameters.ContainsKey('LessThanOrEqual') -and $value -gt $LessThanOrEqual) {
            continue
        }
        if ($PSBoundParameters.ContainsKey('GreaterThan') -and $value -le $GreaterThan) {
            continue
        }

        [PSCustomObject]@{
            x     = $neighbour[0]
            y     = $neighbour[1]
            Value = $value
        }

        if ($Recurse) {
            $PSBoundParameters['x'] = $neighbour[0]
            $PSBoundParameters['y'] = $neighbour[1]
            Get-Neighbours @PSBoundParameters -HasVisited $hasVisited
        }
    }
}

$y = 0
$content = Get-Content "$PSScriptRoot\input.txt"
$map = [int[][]]::new($content[0].Length, $content.Count)
$content | ForEach-Object {
    $x = 0
    foreach ($char in [char[]]$_) {
        $map[$x][$y] = [int]::Parse($char)
        $x++
    }
    $y++
}

$lowPoints = for ($x = 0; $x -lt $map.Count; $x++) {
    for ($y = 0; $y -lt $map[0].Count; $y++) {
        $current = $map[$x][$y]

        $neighbours = Get-Neighbours $x $y -LessThanOrEqual $current
        if (-not $neighbours) {
            [PSCustomObject]@{ x = $x; y = $y; Value = $current }
        }
    }
}

$basins = foreach ($lowPoint in $lowPoints) {
    $basin = @(
        $lowPoint
        Get-Neighbours -x $lowPoint.x -y $lowPoint.y -NotEqual 9 -GreaterThan $lowPoint.Value -Recurse
    )

    [PSCustomObject]@{
        x     = $lowPoint.x
        y     = $lowPoint.y
        Value = $lowPoint.Value
        Size  = $basin.Count
    }
}
$result = 1
$basins | Sort-Object Size | Select-Object -Last 3 | ForEach-Object {
    $result *= $_.Size
}
$result
