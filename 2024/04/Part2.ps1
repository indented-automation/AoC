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

        [string[]]
        $path,

        [Hashtable]
        $visit,

        [string]
        $value
    )

    if ($value -eq $word) {
        $visit[$path[1]]++
        return
    }

    if ($index -ge $word.Length) {
        return
    }

    if (-not $path) {
        $path = "$x,$y"
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
                path      = $path + $next
                visit     = $visit
                value     = $value + $nextChar
            }
            Find-Word @splat
        }
    }
}

$word = 'mas'
$word = $word.ToUpper()

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$positions = [Dictionary[char,hashtable]]::new()
foreach ($char in $word.ToCharArray()) {
    $positions.Add($char, @{})
}

for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        $char = $grid[$y][$x]
        if ($positions.ContainsKey($char)) {
            $positions[$char]['{0},{1}' -f $x, $y] = $x, $y
        }
    }
}

$directions = @(
    @{ x = 1;  y = 1 }  # NE
    @{ x = 1;  y = -1 } # SE
    @{ x = -1; y = -1 } # SW
    @{ x = -1; y = 1 }  # NW
)

$visit = @{}
foreach ($xy in $positions[$word[0]].Keys) {
    $x, $y = $positions[$word[0]][$xy]

    Find-Word -x $x -y $y -word $word -value $word[0] -direction $directions -visit $visit
}
$count = 0
foreach ($value in $visit.Values) {
    if ($value -eq 2) {
        $count++
    }
}
$count