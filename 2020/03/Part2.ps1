$f = gc "$PSScriptRoot\input.txt"
$s = 1
foreach ($p in @(1, 1), @(3, 1), @(5, 1), @(7, 1), @(1, 2)) {
    for (($x = 0), ($y = 0), ($t = 0); $y -lt $f.Count; ($x += $p[0]), ($y += $p[1])) {
        if ($x -ge $f[$y].Length) {
            $x -= $f[$y].Length
        }
        $t += $f[$y][$x] -eq '#'
    }
    $s *= $t
}
$s
