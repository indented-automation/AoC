$position = 50

$password = 0
foreach ($movement in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $null = $movement -match '^([LR])(\d+)'
    $value = [int]$matches[2] % 100

    if ($matches[1] -eq 'L') {
        $position -= $value
    } else {
        $position += $value
    }

    if ($position -gt 99) {
        $position -= 100
    } elseif ($position -lt 0) {
        $position += 100
    }

    if ($position -eq 0) {
        $password++
    }
}
$password