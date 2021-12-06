
# Least common multiple when each individual value repeats on each axis for each moon

$moonID = 1

$moons = Get-Content "$PSScriptRoot\input.txt" |
    Where-Object { $_ -match 'x=([\d-]+),\sy=([\d-]+),\sz=([\d-]+)' } |
    ForEach-Object {
        [PSCustomObject]@{
            ID        = ($moonID++)
            Position  = [PSCustomObject]@{
                x = $matches[1] -as [int]
                y = $matches[2] -as [int]
                z = $matches[3] -as [int]
            }
            Velocity = [PSCustomObject]@{
                x = 0
                y = 0
                z = 0
            }
        }
    }

$state = [PSCustomObject]@{
    x = [System.Collections.Generic.HashSet[string]]::new()
    y = [System.Collections.Generic.HashSet[string]]::new()
    z = [System.Collections.Generic.HashSet[string]]::new()
}

[long]$step = 1
while ($true) {
    foreach ($moon in $moons) {
        foreach ($moonPair in $moons) {
            foreach ($axis in 'x', 'y', 'z') {
                if ($moon.Position.$axis -lt $moonPair.Position.$axis) {
                    $moon.Velocity.$axis++
                }
                if ($moon.Position.$axis -gt $moonPair.Position.$axis) {
                    $moon.Velocity.$axis--
                }
            }
        }
    }

    foreach ($moon in $moons) {
        foreach ($axis in 'x', 'y', 'z') {
            $moon.Position.$axis += $moon.Velocity.$axis
        }
    }

    $xState = ''
    $yState = ''
    $zState = ''
    foreach ($moon in $moons) {
        $xState += '{0}:{1},{2}' -f $moon.ID, $moon.Position.x, $moon.Velocity.x
        $yState += '{0}:{1},{2}' -f $moon.ID, $moon.Position.y, $moon.Velocity.y
        $zState += '{0}:{1},{2}' -f $moon.ID, $moon.Position.z, $moon.Velocity.z
    }
    $x = -not $state.x.Add($xState)
    $y = -not $state.y.Add($yState)
    $z = -not $state.z.Add($zState)
    if ($x -and $y -and $z) {
        break
    }
    $step++
}

function Get-Lcm {
    param (
        [long]$Value1,
        [long]$Value2
    )

    for ($lcm = 1; ; $lcm++) {
        if (($Value1 * $lcm) % $Value2 -eq 0) {
            return $Value1 * $lcm
        }
    }
}

$lcm = Get-Lcm $state.x.Count $state.y.Count
Get-Lcm $state.z.Count $lcm
