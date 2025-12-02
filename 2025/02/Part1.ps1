$data = Get-Content input.txt -Raw

$sum = 0l
foreach ($range in $data -replace '\r?\n' -split ',') {
    $first, $last = $range -split '-' -as [int64[]]

    for ($value = $first; $value -le $last; $value++) {
        if ($value -match '^(\d+)\1$') {
            $sum += $value
        }
    }
}
$sum
