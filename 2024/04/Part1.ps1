using namespace System.Collections.Generic

function Find-Word {
    param (
        [Parameter(Mandatory)]
        [int]
        $x,

        [Parameter(Mandatory)]
        [int]
        $y,

        [Parameter(Mandatory)]
        [string]
        $word,

        [Parameter(Mandatory)]
        [Hashtable[]]
        $direction,

        [int]
        $index = 0,

        [string]
        $value
    )

    if ($value -eq $word) {
        return $value
    }

    if ($index -ge $word.Length) {
        return
    }

    $nextChar = $word[$index + 1]
    foreach ($currentDirection in $direction) {
        $next = '{0},{1}' -f @(
            $x + $currentDirection['x']
            $y + $currentDirection['y']
        )
        if ($positions[$nextChar].Contains($next)) {
            $splat = @{
                x         = $positions[$nextChar][$next][0]
                y         = $positions[$nextChar][$next][1]
                word      = $word
                direction = $currentDirection
                index     = $index + 1
                value     = $value + $nextChar
            }
            Find-Word @splat
        }
    }
}

$word = 'xmas'
$word = $word.ToUpper()

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$positions = [Dictionary[char,hashtable]]::new()
foreach ($char in $word.ToCharArray()) {
    $positions.Add($char, @{})
}

for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        $positions[$grid[$y][$x]]['{0},{1}' -f $x, $y] = $x, $y
    }
}

$directions = @(
    @{ x = 0;  y = 1 }  # N
    @{ x = 1;  y = 1 }  # NE
    @{ x = 1;  y = 0 }  # E
    @{ x = 1;  y = -1 } # SE
    @{ x = 0;  y = -1 } # S
    @{ x = -1; y = -1 } # SW
    @{ x = -1; y = 0 }  # W
    @{ x = -1; y = 1 }  # NW
)

$words = foreach ($xy in $positions[$word[0]].Keys) {
    $x, $y = $positions[$word[0]][$xy]

    Find-Word -x $x -y $y -word $word -value $word[0] -direction $directions
}
$words.Count