$positions = (Get-Content input.txt) -split ',' -as [int[]]

$lowest = [int]::MaxValue
$highest = 0
foreach ($position in $positions) {
    if ($position -lt $lowest) {
        $lowest = $position
    }
    if ($position -gt $highest) {
        $highest = $position
    }
}

$cost = $last = [int]::MaxValue
for ($target = $lowest; $target -le $highest; $target++) {
    $runCost = 0
    foreach ($position in $positions) {
        $value = [Math]::Abs($target - $position)
        $runCost += ($value / 2) * ($value + 1)
    }
    if ($last -lt $runCost) {
        break
    }
    if ($runCost -lt $cost) {
        $cost = $runCost
    }
    $last = $runCost
}
$cost
