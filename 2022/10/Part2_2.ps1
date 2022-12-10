$data = [System.IO.StreamReader][System.IO.File]::OpenRead("$PSScriptRoot\input.txt")

$screen = [System.Text.StringBuilder]::new()
1..6 | ForEach-Object {
    $null = $screen.AppendLine('........................................')
}

$next = 0
$x = $cycle = 1
$sprite = $pixel = 0
do {
    $position = $pixel % 40
    if ($position -ge $sprite - 1 -and $position -le $sprite + 1) {
        $lineBreakChars = [Environment]::NewLine.Length * (($pixel - $position) / 40)
        $null = $screen.Replace('.', '#', ($pixel + $lineBreakChars), 1)
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

$screen.ToString()
