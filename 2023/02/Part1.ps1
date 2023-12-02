$cubes = @{
    red   = 12
    green = 13
    blue  = 14
}

$sum = 0
foreach ($record in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $null = $record -match 'Game\s(\d+):\s(.+)'
    $id = $matches[1]
    $subsets = $matches[2] -split ';\s'

    $isPossible = $true
    :game
    foreach ($subset in $subsets) {
        foreach ($cube in $subset -split ',\s') {
            $number, $colour = $cube -split '\s'

            if ($cubes[$colour] -lt $number) {
                $isPossible = $false
                break game
            }
        }
    }

    if ($isPossible) {
        $sum += $id
    }
}
$sum
