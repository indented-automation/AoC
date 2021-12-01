$n = (gc input.txt) -as [int[]]
for ($i = $j = $k = 0; $i -lt $n.Count - 2; $i++) {
    $a, $b, $c = $n[$i..($i + 2)]
    $s = $a + $b + $c
    if ($j -gt 0 -and $s -gt $j) {
        $k++
    }
    $j = $s
}
$k
