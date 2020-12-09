$i = 0
$in = (gc $PSScriptRoot\input.txt) -as [long[]]

$length = 25

$queue = [System.Collections.Generic.Queue[long]]::new($length * $length)
$invalidNum = for ($i = 0; $i -lt $in.Count; $i++) {
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

:all for ($i = 0; $i -lt $in.Count; $i++) {
    if ($in[$i] -le $invalidNum) {
        $j = $i
        $sum = 0
        $set = [System.Collections.Generic.List[long]]::new()
        while ($j -gt 0 -and $sum -le $invalidNum) {
            $set.Add($in[$j])
            $sum += $in[$j]
            if ($set.Count -ge 2 -and $sum -eq $invalidNum) {
                break all
            }
            $j--
        }
    }
}
$set = $set | sort
$set[0] + $set[-1]
