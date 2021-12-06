using module .\IntCode.psm1

$intCode = [IntCode]::Init((Get-Content $PSScriptRoot\input.txt | Select-Object -First 1))
$intCode.OutputMode = 'StopOnCount'
$intCode.ExpectOutputCount = 2

$directions = @(
    @(0, -1), # Up
    @(1, 0), # Right
    @(0, 1),  # Down
    @(-1, 0) # Left
)
$directionIndex = 0
$position = 0, 0
$visited = @{}

$colour = 1

while ($true) {
    if ($visited.Contains("$position")) {
        $colour = $visited["$position"].Colour
    }
    $intCode.AddInputValue($colour)

    $intCode.ClearOutput()
    $intCode.Start()
    $colourToPaint, $directionToTurn = $intCode.Output

    if ($null -eq $colourToPaint -or $null -eq $directionToTurn) {
        break
    }

    # Paint

    if ($visited.Contains($position)) {
        $visited["$position"].Visited++
        $visited["$position"].Colour = $colourToPaint
    } else {
        $visited["$position"] = [PSCustomObject]@{
            Visited = 1
            Colour  = $colourToPaint
        }
    }

    # Then move

    $directionToTurn = switch ($directionToTurn) {
        0 { $directionIndex--; 'Left' }
        1 { $directionIndex++; 'Right' }
    }

    if ($directionIndex -lt 0) {
        $directionIndex = 3
    } elseif ($directionIndex -ge $directions.Count) {
        $directionIndex = 0
    }
    $direction = $directions[$directionIndex]

    $position = @(
        $position[0] + $direction[0]
        $position[1] + $direction[1]
    )

    # Default colour
    $colour = 0
}

$maxX = $maxY = 0
foreach ($position in $visited.Keys) {
    $x, $y = $position -split '\s' -as [int[]]
    $maxX = [Math]::Max($x, $maxX)
    $maxY = [Math]::Max($y, $maxY)
}

$bitMap = [System.Drawing.BitMap]::new($maxX + 1, $maxY + 1)
foreach ($position in $visited.Keys) {
    $x, $y = $position -split '\s' -as [int[]]
    if ($visited[$position].Colour -eq 0) {
        $bitMap.SetPixel($x, $y, 'Black')
    }
}
$bitMap.Save("$PSScriptRoot\image.bmp")
