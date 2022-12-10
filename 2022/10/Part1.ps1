$data = [System.IO.StreamReader][System.IO.File]::OpenRead("$PSScriptRoot\input.txt")

$next = 0
$x = $cycle = 1
$sum = 0
do {
    if (($cycle - 20) % 40 -eq 0) {
        $sum += $cycle * $x
    }

    if ($next) {
        $x += $next
        $next = 0
    } else {
        $operation = $data.ReadLine()
        if ($operation -match '^addx (-?\d+)$') {
            $next = $matches[1]
        }
    }

    $cycle++
} until ($data.EndOfStream)

$data.Close()

$sum
