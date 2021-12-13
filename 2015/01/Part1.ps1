$instruction = Get-Content "$PSScriptRoot\input.txt"

$floor = 0
switch ([char[]]$instruction) {
    '(' { $floor++ }
    ')' { $floor-- }
}
$floor
