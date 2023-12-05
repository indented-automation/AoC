$reindeers = Get-Content "$PSScriptRoot\input.txt" |
    Where-Object { $_ -match '^(\S+)\D+(\d+)\skm.*?(\d+)\D+(\d+)' } |
    ForEach-Object {
        [PSCustomObject]@{
            Name     = $matches[1]
            Speed    = [int]$matches[2]
            FlyTime  = [int]$matches[3]
            RestTime = [int]$matches[4]
        }
    }
$max = 0
$totalTime = 2503
foreach ($reindeer in $reindeers) {
    $intervalTime = $reindeer.FlyTime + $reindeer.RestTime

    if ($totalTime -lt $intervalTime) {
        $distance = [Math]::Min($totalTime, $reindeer.FlyTime) * $reindeer.Speed
    } else {
        $secondsRemaining = $totalTime % $intervalTime
        $fullPeriods = ($totalTime - $secondsRemaining) / $intervalTime
        $totalSecondsFlown = $fullPeriods * $reindeer.FlyTime

        $distance = $totalSecondsFlown * $reindeer.Speed +
            [Math]::Min($secondsRemaining, $reindeer.FlyTime) * $reindeer.Speed
    }

    if ($distance -gt $max) {
        $max = $distance
    }
}
$max
