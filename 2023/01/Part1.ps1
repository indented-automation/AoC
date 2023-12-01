using namespace System.IO

$sum = 0
foreach ($line in [File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $digits = $line -replace '\D'
    $sum += -join $digits[0,-1]
}
$sum
