$sum = 0l
foreach ($bank in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $batteries = [int[]][string[]][char[]]$bank

    $joltage = 0l
    for (($b = 1), ($min = 0); $b -le 12; $b++) {
        $max = $bank.Length - 12 + $b

        $jolts = 0
        for ($j = $min; $j -lt $max; $j++) {
            if ($batteries[$j] -gt $jolts) {
                $jolts = $batteries[$j]
                $min = $j + 1
            }
        }

        $joltage += $jolts * [Math]::Pow(10, 12 - $b)
    }
    $sum += $joltage
}
$sum