class DeterministicDice {
    $values = 1..100
    $position = 0

    [int] Roll() {
        if ($this.position -eq $this.values.Count) {
            $this.position = 0
        }

        return $this.values[$this.position++]
    }
}

$players = Get-Content "$PSScriptRoot\input.txt" | Where-Object { $_ -match '^\S+\s(\d+).+:\s(\d+)' } | ForEach-Object {
    [PSCustomObject]@{
        Number   = $matches[1]
        Position = [int]$matches[2] - 1
        Score    = 0
    }
}

$dice = [DeterministicDice]::new()
$rolls = 0
:game while ($true) {
    foreach ($player in $players) {
        $roll = $dice.Roll(), $dice.Roll(), $dice.Roll()
        $rolls += 3

        $player.Position += $roll[0] + $roll[1] + $roll[2]
        if ($player.Position -gt 9) {
            $player.Position %= 10
        }
        $player.Score += $player.Position + 1

        if ($player.Score -ge 1000) {
            break game
        }
    }
}

[Math]::Min.Invoke($players.Score) * $rolls
