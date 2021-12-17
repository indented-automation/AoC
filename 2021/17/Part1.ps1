$null = (Get-Content "$PSScriptRoot\input.txt" -Raw) -match 'x=([-\d]+)\.\.([-\d]+), y=([-\d]+)\.\.([-\d]+)'
$target = @{
    x = [int]$matches[1]..[int]$matches[2]
    y = [int]$matches[3]..[int]$matches[4]
}
$start = @{ x = 0; y = 0 }

# Just brute force this
$r = for ($vx = 1; $vx -le $target.x[0]; $vx++) {
    for ($vy = 0; $vy -le [Math]::Abs($target.y[0]); $vy++) {
        $step = 1
        $position = $start.Clone()

        $x = $vx
        $y = $vy
        $py = 0
        :attempt do {
            $position.x += $x
            $position.y += $y

            if ($position.y -gt $py) {
                $py = $position.y
            }

            if ($x -gt 0) {
                $x--
            }
            $y--

            # Never going to make it
            if ($x -eq 0 -and $position.x -lt $target.x[0]) {
                break attempt
            }
            # Too far down
            if ($position.y -lt $target.y[0]) {
                break attempt
            }

            if ($position.x -in $target.x -and $position.y -in $target.y) {
                [PSCustomObject]@{
                    vx   = $vx
                    vy   = $vy
                    x    = $position.x
                    y    = $position.y
                    py   = $py
                    step = $step
                }
            }

            $step++
        } while ($position.y -gt $target.y[0])
    }
}
($r | Sort-Object py | Select-Object -Last 1).py
