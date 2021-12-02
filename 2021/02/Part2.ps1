$p = $d = $a = 0
switch -Regex (gc input.txt) {
    'forward (\d+)' {
        $p += $matches[1]
        $d += $a * $matches[1]
    }
    'up (\d+)' { $a -= $matches[1] }
    'down (\d+)' { $a += $matches[1] }
}
$p * $d
