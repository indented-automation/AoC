$document = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt") -replace '\D+'
$race = @{
    Time   = [long]$document[0]
    Record = [long]$document[1]
}

$count = 0

for ($wait = 1; $wait -lt $race.Time; $wait++) {
    $speed = $wait
    $distance = $speed * ($race.Time - $wait)

    if ($distance -gt $race.Record) {
        $count++
    }
}
$count
