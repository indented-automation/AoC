function Get-Direction {
    param ( $start, $end )

    if ($start -eq $end) {
        0
    } elseif ($start -lt $end) {
        1
    } else {
        -1
    }
}

$lines = gc "$PSScriptRoot\input.txt" | ForEach-Object {
    $start, $end = $_ -split ' -> '
    [PSCustomObject]@{
        Start     = $start
        End       = $end
        Direction = $null
    }
} | ForEach-Object {
    $_.PSObject.Properties | ForEach-Object {
        $x, $y = $_.Value -split ','
        $_.Value = [PSCustomObject]@{
            Position = "$x $y"
            x        = [int]$x
            y        = [int]$y
        }
    }
    $_.Direction = @(
        Get-Direction $_.Start.X $_.End.X
        Get-Direction $_.Start.Y $_.End.Y
    )
    $_
}


$lines = $lines | Where-Object { $_.Start.x -eq $_.End.x -or $_.Start.y -eq $_.End.y }

$visited = @{}
$count = 0
foreach ($line in $lines) {
    $position = $line.Start.X, $line.Start.Y
    while ($true) {
        $visited["$position"]++

        if ($visited["$position"] -eq 2) {
            $count++
        }

        if ("$position" -eq $line.End.Position) {
            break
        }

        $position[0] += $line.Direction[0]
        $position[1] += $line.Direction[1]
    }
}
$count
