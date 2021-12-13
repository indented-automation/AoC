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

        $dimensions.($matches[1]) -= $matches[2]
    }
}

$grid = [string[][]]::new($dimensions.y + 1, $dimensions.x + 1)
for ($y = 0; $y -le $dimensions.y; $y++) {
    for ($x = 0; $x -le $dimensions.x; $x++) {
        $grid[$y][$x] = ' '
    }
}

foreach ($instruction in $foldInstructions) {
    foreach ($point in [object[]]$coordinates.Values) {
        if ($point.($instruction.Axis) -le $instruction.Position) {
            continue
        }

        $coordinates.Remove(('{0},{1}' -f $point.x, $point.y))
        $point.($instruction.Axis) = $instruction.Position - ($point.($instruction.Axis) - $instruction.Position)
        $coordinates['{0},{1}' -f $point.x, $point.y] = $point
    }
}

foreach ($point in $coordinates.Values) {
    $grid[$point.y][$point.x] = '#'
}

for ($y = 0; $y -lt $dimensions.y; $y++) {
    [string]::new($grid[$y])
}
