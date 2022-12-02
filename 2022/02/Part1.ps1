enum Move {
    Rock = 1
    Paper
    Scissors
}

$total = 0
foreach ($move in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    [Move]$opponent, [Move]$player = switch -regex ($move -split '\s+') {
        '[ax]' { 'Rock'; continue }
        '[by]' { 'Paper'; continue }
        '[cz]' { 'Scissors'; continue }
    }
    $outcome = switch ($opponent) {
        { $_ -eq $player } { 3; break }
        'Rock'     { 6 * ($player -eq 'Paper'); break }
        'Paper'    { 6 * ($player -eq 'Scissors'); break }
        'Scissors' { 6 * ($player -eq 'Rock') }
    }
    $total += $outcome + $player
}
$total
