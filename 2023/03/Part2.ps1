$schematic = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$numbers = @{}
$symbols = @{}

for ($y = 0; $y -lt $schematic.Count; $y++) {
    $line = $schematic[$y]

    for ($x = 0; $x -lt $line.Length; $x++) {
        $value = [string]$line[$x]

        if ($value -notmatch '[\d*]') {
            continue
        }

        $extent = [PSCustomObject]@{
            value = $value
            pos   = "$x,$y"
            xs    = $x
            xe    = $x
            y     = $y
            adj   = $null
        }

        if ($value -match '\d') {
            while (($next = [string]$line[$x + 1]) -and $next -match '\d') {
                $extent.value += $next
                $extent.xe = $x + 1
                $x++
            }
            $extent.value = [int]$extent.value
            $numbers["$x,$y"] = $extent
        } else {
            $symbols["$x,$y"] = $extent
        }
    }
}

$adj = @{}
foreach ($extent in $Numbers.Values) {
    $around = @(
        for ($x = $extent.xs - 1; $x -le $extent.xe + 1; $x++) {
            '{0},{1}' -f $x, ($extent.y - 1)
            '{0},{1}' -f $x, ($extent.y + 1)
        }
        '{0},{1}' -f ($extent.xs - 1), $extent.y
        '{0},{1}' -f ($extent.xe + 1), $extent.y
    )
    foreach ($pos in $around) {
        if ($symbols.Contains($pos)) {
            $extent.adj = $pos
            $adj[$pos] += @($extent)
            break
        }
    }
}

$sum = 0
foreach ($value in $adj.Values) {
    if ($value.Count -gt 1) {
        $sum += $value[0].Value * $value[1].Value
    }
}
$sum
