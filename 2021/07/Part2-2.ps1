$positions = (Get-Content input.txt) -split ',' -as [int[]]

# From https://github.com/ChrisKibble/Advent-of-Code/blob/main/2021/advent-day7-part2.ps1 (Chris Kibble)
$average = ($positions | Measure-Object -Average).Average
$lowest = [Math]::Floor($average)
$highest = [Math]::Floor($average)

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
