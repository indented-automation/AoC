using namespace System.Collections.Generic

function Import-Scanners {
    $content = Get-Content "$PSScriptRoot\input.txt" -Raw
    $content -split '---\sscanner\s' | Where-Object { $_ -match '(?s)^(\d+)\s---(.+)' } | ForEach-Object {
        $scanner = [PSCustomObject]@{
            Scanner     = $matches[1]
            Beacons     = @{}
            Relative    = [Ordered]@{}
        }
        $scanner

        $scanner.Beacons = [List[int[]]]::new()

        $matches[2] -split '\r?\n' -match '.' | ForEach-Object {
            $scanner.Beacons.Add(($_ -split ',' -as [int[]]))
        }
    }
}

function New-MappingSet {
    [CmdletBinding()]
    param (
        $Scanner
    )

    $sets = @{}

    $set = 0

    # These comparison sets exclude one beacon, the reference point.
    foreach ($referenceBeacon in $Scanner.Beacons) {
        $sets["$set"] = @{}

        foreach ($beacon in $scanner.Beacons) {
            if ("$referenceBeacon" -ne "$beacon") {
                $r = [PSCustomObject]@{
                    Distance         = ''
                    AbsoluteDistance = ''
                    Beacon           = $beacon
                    Scanner          = $scanner.Scanner
                    Set              = "$set"
                    Point            = @(
                        $beacon[0] - $referenceBeacon[0]
                        $beacon[1] - $referenceBeacon[1]
                        $beacon[2] - $referenceBeacon[2]
                    )
                }
                $r.Distance = $r.Point
                $r.AbsoluteDistance = ([Math]::Abs($r.Point[0]), [Math]::Abs($r.Point[1]), [Math]::Abs($r.Point[2]) | Sort-Object) -join ','
                $sets["$set"][$r.AbsoluteDistance] = $r
            }
        }
        $set++
    }

    $sets
}

function Find-NextScanner {
    param (
        $ReferenceScanner,

        $Scanners
    )

    $referenceSets = New-MappingSet $ReferenceScanner

    foreach ($differenceScanner in $Scanners) {
        $differenceSets = New-MappingSet $differenceScanner

        foreach ($referenceSet in $referenceSets.Keys) {
            foreach ($differenceSet in $differenceSets.Keys) {
                $count = 0

                $distances = foreach ($beacon in $differenceSets[$differenceSet].Values) {
                    if ($referenceSets[$referenceSet].Contains($beacon.AbsoluteDistance)) {
                        $beacon.AbsoluteDistance
                        $count++
                    }
                }

                if ($count -ge 11) {
                    return [PSCustomObject]@{
                        Scanner       = $differenceScanner
                        ReferenceSet  = $referenceSets[$referenceSet]
                        DifferenceSet = $differenceSets[$differenceSet]
                        Distances     = $distances
                    }
                }
            }
        }
    }
}

function Get-FirstBeacon {
    [CmdletBinding()]
    param (
        $ReferenceScanner,

        $DifferenceScanner,

        [Hashtable]$ReferenceSet,

        [Hashtable]$DifferenceSet,

        [string[]]$Distances
    )

    foreach ($distance in $Distances) {
        if (([HashSet[string]]($distance -split ',')).Count -lt 3) {
            continue
        }

        $referenceBeacon = $ReferenceSet[$distance]
        $differenceBeacon = $DifferenceSet[$distance]

        return [PSCustomObject]@{
            Reference  = $referenceBeacon
            Difference = $differenceBeacon
        }
    }
}

function Get-PositionMap {
    [CmdletBinding()]
    param (
        $Reference,

        $Difference
    )

    for ($i = 0; $i -lt 3; $i++) {
        [Math]::Max($Difference.Distance.IndexOf($Reference.Distance[$i]), $Difference.Distance.IndexOf(-1 * $Reference.Distance[$i]))
    }
}

function Get-Orientation {
    [CmdletBinding()]
    param (
        $Reference,

        $Difference,

        [int[]]$Map
    )

    @(
        $Reference.Distance[0] / $Difference.Distance[$Map[0]]
        $Reference.Distance[1] / $Difference.Distance[$Map[1]]
        $Reference.Distance[2] / $Difference.Distance[$Map[2]]
    )
}

function Get-ScannerPosition {
    [CmdletBinding()]
    param (
        $ReferenceBeacon,

        $DifferenceBeacon,

        [int[]]$Map,

        [int[]]$Orientation
    )

    @(
        $ReferenceBeacon[0] - ($Orientation[0] * $DifferenceBeacon[$Map[0]])
        $ReferenceBeacon[1] - ($Orientation[1] * $DifferenceBeacon[$Map[1]])
        $ReferenceBeacon[2] - ($Orientation[2] * $DifferenceBeacon[$Map[2]])
    )
}

function Convert-BeaconPosition {
    [CmdletBinding()]
    param (
        $Beacon,

        [int[]]$Orientation,

        [int[]]$ScannerPosition,

        [int[]]$Map
    )

    @(
        $ScannerPosition[0] - (($Orientation[0] * -1) * $Beacon[$Map[0]])
        $ScannerPosition[1] - (($Orientation[1] * -1) * $Beacon[$Map[1]])
        $ScannerPosition[2] - (($Orientation[2] * -1) * $Beacon[$Map[2]])
    )
}

function Merge-Beacons {
    [CmdletBinding()]
    param (
        $To,

        $From,

        [int[]]$Orientation,

        [int[]]$ScannerPosition,

        [int[]]$Map
    )

    $allBeacons = @{}
    foreach ($beacon in $To.Beacons) {
        $allBeacons["$beacon"] = $beacon
    }

    foreach ($beacon in $From.Beacons) {
        $newPosition = Convert-BeaconPosition -Beacon $beacon -Orientation $Orientation -ScannerPosition $ScannerPosition -Map $Map
        $allBeacons["$newPosition"] = $newPosition
    }

    $To.Beacons = [List[int[]]]::new()
    foreach ($beacon in $allBeacons.Keys) {
        $To.Beacons.Add($allBeacons[$beacon] -as [int[]])
    }
}

#
# Main
#

$referenceScanner, $scanners = Import-Scanners

$allScanners = @{
    '0' = 0, 0, 0
}
while ($scanners) {
    $nextScanner = Find-NextScanner -Reference $referenceScanner -Scanners $scanners

    $params = @{
        ReferenceScanner  = $referenceScanner
        DifferenceScanner = $nextScanner.Scanner
        ReferenceSet      = $nextScanner.ReferenceSet
        DifferenceSet     = $nextScanner.DifferenceSet
        Distances         = $nextScanner.Distances
    }
    $beacons = Get-FirstBeacon @params
    $map = Get-PositionMap -Reference $beacons.Reference -Difference $beacons.Difference

    $common = @{
        Map = $map
    }
    $common['Orientation'] = Get-Orientation -Reference $beacons.Reference -Difference $beacons.Difference @common
    $common['ScannerPosition'] = Get-ScannerPosition -ReferenceBeacon $beacons.Reference.Beacon -DifferenceBeacon $beacons.Difference.Beacon @common

    $allScanners["$($nextScanner.Scanner.Scanner)"] = $common['ScannerPosition']

    Merge-Beacons -From $nextScanner.Scanner -To $referenceScanner @common

    $scanners = $scanners | Where-Object Scanner -ne $nextScanner.Scanner.Scanner
}

$largest = 0
foreach ($i in $allScanners.Keys) {
    foreach ($j in $allScanners.Keys) {
        if ($i -ne $j) {
            $distance = [Math]::Abs($allScanners[$i][0] - $allScanners[$j][0]) +
                [Math]::Abs($allScanners[$i][1] - $allScanners[$j][1]) +
                [Math]::Abs($allScanners[$i][2] - $allScanners[$j][2])

            $largest = [Math]::Max($largest, $distance)
        }
    }
}
$largest
