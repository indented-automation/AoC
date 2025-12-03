# $sum = 0l
# foreach ($bank in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
#     $batteries = [int[]][string[]][char[]]$bank
#     $joltage = 0
#     for ($a = 0; $a -lt $batteries.Count - 1; $a++) {
#         for ($b = $a + 1; $b -lt $batteries.Count; $b++) {
#             $j = $batteries[$a] * 10 + $batteries[$b]
#             if ($j -gt $joltage) {
#                 $joltage = $j
#             }
#         }
#     }

#     $sum += $joltage
# }
# $sum

# Since I wrote a better thing for part 2... reuse it for part 1, it's a lot faster.

$sum = 0l
foreach ($bank in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $batteries = [int[]][string[]][char[]]$bank

    $joltage = 0l
    for (($b = 1), ($min = 0); $b -le 2; $b++) {
        $max = $bank.Length - 2 + $b

        $jolts = 0
        for ($j = $min; $j -lt $max; $j++) {
            if ($batteries[$j] -gt $jolts) {
                $jolts = $batteries[$j]
                $min = $j + 1
            }
        }

        $joltage += $jolts * [Math]::Pow(10, 2 - $b)
    }
    $sum += $joltage
}
$sum