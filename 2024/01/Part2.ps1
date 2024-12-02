$lists = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$i = 0
$left, $right = @(-split $lists -as [int[]]).Where( { $i++ % 2 -eq 0 }, 'Split')

$values = @{}
foreach ($value in $left) {
    $values[$value] = 0
}
foreach ($value in $right) {
    if ($values.Contains($value)) {
        $values[$value]++
    }
}

$sum = 0
foreach ($value in $left) {
    $sum += $value * $values[$value]
}
$sum