using module .\IntCode.psm1

$intCode = [IntCode]::Init((Get-Content $PSScriptRoot\input.txt | Select-Object -First 1))
$intCode.Memory[0] = 2
$intCode.OutputMode = 'StopOnCount'
$intCode.ExpectOutputCount = 3

$ballPosition = $paddlePosition = 0
while ($true) {
    $intCode.ClearOutput()
    $intCode.Start()

    $x, $y, $id = $intCode.Output[0, 1, 2]

    if ($id -eq 3) {
        $paddlePosition = $x
    } elseif ($id -eq 4) {
        $ballPosition = $x
    }

    if ($paddlePosition -lt $ballPosition) {
        $intCode.InputQueue = 1
    } elseif ($paddlePosition -gt $ballPosition) {
        $intCode.InputQueue = -1
    } else {
        $intCode.InputQueue = 0
    }

    if ($x -eq -1 -and $y -eq 0) {
        $score = $id
    }

    if ($intCode.IsComplete -or -not $intCode.Output) {
        break
    }
}
$score
