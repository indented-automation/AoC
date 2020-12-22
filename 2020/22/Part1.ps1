$content = gc $PSScriptRoot\input.txt

$hands = [PSCustomObject]@{
    Player1 = [System.Collections.Generic.Queue[int]]::new()
    Player2 = [System.Collections.Generic.Queue[int]]::new()
}

foreach ($line in $content) {
    if ($line -match 'Player (\d+):') {
        $queue = $hands."Player$($matches[1])"
    }
    if ($line -match '^\d+$') {
        $queue.Enqueue($matches[0])
    }
}

do {
    $player1Draw = $hands.Player1.Dequeue()
    $player2Draw = $hands.Player2.Dequeue()

    if ($player1Draw -gt $player2Draw) {
        $hands.Player1.Enqueue($player1Draw)
        $hands.Player1.Enqueue($player2Draw)
    } else {
        $hands.Player2.Enqueue($player2Draw)
        $hands.Player2.Enqueue($player1Draw)
    }
} while ($hands.Player1.Count -gt 0 -and $hands.Player2.Count -gt 0)

if ($hands.Player1.Count -gt 0) {
    $queue = $hands.Player1
} else {
    $queue = $hands.Player2
}

$score = 0
for ($i = $queue.Count - 1; $i -ge 0; $i--) {
    $score += $queue.Dequeue() * ($i + 1)
}
$score
