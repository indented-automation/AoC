# This is a real mess of a script. It's had bits bolted on and on and on... meh...

function Reverse-String {
    param ( $string )

    $chars = [char[]]$string
    [Array]::Reverse($chars)
    [string]::new($chars)
}

function Rotate-Tile {
    param (
        [Parameter(Mandatory)]
        [string[]]$Tile,

        [ValidateSet('None', 'Right', 'Left', 'Down')]
        [string]$Direction = 'None'
    )

    $rows = $tile -split '\r?\n'
    switch ($direction) {
        'None'  { $rows }
        'Right' {
            for ($x = 0; $x -lt $rows[0].Length; $x++) {
                $chars = for ($y = $rows.Count - 1; $y -ge 0; $y--) {
                    $rows[$y][$x]
                }
                [string]::new($chars)
            }
            break
        }
        'Down' {
            for ($y = $rows.Count - 1; $y -ge 0; $y--) {
                $chars = for ($x = $rows[0].Length - 1; $x -ge 0; $x--) {
                    $rows[$y][$x]
                }
                [string]::new($chars)
            }
        }
        'Left' {
            for ($x = $rows[0].Length - 1; $x -ge 0; $x--) {
                $chars = for ($y = 0; $y -lt $rows.Count; $y++) {
                    $rows[$y][$x]
                }
                [string]::new($chars)
            }
            break
        }
    }
}

function Flip-Tile {
    param (
        [Parameter(Mandatory)]
        [string[]]$tile,

        [Parameter(Mandatory)]
        [ValidateSet('None', 'Horizontal', 'Vertical')]
        $direction
    )

    $rows = $tile -split '\r?\n'
    $columns = for ($i = 0; $i -lt $rows[0].Length; $i++) {
        $chars = for ($j = 0; $j -lt $rows.Count; $j++) {
            $rows[$j][$i]
        }
        [string]::new($chars)
    }

    switch ($direction) {
        'None'       { $rows }
        'Horizontal' {
            for ($i = $columns.Count - 1; $i -ge 0; $i--) {
                $columns[$i]
            }
        }
        'Vertical'   {
            for ($i = $rows.Count - 1; $i -ge 0; $i--) {
                $rows[$i]
            }
        }
    }
}

function Update-TileMetadata {
    param (
        [Parameter(Mandatory)]
        $tile
    )

    $tile.Rows = $tile.RenderedTile -split '\r?\n'
    $tile.Columns = for ($i = 0; $i -lt $tile.Rows[0].Length; $i++) {
        $chars = for ($j = 0; $j -lt $tile.Rows.Count; $j++) {
            $tile.Rows[$j][$i]
        }
        [string]::new($chars)
    }
}

function Try-FixTile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Tile,

        [Parameter(Mandatory)]
        $Neighbours,

        [switch]$Recurse,

        [switch]$Force
    )

    if (-not $Tile.IsFixed -or $Force) {
        if (-not $Force) {
            $Neighbours = $Neighbours | Where-Object IsFixed
        }
        foreach ($neighbour in $Neighbours) {
            $matchingEdge = switch ($true) {
                { $Neighbour.x -lt $Tile.x } {
                    'Left'
                    $compareWith = $Neighbour.Columns[-1]
                }
                { $Neighbour.x -gt $Tile.x } {
                    'Right'
                    $compareWith = $Neighbour.Columns[0]
                }
                { $Neighbour.y -lt $Tile.y } {
                    'Top'
                    $compareWith = $Neighbour.Rows[-1]
                }
                { $Neighbour.y -gt $Tile.y } {
                    'Bottom'
                    $compareWith = $Neighbour.Rows[0]
                }
            }

            $neighbourMatches = $false
            :doevenmorework foreach ($rotation in 'None', 'Right', 'Down', 'Left') {
                foreach ($flipAxis in 'None', 'Horizontal', 'Vertical') {
                    $Tile.RenderedTile = Rotate-Tile -Tile $Tile.Tile -Direction $rotation
                    $Tile.RenderedTile = Flip-Tile -Tile $Tile.RenderedTile -direction $flipAxis
                    Update-TileMetadata -Tile $Tile

                    $compare = switch ($matchingEdge) {
                        'Left'   { $Tile.Columns[0] }
                        'Right'  { $Tile.Columns[-1] }
                        'Top'    { $Tile.Rows[0] }
                        'Bottom' { $Tile.Rows[-1] }
                    }

                    if ($compare -eq $compareWith) {
                        $neighbourMatches = $true
                        break doevenmorework
                    }
                }
            }

            if (-not $neighbourMatches) {
                return $false
            }
        }

        $Tile.IsFixed = $true
    }

    if ($Tile.IsFixed -and $Recurse) {
        foreach ($neighbour in $Tile.Neighbours | Where-Object { $_.IsPlaced -and -not $_.IsFixed }) {
            $null = Try-FixTile -Tile $neighbour -Neighbour $Tile -Recurse
        }
    }

    return $Tile.IsFixed
}

function Try-PlaceTile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Tile,

        [Parameter(Mandatory)]
        $Neighbours
    )

    if ($Tile.IsPlaced) {
        $null = Try-FixTile -Tile $Tile -Neighbour $Neighbours
    } else {
        $directions = @(
            @(1, 0),
            @(0, 1),
            @(-1, 0),
            @(0, -1)
        )

        :tryplace foreach ($direction in $directions) {
            $x = $Neighbours[0].x + $direction[0]
            $y = $Neighbours[0].y + $direction[1]

            if ($x -lt 0 -or $y -lt 0 -or $x -gt $maxIndex -or $y -gt $maxIndex) {
                continue tryplace
            }

            if ($grid[$x,$y]) {
                continue tryplace
            } else {
                $grid[$x,$y] = $Tile
                $Tile.x = $x
                $Tile.y = $y
                $Tile.IsPlaced = $true
            }

            if (Try-FixTile -Tile $Tile -Neighbour $Neighbours) {
                break tryplace
            } else {
                $grid[$x,$y] = $null
            }
        }
    }
}

function Show-Tiles {
    for ($y = 0; $y -le $maxIndex; $y++) {
        for ($i = 0; $i -lt $tiles[0].Rows.Count; $i++) {
            $rows = for ($x = 0; $x -le $maxIndex; $x++) {
                if ($grid[$x,$y]) {
                    $grid[$x,$y].RenderedTile[$i].PadRight(10)
                } else {
                    ' ' * 10
                }
            }
            Write-Host ($rows -join ' ')
        }
        Write-Host
    }
}

function Show-Numbers {
    for ($y = 0; $y -le $maxIndex; $y++) {
        # To write them side by side needs each row simultaneously reading
        $line = for ($x = 0; $x -le $maxIndex; $x++) {
            "$($grid[$x,$y].Number)".PadRight(6)
        }
        Write-Host $line
    }
}

$path = "$PSScriptRoot\input.txt"
$content = Get-Content $path -Raw
$tiles = [Regex]::Matches(
    $content,
    '(?s)Tile (?<Number>\d+):(?<Tile>.+?)(?=((\r\n){2}|$))'
) | ForEach-Object {
    $tile = $_.Groups['Tile'].Value.Trim()
    $rows = $tile -split '\r?\n'
    $columns = for ($i = 0; $i -lt $rows[0].Length; $i++) {
        $chars = for ($j = 0; $j -lt $rows.Count; $j++) {
            $rows[$j][$i]
        }
        [string]::new($chars)
    }

    [PSCustomObject]@{
        Number       = $_.Groups['Number'].Value
        RenderedTile = $rows
        Rows         = $rows
        Columns      = $columns
        Neighbours   = $null
        Category     = $null
        IsPlaced     = $false
        IsFixed      = $false
        x            = -1
        y            = -1
        Position     = ''
        Tile         = $tile
    }
}

$tileEdges = foreach ($tile1 in $tiles) {
    foreach ($rotation in 'None', 'Right', 'Down', 'Left') {
        foreach ($flipAxis in 'None', 'Horizontal', 'Vertical') {
            switch ($rotation) {
                'None' {
                    $orientation = 'None'
                    $top = $tile1.Rows[0]
                    $right = $tile1.Columns[-1]
                    $bottom = $tile1.Rows[-1]
                    $left = $tile1.Columns[0]
                }
                'Right' {
                    $orientation = 'Right'
                    $top = $tile1.Columns[0]
                    $right = $tile1.Rows[0]
                    $bottom = $tile1.Columns[-1]
                    $left = $tile1.Rows[-1]
                }
                'Down' {
                    $orientation = 'Down'
                    $top = Reverse-String $tile1.Rows[-1]
                    $right = Reverse-String $tile1.Columns[0]
                    $bottom = Reverse-String $tile1.Rows[0]
                    $left = Reverse-String $tile1.Columns[-1]
                }
                'Left' {
                    $orientation = 'Left'
                    $top = $tile1.Columns[-1]
                    $right = $tile1.Rows[-1]
                    $bottom = $tile1.Columns[0]
                    $left = $tile1.Rows[0]
                }
            }

            switch ($flipAxis) {
                'Horizontal' {
                    $flipped = 'Horizontal'

                    $top = Reverse-String $top
                    $bottom = Reverse-String $bottom

                    $temp = $right
                    $right = $left
                    $left = $temp
                }
                'Vertical' {
                    $flipped = 'Vertical'

                    $temp = $top
                    $top = $bottom
                    $bottom = $temp

                    $right = Reverse-String $right
                    $left = Reverse-String $left
                }
                default {
                    $flipped = 'None'
                }
            }

            foreach ($tile2 in $tiles) {
                if ($tile1.Number -eq $tile2.Number) {
                    continue
                }

                $edge = $null

                if ($top -eq $tile2.Rows[-1]) {
                    $edge = 'Top'
                    $value = $top
                }
                if ($bottom -eq $tile2.Rows[0]) {
                    $edge = 'Bottom'
                    $value = $bottom
                }
                if ($left -eq $tile2.Columns[-1]) {
                    $edge = 'Left'
                    $value = $left
                }
                if ($right -eq $tile2.Columns[0]) {
                    $edge = 'Right'
                    $value = $right
                }

                if ($edge) {
                    [PSCustomObject]@{
                        Tile1       = $tile1.Number
                        Tile2       = $tile2.Number
                        Orientation = $orientation
                        Flipped     = $flipped
                        Edge        = $edge
                        Value       = $value
                        Tile        = $tile1
                    }
                }
            }
        }
    }
}

$tilesByNumber = $tiles | Group-Object Number -AsHashtable -AsString
$tileEdges | Group-Object Tile1 | ForEach-Object {
    $neighbours = [string[]][System.Collections.Generic.HashSet[string]]$_.Group.Tile2
    $_.Group[0].Tile.Neighbours = foreach ($neighbour in $neighbours) {
        $tilesByNumber[$neighbour]
    }
    $_.Group[0].Tile.Category = switch ($_.Group[0].Tile.Neighbours.Count) {
        2 { 'Corner' }
        3 { 'Side' }
        4 { 'Middle' }
    }
}
$tilesByCategory = $tiles | Group-Object Category -AsHashtable -AsString

$gridSize = [Math]::Sqrt($tiles.Count)
$grid = [object[,]]::new($gridSize, $gridSize)

$maxIndex = $gridSize - 1
$cornerPositions = @(
    @(0, 1, 2, 3),
    @(0, 1, 3, 2),
    @(0, 2, 1, 3),
    @(0, 2, 3, 1),
    @(0, 3, 1, 2),
    @(0, 3, 2, 1)
)
:fillSides foreach ($position in $cornerPositions) {
    $grid.Clear()

    foreach ($tile in $tiles) {
        $tile.IsPlaced = $false
    }

    $topLeft, $topRight, $bottomLeft, $bottomRight = $position

    foreach ($corner in $tilesByCategory['Corner']) {
        $corner.IsPlaced = $true
    }
    $grid[0,0] = $tilesByCategory['Corner'][$topLeft]
    $grid[0,0].x = $grid[0,0].y = 0
    $grid[0,0].Position = 'TopLeft'

    $grid[$maxIndex, 0] = $tilesByCategory['Corner'][$topRight]
    $grid[$maxIndex, 0].x, $grid[$maxIndex, 0].y = $maxIndex, 0
    $grid[$maxIndex, 0].Position = 'TopRight'

    $grid[0, $maxIndex] = $tilesByCategory['Corner'][$bottomLeft]
    $grid[0, $maxIndex].x, $grid[0, $maxIndex].y = 0, $maxIndex
    $grid[0, $maxIndex].Position = 'BottomLeft'

    $grid[$maxIndex, $maxIndex] = $tilesByCategory['Corner'][$bottomRight]
    $grid[$maxIndex, $maxIndex].x, $grid[$maxIndex, $maxIndex].y = $maxIndex, $maxIndex
    $grid[$maxIndex, $maxIndex].Position = 'BottomRight'

    $directions = @(
        @(1, 0),
        @(0, 1),
        @(-1, 0),
        @(0, -1)
    )
    $x = $y = 0
    foreach ($direction in $directions) {
        for ($i = 0; $i -le $maxIndex; $i++) {
            $currentNode = $x,$y

            if (-not $grid[$currentNode]) {
                $grid[$currentNode] = $grid[$lastNode].Neighbours |
                    Where-Object { $_.Category -eq 'Side' -and -not $_.IsPlaced } |
                    Select-Object -First 1

                $grid[$currentNode].IsPlaced = $true
                $grid[$currentNode].x, $grid[$currentNode].y = $currentNode
            }

            $lastNode = $x,$y

            if ($i -lt $maxIndex) {
                $x += $direction[0]
                $y += $direction[1]

                $nextNode = $x, $y
                if ($grid[$nextNode] -and $grid[$currentNode].Number -notin $grid[$nextNode].Neighbours.Number) {
                    continue fillSides
                }
            }
        }
    }

    break fillSides
}

$Tile = $grid[0,0]
:orienttile foreach ($rotation in 'None', 'Right', 'Down', 'Left') {
    foreach ($flipAxis in 'None', 'Horizontal', 'Vertical') {
        $Tile.RenderedTile = Rotate-Tile -Tile $Tile.Tile -Direction $rotation
        $Tile.RenderedTile = Flip-Tile -Tile $Tile.RenderedTile -direction $flipAxis
        Update-TileMetadata -Tile $Tile

        $matchedGroup = foreach ($neighbour in $Tile.Neighbours) {
            Try-FixTile -Tile $Neighbour -Neighbour $Tile -Force
        }

        if ($matchedGroup -notcontains $false) {
            break orienttile
        }
    }
}

$fixedTile = $tiles | Where-Object IsFixed | Select-Object -First 1
foreach ($neighbour in $fixedTile.Neighbours | Where-Object IsPlaced) {
    $null = Try-FixTile -Tile $neighbour -Neighbour $fixedTile -Recurse
}

while ($tiles.IsFixed -contains $false) {
    $tilesForRound = $tiles | Where-Object {
        -not $_.IsFixed -and
        ($_.Neighbours | Where-Object IsFixed).Count -ge 2
    }
    foreach ($tile in $tilesForRound) {
        $neighbours = $tile.Neighbours | Where-Object IsFixed
        Try-PlaceTile -Tile $tile -Neighbours $neighbours
    }
}

$map = for ($y = 0; $y -le $grid.GetUpperBound(1); $y++) {
    for ($i = 1; $i -le 8; $i++) {
        $strings = for ($x = 0; $x -le $grid.GetUpperBound(0); $x++) {
            $grid[$x,$y].RenderedTile[$i].Substring(1, 8)
        }
        -join $strings
    }
}

$seamonster = @(
    '..................#'
    '#....##....##....###'
    '.#..#..#..#..#..#'
)

$mostMonsters = 0
foreach ($rotation in 'None', 'Right', 'Down', 'Left') {
    foreach ($flipAxis in 'None', 'Horizontal', 'Vertical') {
        $rotatedMap = Rotate-Tile $map -Direction $rotation
        $flippedMap = Flip-Tile $rotatedMap -Direction $flipAxis

        $rows = $flippedMap

        $seamonsters = for ($i = 1; $i -lt $rows.Count - 1; $i++) {
            $match = [Regex]::Match($rows[$i], $seamonster[1])
            if ($match.Success) {
                $head = ('.' * $match.Index) + $seamonster[0]
                $body = ('.' * $match.Index) + $seamonster[2]
                if ($rows[$i - 1] -match $head -and $rows[$i + 1] -match $body) {
                    $match
                }
            }
        }

        if ($seamonsters.Count -gt $mostMonsters) {
            $mostMonsters = $seamonsters.Count
        }
    }
}

$seamonsterLength = 15
(-join $map -replace '[^#]').Length - ($seamonsterLength * $mostMonsters)
