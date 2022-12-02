enum Move {
    Rock = 1
    Paper
    Scissors
}

$total = 0
foreach ($move in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    [Move]$opponent, [Move]$player = switch ($move -split '\s+') {
        'a' { 'Rock'; continue }
        'b' { 'Paper'; continue }
        'c' { 'Scissors'; continue }
        'x' { 'Rock'; continue }
        'y' { 'Paper'; continue }
        'z' { 'Scissors' }
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
