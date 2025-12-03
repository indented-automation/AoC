using namespace System.Collections

$sum = 0l
foreach ($bank in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $batteries = [int[]][string[]][char[]]$bank
    $joltage = 0
    for ($a = 0; $a -lt $batteries.Count - 1; $a++) {
        for ($b = $a + 1; $b -lt $batteries.Count; $b++) {
            $j = $batteries[$a] * 10 + $batteries[$b]
            if ($j -gt $joltage) {
                $joltage = $j
            }
        }
    }

    $sum += $joltage
}
$sum