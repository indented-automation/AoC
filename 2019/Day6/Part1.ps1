using namespace System.Collections.Generic

class CelestialBody {
    [string]              $Name
    [CelestialBody]       $Orbits
    [List[CelestialBody]] $OrbitedBy = [List[CelestialBody]]::new()

    [CelestialBody] AddOrbitingBody(
        [string] $name
    ) {
        $body = [CelestialBody]@{
            Name   = $name
            Orbits = $this
        }
        $this.OrbitedBy.Add($body)

        return $body
    }

    [string] ToString() {
        return $this.Name
    }
}

function Add-OrbitingBody {
    param (
        [CelestialBody]$CelestielBody
    )

    foreach ($orbitingBody in $unsortedObjects[$CelestielBody.Name]) {
        $parent = $CelestielBody.AddOrbitingBody($orbitingBody)

        Add-OrbitingBody -Name $orbitingBody -CelestielBody $parent
    }

    $unsortedObjects.Remove($celestielBody.Name)
}

function Get-OrbitingBody {
    param (
        [CelestialBody]$CelestielBody,
        [switch]$Recurse
    )

    foreach ($child in $CelestielBody.OrbitedBy) {
        $child
        if ($Recurse) {
            Get-OrbitingBody $child -Recurse
        }
    }
}

$unsortedObjects = @{}
gc $pwd\input.txt | ?{ $_ -match '(?<name>[^)]+)\)(?<orbitedBy>.+)' } | %{
    $unsortedObjects[$matches['name']] += @($matches['orbitedBy'])
}

$com = [CelestialBody]@{
    Name = 'com'
}
Add-OrbitingBody -CelestielBody $com

$direct = Get-OrbitingBody $com -Recurse
$i = 0
foreach ($body in $direct) {
    while ($body.Orbits) {
        $i++
        $body = $body.Orbits
    }
    $i--
}
$direct.Count + $i
