using namespace System.Collections.Generic
using namespace System.IO

$history = [File]::ReadAllLines("$PSScriptRoot\input.txt")

$sum = 0
foreach ($sequence in $history) {
    $sequence = $sequence -split '\s+' -as [List[long]]

    $difference = $sequence
    $differences = [List[List[long]]]::new()
    $differences.Add($difference)

    do {
        $differenceIsZero = $true

        $difference = for ($i = 0; $i -lt $difference.Count - 1; $i++) {
            $value = $difference[$i + 1] - $difference[$i]
            if ($value -ne 0) {
                $differenceIsZero = $false
            }
            $value
        }

        if (-not $differenceIsZero) {
            $differences.Add($difference)
        }
    } until ($differenceIsZero)

    for ($i = $differences.Count - 1; $i -ge 0; $i--) {
        $next = $differences[$i - 1][-1] + $differences[$i][-1]
        $differences[$i - 1].Add($next)
    }

    $sum += $differences[0][-1]
}
$sum
