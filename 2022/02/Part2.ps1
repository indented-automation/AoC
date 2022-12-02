enum Move {
    Rock = 1
    Paper
    Scissors
}

$total = 0
foreach ($move in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    [Move]$opponent, $outcome = switch ($move -split '\s+') {
        'a' { 'Rock' }
        'b' { 'Paper' }
        'c' { 'Scissors' }
        'x' { 'Lose' }
        'y' { 'Draw' }
        'z' { 'Win' }
    }
    $modifier, $score = switch ($outcome) {
        'Draw' { 0, 3 }
        'Lose' { -1, 0 }
        'Win'  { 1, 6 }
    }
    $player = $opponent + $modifier
    if ($player -gt 3) {
        $player = 1
    }
    if ($player -lt 1) {
        $player = 3
    }

    $total += $player + $score
}
$total
