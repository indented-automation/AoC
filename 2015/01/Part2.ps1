$instruction = Get-Content "$PSScriptRoot\input.txt"

$floor = 0
$index = 0
switch ([char[]]$instruction) {
    { $true } {
        if ($floor -lt 0) {
            break
        }
        $index++
    }
    '(' { $floor++ }
    ')' { $floor-- }
}
$index
