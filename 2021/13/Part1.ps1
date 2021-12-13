$dimensions = [PSCustomObject]@{
    x = 0
    y = 0
}

$foldInstructions = [System.Collections.Generic.List[object]]::new()
$coordinates = @{}
Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    if ($_ -match '^\d+') {
        $x, $y = $_ -split ',' -as [int[]]
        $dimensions.x = [Math]::Max($x, $dimensions.x)
        $dimensions.y = [Math]::Max($y, $dimensions.y)

        $coordinates["$x,$y"] = [PSCustomObject]@{
            x = $x
            y = $y
        }
    }

    if ($_ -match 'fold along (.)=(\d+)') {
        $foldInstructions.Add(
            [PSCustomObject]@{
                Axis     = $matches[1]
                Position = $matches[2] -as [int]
            }
        )
    }
}

foreach ($instruction in $foldInstructions[0]) {
    foreach ($point in [object[]]$coordinates.Values) {
        if ($point.($instruction.Axis) -le $instruction.Position) {
            continue
        }

        $coordinates.Remove(('{0},{1}' -f $point.x, $point.y))
        $point.($instruction.Axis) = $instruction.Position - ($point.($instruction.Axis) - $instruction.Position)
        $coordinates['{0},{1}' -f $point.x, $point.y] = $point
    }

    $dimensions.($instruction.Axis) -= $instruction.Position
}

$coordinates.Count
