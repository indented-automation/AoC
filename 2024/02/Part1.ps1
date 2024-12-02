$reports = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$count = 0
foreach ($report in $reports) {
    $levels = -split $report -as [int[]]

    $safe = $true
    $lastDirection = $null
    for ($i = 1; $i -lt $levels.Count -and $safe; $i++) {
        $a, $b = $levels[($i - 1), $i]

        $change = $b - $a
        if ($change -eq 0 -or $change -lt -3 -or $change -gt 3) {
            $safe = $false
            break
        }

        $direction = $change -gt 0 ? 'increment' : 'decrement'

        if ($lastDirection -and $direction -ne $lastDirection) {
            $safe = $false
            break
        }

        $lastDirection = $direction
    }

    if ($safe) {
        $count++
    }
}
$count