$reindeers = Get-Content "$PSScriptRoot\input.txt" |
    Where-Object { $_ -match '^(\S+)\D+(\d+)\skm.*?(\d+)\D+(\d+)' } |
    ForEach-Object {
        [PSCustomObject]@{
            Name     = $matches[1]
            Speed    = [int]$matches[2]
            FlyTime  = [int]$matches[3]
            RestTime = [int]$matches[4]
            Distance = 0
            Points   = 0
        }
    }

$points = 0
$totalTime = 2503
for ($time = 1; $time -le $totalTime; $time++) {
    $win = 0

    foreach ($reindeer in $reindeers) {
        $intervalTime = $reindeer.FlyTime + $reindeer.RestTime

        if ($time -le $intervalTime) {
            $reindeer.Distance = [Math]::Min($time, $reindeer.FlyTime) * $reindeer.Speed
        } else {
            $secondsRemaining = $time % $intervalTime
            $fullPeriods = ($time - $secondsRemaining) / $intervalTime
            $totalSecondsFlown = $fullPeriods * $reindeer.FlyTime

            $reindeer.Distance = $totalSecondsFlown * $reindeer.Speed +
                [Math]::Min($secondsRemaining, $reindeer.FlyTime) * $reindeer.Speed
        }

        if ($reindeer.Distance -gt $win) {
            $win = $reindeer.Distance
        }
    }

    foreach ($reindeer in $reindeers) {
        if ($reindeer.Distance -eq $win) {
            $reindeer.Points++
        }
        if ($reindeer.Points -gt $points) {
            $points = $reindeer.Points
        }
    }
}
$points
