$steps = Get-Content "$PSSCriptRoot\input.txt" | Where-Object { $_ -match '^(\S+)\sx=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)' } | ForEach-Object {
    [PSCustomObject]@{
        Action = $matches[1]
        x      = $matches[2], $matches[3] -as [int[]]
        y      = $matches[4], $matches[5] -as [int[]]
        z      = $matches[6], $matches[7] -as [int[]]
    }
}

$on = @{}
foreach ($step in $steps) {

    if ($step.x[0] -gt 50 -or $step.x[-1] -lt -50) {
        continue
    }
    if ($step.y[0] -gt 50 -or $step.y[-1] -lt -50) {
        continue
    }
    if ($step.z[0] -gt 50 -or $step.z[-1] -lt -50) {
        continue
    }

    for ($x = [Math]::Max($step.x[0], -50); $x -le [Math]::Min($step.x[1], 50); $x++) {
        for ($y = [Math]::Max($step.y[0], -50); $y -le [Math]::Min($step.y[1], 50); $y++) {
            for ($z = [Math]::Max($step.z[0], -50); $z -le [Math]::Min($step.z[1], 50); $z++) {
                $cuboid = "$x,$y,$z"

                if ($step.Action -eq 'on') {
                    $on[$cuboid] = 1
                } else {
                    if ($on.Contains($cuboid)) {
                        $on.Remove($cuboid)
                    }
                }
            }
        }
    }
}

$on.Count
