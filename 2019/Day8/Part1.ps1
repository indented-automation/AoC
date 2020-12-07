$raw = gc "$pwd\input.txt" -raw

$rows = for ($i = 0; $i -lt $raw.Length - 25; $i += 25) {
    $row = for ($j = 0; $j -lt 25; $j++) {
        $raw[$i + $j]
    }
    [string]::new($row)
}

$layers = for ($i = 0; $i -lt $rows.Count - 6; $i += 6) {
    $layer = for ($j = 0; $j -lt 6; $j++) {
        $rows[$i + $j]
    }
    $layer -join "`n"
}

$min = 25 * 6
$layer = 0
for ($i = 0; $i -lt $layers.Count; $i++) {
    $count = ($layers[$i] -replace '[^0]').Length
    if ($count -lt $min) {
        $min = $count
        $layer = $i
    }
}
($layers[$layer] -replace '[^1]').Length * ($layers[$layer] -replace '[^2]').Length
