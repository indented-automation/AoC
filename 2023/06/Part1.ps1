$document = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$time = $document[0] -split '\s+'
$distance = $document[1] -split '\s+'

$races = for ($i = 1; $i -lt $time.Count; $i++) {
    @{
        Time   = [int]$time[$i]
        Record = [int]$distance[$i]
    }
}

$multiple = 1
foreach ($race in $races) {
    $count = 0

    for ($wait = 1; $wait -lt $race.Time; $wait++) {
        $speed = $wait
        $distance = $speed * ($race.Time - $wait)

        if ($distance -gt $race.Record) {
            $count++
        }
    }
    if ($count -gt 0) {
        $multiple *= $count
    }
}
$multiple
