$pad = @(
    @(1, 2, 3),
    @(4, 5, 6),
    @(7, 8, 9)
)

$x = $y = 1
Get-Content $pwd\input.txt | ForEach-Object {
    switch ($_ -as [char[]]) {
        'U' {
            if ($y -gt 0) { $y-- }
        }
        'D' {
            if ($y -lt 2) { $y++ }
        }
        'R' {
            if ($x -lt 2) { $x++ }
        }
        'L' {
            if ($x -gt 0) { $x-- }
        }
    }
    $pad[$y][$x]
}
