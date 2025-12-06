using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$data = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName)).Trim()

$operators = $data[-1] -split '\s+'
$results = [long[]]::new($operators.Count)

for ($i = 0; $i -lt $data.Count - 1; $i++) {
    $values = $data[$i] -split '\s+'

    if ($i -eq 0) {
        for ($j = 0; $j -lt $values.Count; $j++) {
            $results[$j] = $values[$j]
        }
        continue
    }

    for ($j = 0; $j -lt $values.Count; $j++) {
        if ($operators[$j] -eq '+') {
            $results[$j] += $values[$j]
        }
        if ($operators[$j] -eq '*') {
            $results[$j] *= $values[$j]
        }
    }
}

$sum = 0
foreach ($result in $results) {
    $sum += $result
}
$sum