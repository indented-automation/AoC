$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$beaconsByRow = @{}
$sensors = foreach ($record in $data) {
    if ($record -match 'x=(?<sx>-?\d+),\sy=(?<sy>-?\d+).+x=(?<bx>-?\d+),\sy=(?<by>-?\d+)') {
        $sensor = [PSCustomObject]@{
            id     = $matches['sx','sy'] -join ','
            x      = [int]$matches['sx']
            y      = [int]$matches['sy']
            bx     = [int]$matches['bx']
            by     = [int]$matches['by']
            radius = 0
            area   = @{}
        }
        $sensor.radius = (
            [Math]::Abs($sensor.x - $sensor.bx) +
            [Math]::Abs($sensor.y - $sensor.by)
        )
        $sensor.area = @{
            n = $sensor.y - $sensor.radius
            s = $sensor.y + $sensor.radius
            e = $sensor.x + $sensor.radius
            w = $sensor.x - $sensor.radius
        }
        $sensor

        if ($beaconsByRow.Contains($sensor.by)) {
            $beaconsByRow[$sensor.by].Add($sensor.bx)
        } else {
            $beaconsByRow[$sensor.by] = [System.Collections.Generic.SortedSet[int]]@(
                $sensor.bx
            )
        }
    }
}

$row = 2000000

$regions = $sensors | Where-Object {
    $_.area.n -le $row -and
    $_.area.s -ge $row
} | ForEach-Object {
    $distance = $_.radius - [Math]::Abs($_.y - $row)

    [PSCustomObject]@{
        Id       = $_.id
        Low      = $_.x - $distance
        High     = $_.x + $distance
        IsMerged = $false
    }
} | Sort-Object Low

foreach ($reference in $regions) {
    if ($reference.IsMerged) { continue }

    foreach ($difference in $regions) {
        if ($difference.Low -ge $reference.Low -and $difference.Low -le $reference.High) {
            $reference.High = [Math]::Max(
                $reference.High,
                $difference.High
            )
            $difference.IsMerged = $true
            $reference.IsMerged = $false
        }
        if ($difference.High -ge $reference.Low -and $difference.High -le $reference.High) {
            $reference.Low = [Math]::Min(
                $reference.Low,
                $difference.Low
            )
            $difference.IsMerged = $true
            $reference.IsMerged = $false
        }
    }
}
$regions = $regions | Where-Object IsMerged -eq $false

$area = 0
foreach ($region in $regions) {
    $area += [Math]::Abs($region.High - $region.Low) + 1 # Inclusive
}
foreach ($beacon in $beaconsByRow[$row]) {
    foreach ($region in $regions) {
        if ($beacon -ge $region.Low -and $beacon -le $region.High) {
            $area--
        }
    }
}
$area
