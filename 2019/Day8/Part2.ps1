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

Add-Type -AssemblyName System.Drawing

$bitMap = [System.Drawing.BitMap]::new(25, 6)
for ($i = 0; $i -lt $layers.Count; $i++) {
    $layer = $layers[$i]
    $rows = $layer -split '\n'

    for ($j = 0; $j -lt 6; $j++) {
        $row = $rows[$j]

        for ($k = 0; $k -lt 25; $k++) {
            $colour = switch ($row[$k]) {
                0 { 'Black' }
                1 { 'White' }
            }

            $pixel = $bitMap.GetPixel($k, $j)
            if ($pixel.Name -eq 0 -and $colour) {
                $bitMap.SetPixel($k, $j, $colour)
            }
        }
    }
}

$bitMap.Save("$pwd\image.bmp")
