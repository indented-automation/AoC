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

while ($true) {
    if ($visited.Contains("$position")) {
        $colour = $visited["$position"].Colour
    } else {
        # Default to black
        $colour = 0
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
}
$visited.Count
