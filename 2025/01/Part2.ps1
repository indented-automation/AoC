$values = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$password = 0
$position = 50
foreach ($value in $values) {
    $isZero = $position -eq 0

    $number = $value -replace 'L', '-' -replace 'R' -as [int]
    $effective = $number % 100
    $rotations = [Math]::Abs(($number - $effective) / 100)
    $position += $effective

    $click = 0
    if ($position -lt 0) {
        # We click 0 unless we started at 0
        if (-not $isZero) { $click++ }
        $position += 100
    }
    if ($position -gt 99) {
        $click++
        $position -= 100
    }

    # As long as we have not already counted this click
    if ($position -eq 0 -and -not $click) {
        $click++
    }

    # Always add the number of times the dial spun around
    $click += $rotations

    $password += $click
}
$password