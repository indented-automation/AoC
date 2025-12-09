using namespace System.Collections.Generic
using namespace System.IO

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

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

[Point[]]$points = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName))

$area = 0
foreach ($a in $points) {
    foreach ($b in $points) {
        if ($a -eq $b) {
            continue
        }

        $minX = [Math]::Min($a.x, $b.x)
        $maxX = [Math]::Max($a.x, $b.x)
        $minY = [Math]::Min($a.y, $b.y)
        $maxY = [Math]::Max($a.y, $b.y)

        $area = [Math]::Max(($maxX - $minX + 1) * ($maxY - $minY + 1), $area)
    }
}
$area
