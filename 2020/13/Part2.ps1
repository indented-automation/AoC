# This isn't mine. I don't really understand why it works. Leaving it like this to study another time.

$null, $timetable = (gc $pwd\input.txt) -split ','

$timestamp = 0l
$increment = $timetable[0] -as [long]
for ($i = 1; $i -lt $timetable.Count; $i++) {
    if ($timetable[$i] -ne 'x') {
        $newTime = $timetable[$i] -as [long]
        while ($true) {
            $timestamp += $increment
            if (($timestamp + $i) % $newTime -eq 0) {
                $increment *= $newTime
                break
            }
        }
    }
}
$timestamp
