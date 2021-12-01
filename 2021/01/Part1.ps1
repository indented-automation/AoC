$n = (gc input.txt) -as [int[]]
for ($i = $j = 0; $i -lt $n.Count - 1; $i++) {
    if ($n[$i + 1] -gt $n[$i]) {
        $j++
    }
}
$j
