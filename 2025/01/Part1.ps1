$values = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$password = 0
$position = 50
foreach ($value in $values) {
    $number = $value -replace 'L', '-' -replace 'R' -as [int]
    $effective = $number % 100
    $position += $effective

    if ($position -lt 0) {
        $position += 100
    }
    if ($position -gt 99) {
        $position -= 100
    }

    if ($position -eq 0) {
        $password++
    }
}
$password