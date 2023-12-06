function Get-PointInGraph {
    <#
        Find the point in the graph where it changes between breaking the
        record and not using a half-interval search in each direction.
    #>
    param (
        [switch]
        $High
    )

    $modifier = -1
    if ($High) {
        $modifier = 1
    }

    $point = $interval = [Math]::Ceiling($race.Time / 2)
    $overtime = 0
    do {
        $distance = $point * ($race.Time - $point)

        if ($distance -gt $race.Record) {
            $neighbour = $point + $modifier
            $neighbourDistance = $neighbour * ($race.Time - $neighbour)

            if ($neighbourDistance -le $race.Record) {
                # Because we found the point it changes
                break
            }

            $point += $interval * $modifier
        } else {
            $point -= $interval * $modifier
        }

        $interval = [Math]::Ceiling($interval / 2)
        # Allow a small amount of extra testing because of rounding
        if ($interval -eq 1) {
            $overtime++
        }
    } while ($interval -gt 1 -or $overtime -lt 2)

    $point
}

$document = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt") -replace '\D+'
$race = @{
    Time   = [long]$document[0]
    Record = [long]$document[1]
}

$low = Get-PointInGraph
$high = Get-PointInGraph -High

# Number breaking the record is inclusive of the first number
$high - $low + 1
