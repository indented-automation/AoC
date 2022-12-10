$data = [System.IO.StreamReader][System.IO.File]::OpenRead("$PSScriptRoot\input.txt")

Clear-Host

[Console]::SetCursorPosition(0, 0)
Write-Host '........................................'
Write-Host '........................................'
Write-Host '........................................'
Write-Host '........................................'
Write-Host '........................................'
Write-Host '........................................'

$next = 0
$x = $cycle = 1
$row = 0
$sprite = $pixel = 0
do {
    if ($pixel -eq 40) {
        $pixel = 0
        $row++
    }

    if ($pixel -ge $sprite - 1 -and $pixel -le $sprite + 1) {
        [Console]::SetCursorPosition($pixel, $row)
        [Console]::Write('#')
    }

    if ($next) {
        $x += $next
        $next = 0
        $sprite = $x
    } else {
        $operation = $data.ReadLine()
        if ($operation -match '^addx (-?\d+)$') {
            $next = $matches[1]
        }
    }

    $pixel++
    $cycle++
} until ($data.EndOfStream)

$data.Close()
