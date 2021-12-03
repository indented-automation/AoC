$bits = gc "$PSScriptRoot\input.txt"
$g = $e = 0
$l = $bits[0].Length
for ($i = 0; $i -lt $l; $i++) {
    $v = [Math]::Pow(2, $l - $i - 1)
    $group = $bits | ForEach-Object { $_[$i] } | Group-Object | Sort-Object Count
    $g = $g -bor $v * $group[1].Name
    $e = $e -bor $v * $group[0].Name
}
$g * $e
