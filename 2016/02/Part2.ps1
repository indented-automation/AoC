$n = $null
$pad = @(
    @($n,  $n,  1,   $n,   $n),
    @($n,   2,   3,   4,   $n)
    @( 5,    6,   7,   8,   9),
    @($n,  'A', 'B', 'C',  $n),
    @($n,  $n,  'D', $n,   $n)
)

$x = 0
$y = 2
$code = Get-Content $pwd\input.txt | ForEach-Object {
    switch ($_ -as [char[]]) {
        'U' {
            if ($y -gt 0 -and $pad[$y - 1][$x]) {
                $y--
            }
        }
        'D' {
            if ($y -lt 4 -and $pad[$y + 1][$x]) {
                $y++
            }
        }
        'R' {
            if ($x -lt 4 -and $pad[$y][$x + 1]) {
                $x++
            }
        }
        'L' {
            if ($x -gt 0 -and $pad[$y][$x - 1]) {
                $x--
            }
        }
    }
    $pad[$y][$x]
}
-join $code
