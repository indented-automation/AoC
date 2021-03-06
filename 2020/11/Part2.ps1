$Rows = Get-Content $PSScriptRoot\input.txt

$directions = @(
    @(-1, 0),   # Left
    @(1, 0),    # Right
    @(0, -1),   # Up
    @(0, 1),    # Down
    @(-1, -1),  # Left Up
    @(-1, 1),   # Left Down
    @(1, -1),   # Right Up
    @(1, 1)     # Right Down
)

do {
    $workingRows = $Rows.Clone()
    for ($i = 0; $i -lt $workingRows.Count; $i++) {
        $workingRows[$i] = $workingRows[$i].ToCharArray()
    }

    $changed = 0

    for ($y = 0; $y -lt $workingRows.Count; $y++) {
        $row = $workingRows[$y]

        for ($x = 0; $x -lt $row.Count; $x++) {
            if ($row[$x] -eq '.') {
                continue
            }

            $occupied = 0
            foreach ($direction in $directions) {
                $xValue = $x
                $yValue = $y

                while ($true) {
                    $xValue += $direction[0]
                    $yValue += $direction[1]

                    if ($xValue -lt 0 -or $xValue -ge $row.Count -or $yValue -lt 0 -or $yValue -ge $rows.Count) {
                        break
                    }

                    if ($Rows[$yValue][$xValue] -eq 'L') {
                        break
                    }

                    if ($Rows[$yValue][$xValue] -eq '#') {
                        $occupied++
                        break
                    }
                }
            }

            if ($workingRows[$y][$x] -ne '#' -and $occupied -eq 0) {
                $workingRows[$y][$x] = '#'
                $changed++
            } elseif ($workingRows[$y][$x] -eq '#' -and $occupied -ge 5) {
                $workingRows[$y][$x] = 'L'
                $changed++
            }
        }
    }

    for ($i = 0; $i -lt $workingRows.Count; $i++) {
        $workingRows[$i] = -join $workingRows[$i]
    }
    $Rows = $workingRows
} while ($changed)
(-join $Rows -replace '[^#]').Length
