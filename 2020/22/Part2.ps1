$content = gc $PSScriptRoot\input.txt

$Player1 = [System.Collections.Generic.Queue[int]]::new()
$Player2 = [System.Collections.Generic.Queue[int]]::new()

foreach ($line in $content) {
    if ($line -match 'Player 1:') {
        $queue = $Player1
    }
    if ($line -match 'Player 2:') {
        $queue = $Player2
    }
    if ($line -match '^\d+$') {
        $queue.Enqueue($matches[0])
    }
}

function Start-Game {
    [CmdletBinding()]
    param (
        [System.Collections.Generic.Queue[int]]$Player1,

        [System.Collections.Generic.Queue[int]]$Player2
    )

    $round = 1

    $p1Hands = [System.Collections.Generic.HashSet[string]]::new()
    $p2Hands = [System.Collections.Generic.HashSet[string]]::new()

    do {
        if (-not $p1Hands.Add("$Player1") -or -not $p2Hands.Add("$Player2")) {
            $Player2.Clear()

            return 'Player1'
        }

        $player1Draw = $Player1.Dequeue()
        $player2Draw = $Player2.Dequeue()

        if ($Player1.Count -ge $player1Draw -and $Player2.Count -ge $player2Draw) {
            $params = @{
                Player1 = $Player1.ToArray()[0..($player1Draw - 1)]
                Player2 = $Player2.ToArray()[0..($player2Draw - 1)]
            }
            $winner = Start-Game @params
        } else  {
            if ($player1Draw -gt $player2Draw) {
                $winner = 'Player1'
            } else {
                $winner = 'Player2'
            }
        }

        switch ($winner) {
            'Player1' {
                $Player1.Enqueue($player1Draw)
                $Player1.Enqueue($player2Draw)
            }
            'Player2' {
                $Player2.Enqueue($player2Draw)
                $Player2.Enqueue($player1Draw)
            }
        }

        $round++
    } while ($Player1.Count -gt 0 -and $Player2.Count -gt 0)

    if ($Player1.Count -gt 0) {
        'Player1'
    } else {
        'Player2'
    }
}

$winner = Start-Game -Player1 $Player1 -Player2 $Player2

if ($winner -eq 'Player1') {
    $queue = $Player1
} else {
    $queue = $Player2
}

$score = 0
for ($i = $queue.Count - 1; $i -ge 0; $i--) {
    $score += $queue.Dequeue() * ($i + 1)
}
$score
