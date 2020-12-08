$f = gc "$PSScriptRoot\input.txt"
for (($x = 0), ($y = 0), ($t = 0); $y -lt $f.Count; ($x += 3), ($y++)) {
    if ($x -ge $f[$y].Length) {
        $x -= $f[$y].Length
    }
    $t += $f[$y][$x] -eq '#'
}
$t
