$sum = 0
foreach ($record in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $null = $record -match 'Game\s(\d+):\s(.+)'
    $id = $matches[1]
    $subsets = $matches[2] -split ';\s'

    $cubes = @{
        red   = 0
        green = 0
        blue  = 0
    }

    foreach ($subset in $subsets) {
        foreach ($cube in $subset -split ',\s') {
            [int]$number, $colour = $cube -split '\s'

            if ($number -gt $cubes[$colour]) {
                $cubes[$colour] = $number
            }
        }
    }

    $sum += $cubes['red'] * $cubes['green'] * $cubes['blue']
}
$sum
