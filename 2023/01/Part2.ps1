using namespace System.IO

$numbers = [Ordered]@{
    one   = 1
    two   = 2
    three = 3
    four  = 4
    five  = 5
    six   = 6
    seven = 7
    eight = 8
    nine  = 9
}
$start = '^\D*?({0})' -f ($numbers.Keys -join '|')
$end = '({0})\D*?$' -f ($numbers.Keys -join '|')

$sum = 0
foreach ($line in [File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $line = $line -replace $start, { $numbers[$_.Groups[1].Value] }
    $line = [Regex]::Replace($line, $end, { $numbers[$args[0].Groups[1].Value] }, 'RightToLeft')
    $digits = $line -replace '\D'

    $sum += -join $digits[0,-1]
}
$sum
