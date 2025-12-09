using namespace NetTopologySuite
using namespace NetTopologySuite.Geometries
using namespace NetTopologySuite.Geometries.Utilities
using namespace System.IO
using namespace System.Collections.Generic

[CmdletBinding()]
param (
    [switch]
    $Sample
)

class Point {
    [long]
    $x

    [long]
    $y

    hidden [string] $_name

    Point([string] $value) {
        $this._name = $value
        $this.x, $this.y = $value -split ','
    }

    [string] ToString() {
        return $this._name
    }
}

# https://www.nuget.org/packages/nettopologysuite
Add-Type -Path ([Path]::Combine($PSScriptRoot, 'NetTopologySuite.dll'))

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

[Point[]]$points = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName))

$factory = [NtsGeometryServices]::Instance.CreateGeometryFactory()

[Coordinate[]]$coordinates = @(
    foreach ($a in $points) {
        [Coordinate]::new($a.x, $a.y)
    }
    [Coordinate]::new($points[0].x, $points[0].y)
)
$polygon = $factory.CreatePolygon($coordinates)

$unique = [HashSet[string]]::new()
$area = 0
foreach ($a in $points) {
    foreach ($b in $points) {
        if ($a -eq $b) {
            continue
        }
        $id = -join ($a, $b | Sort-Object)
        if (-not $unique.Add($id)) {
            continue
        }

        $minX = [Math]::Min($a.x, $b.x)
        $maxX = [Math]::Max($a.x, $b.x)
        $minY = [Math]::Min($a.y, $b.y)
        $maxY = [Math]::Max($a.y, $b.y)

        $rectangle = $factory.CreatePolygon(
            [Coordinate[]]@(
                [Coordinate]::new($minX, $minY),
                [Coordinate]::new($minX, $maxY),
                [Coordinate]::new($maxX, $maxY),
                [Coordinate]::new($maxX, $minY),
                [Coordinate]::new($minX, $minY)
            )
        )
        $null = [GeometryFixer]::Fix($rectangle)

        if ($rectangle.CoveredBy($polygon)) {
            $area = [Math]::Max(($maxX - $minX + 1) * ($maxY - $minY + 1), $area)
        }
    }
}
$area
