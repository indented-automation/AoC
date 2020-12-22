function Reverse-String {
    param ( $string )

    $chars = [char[]]$string
    [Array]::Reverse($chars)
    [string]::new($chars)
}

$content = Get-Content $PSScriptRoot\input.txt -Raw
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
        Number          = $_.Groups['Number'].Value
        Tile            = $tile
        Rows            = $rows
        Columns         = $columns
    }
}

$tileEdgeMatches = foreach ($tile1 in $tiles) {
    foreach ($rotation in 'None', 'Right', 'Down', 'Left') {
        foreach ($flipAxis in 'None', 'Horizontal', 'Vertical', 'Both') {
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
                }
                if ($bottom -eq $tile2.Rows[0]) {
                    $edge = 'Bottom'
                }
                if ($left -eq $tile2.Columns[-1]) {
                    $edge = 'Left'
                }
                if ($right -eq $tile2.Columns[0]) {
                    $edge = 'Right'
                }

                if ($edge) {
                    [PSCustomObject]@{
                        Tile1       = $tile1.Number
                        Tile2       = $tile2.Number
                        Orientation = $orientation
                        Flipped     = $flipped
                        Edge        = $edge
                    }
                }
            }
        }
    }
}

$tileEdgeMatches | Group-Object Tile1 | ForEach-Object {
    $neighbours = [System.Collections.Generic.HashSet[string]]$_.Group.Tile2
    [PSCustomObject]@{
        Tile     = $_.Name
        IsNextTo = $neighbours
        Category = switch ($neighbours.Count) {
            2 { 'Corner' }
            3 { 'Side' }
            4 { 'Middle' }
        }
    }
} | Where-Object Category -eq 'Corner' | ForEach-Object -Begin { $i = 1 } { $i *= $_.Tile } { $i }
