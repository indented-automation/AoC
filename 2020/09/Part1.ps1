$i = 0
$in = (gc $PSScriptRoot\input.txt) -as [long[]]

$length = 25

$queue = [System.Collections.Generic.Queue[long]]::new($length * $length)
for ($i = 0; $i -lt $in.Count; $i++) {
    $start = $i - $length - 1
    $end = $i - 1
    for ($j = $start; $j -lt $end; $j++) {
        if ($j -gt 0) {
            $queue.Enqueue($in[$j] + $in[$end])
        }
    }
    while ($queue.Count -gt ($length * $length)) {
        $null = $queue.Dequeue()
    }
    if ($i -gt $length -and $queue -notcontains $in[$i]) {
        $in[$i]
        break
    }
}
