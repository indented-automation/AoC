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

$steps = 1000

for ($step = 1; $step -le $steps; $step++) {
    # Apply Gravity

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

    # Apply Velocity

    foreach ($moon in $moons) {
        foreach ($axis in 'x', 'y', 'z') {
            $moon.Position.$axis += $moon.Velocity.$axis
        }
    }
}

$totalEnergy = 0
foreach ($moon in $moons) {
    $potentialEnergy = 0
    foreach ($property in $moon.Position.PSObject.Properties) {
        $potentialEnergy += [Math]::Abs($property.Value)
    }

    $kineticEnergy = 0
    foreach ($property in $moon.Velocity.PSObject.Properties) {
        $kineticEnergy += [Math]::Abs($property.Value)
    }

    $totalEnergy += $potentialEnergy * $kineticEnergy
}
$totalEnergy
