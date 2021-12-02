$p = $d = 0
switch -Regex (gc input.txt) {
    'forward (\d+)' { $p += $matches[1] }
    'up (\d+)' { $d -= $matches[1] }
    'down (\d+)' { $d += $matches[1] }
}
$p * $d
