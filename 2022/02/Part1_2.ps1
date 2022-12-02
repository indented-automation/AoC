enum Move {
    Rock
    Paper
    Scissors
    a = 0
    b
    c
    x = 0
    y
    z
}

$total = 0
foreach ($move in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    [Move]$opponent, [Move]$player = $move -split '\s+'
    $total += $player + 1 +
        3 * ($opponent -eq $player) +
        6 * (($opponent + 1) % 3 -eq $player)
}
$total
