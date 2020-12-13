[int]$timestamp, $timetable = gc $pwd\input.txt
$buses = $timetable -split ',' -ne 'x' -as [int[]]

$difference = $timestamp
$bus = 0
$waitTime = 0
$buses | %{
    $next = $timestamp - $timestamp % $_ + $_
    $nextDiff = $next - $timestamp
    if ($nextDiff -lt $difference) {
        $difference = $nextDiff
        $bus = $_
        $waitTime = $bus * $difference
    }
}
$waitTime
