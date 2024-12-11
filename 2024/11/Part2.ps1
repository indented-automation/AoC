$stones = @{}

$initial = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt").Trim() -split '\s+'
foreach ($stone in $initial) {
    $stones[$stone]++
}

for ($i = 1; $i -le 75; $i++) {
    $current = $stones
    $stones = @{}

    foreach ($stone in $current.Keys) {
        if ($stone -eq '0') {
            $stones['1'] += $current[$stone]
        } elseif ($stone.Length % 2 -eq 0) {
            $size = $stone.Length / 2

            $stones[+$stone.Substring(0, $size) -as [string]] += $current[$stone]
            $stones[+$stone.Substring($size) -as [string]] += $current[$stone]
        } else {
            $stones[+$stone * 2024 -as [string]] += $current[$stone]
        }
    }
}

$sum = 0
foreach ($count in $stones.Values) {
    $sum += $count
}
$sum