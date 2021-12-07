$positions = (Get-Content input.txt -Raw) -split ',' -as [int[]]

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

# Smallest number amount of fuel to align
$cost = $last = [int]::MaxValue
for ($target = $lowest; $target -le $highest; $target++) {
    $runCost = 0
    foreach ($position in $positions) {
        $runCost += [Math]::Abs($target - $position)
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
