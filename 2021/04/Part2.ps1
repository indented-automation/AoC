$draw, $boards = (gc "$PSScriptRoot\input.txt" -Raw) -split '(\r?\n){2}'
$draw = [System.Collections.Generic.Queue[string]]($draw -split ',')
$boards = $boards.Trim() -match '.+'

$index = @{}
$boardNumber = 0
$boards = foreach ($board in $boards) {
    $boardInfo = [PSCustomObject]@{
        Number = ($boardNumber++)
        Board  = [string[][]]::new(5, 5)
        Index  = @{}
        Marked = @{
            x = @{}
            y = @{}
        }
        Total  = 0
        HasWon = $false
    }
    $boardInfo

    $y = 0
    foreach ($row in $board -split '\r?\n') {
        $x = 0
        foreach ($column in $row.Trim() -split '\s+') {
            $value = $column

            $boardInfo.Total += $value -as [int]
            $boardInfo.Board[$x][$y] = $value
            $boardInfo.Index[$value] = $x, $y
            $index[$value] += @($boardInfo)
            $x++
        }
        $y++
    }
}

do {
    $value = $draw.Dequeue()
    if ($index.Contains($value)) {
        foreach ($board in $index[$value]) {
            if ($board.HasWon) {
                continue
            }

            $board.Total -= $value

            $x, $y = $board.Index[$value]
            $board.Marked['x'][$x]++
            $board.Marked['y'][$y]++

            if ($board.Marked['x'][$x], $board.Marked['y'][$y] -contains 5) {
                $board.HasWon = $true
                $last = $board.Total * $value
            }
        }
    }
} while ($draw.Count)
$last
