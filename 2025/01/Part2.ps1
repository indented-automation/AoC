$position = 50

$password = 0
foreach ($movement in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $null = $movement -match '^([LR])(\d+)'

    $actual = [int]$matches[2]
    $effective = $actual % 100
    $rotations = ($actual - $effective) / 100

    $next = $position

    if ($matches[1] -eq 'L') {
        $next -= $effective
    } else {
        $next += $effective
    }

    $passedZero = $false
    if ($next -gt 99) {
        $passedZero = $position -ne 100
        $next -= 100
    } elseif ($next -lt 0) {
        $passedZero = $position -ne 0
        $next += 100
    }

    if ($next -eq 0 -or $passedZero) {
        $password++
    }
    if ($rotations) {
        $password += $rotations
    }

    $position = $next
}
$password