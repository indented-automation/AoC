$lists = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$i = 0
$left, $right = @(-split $lists -as [int[]]).Where( { $i++ % 2 -eq 0 }, 'Split')
$left = $left | Sort-Object
$right = $right | Sort-Object

$sum = 0
for ($i = 0; $i -lt $left.Count; $i++) {
    $sum += [Math]::Abs($left[$i] - $right[$i])
}
$sum