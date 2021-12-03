$bits = gc "$PSScriptRoot\input.txt"

$values = @(
    [PSCustomObject]@{ Name = 'Oxygen'; Bits = $bits; GroupName = 1; Integer = 0 }
    [PSCustomObject]@{ Name = 'Scubber'; Bits = $bits; GroupName = 0; Integer = 0 }
)
foreach ($value in $values) {
    for ($i = 0; $i -lt $bits[0].Length; $i++) {
        $group = $value.Bits | ForEach-Object { $_[$i] } | Group-Object | Sort-Object Count
        $filter = $group[$value.GroupName].Name
        if ($group[0].Count -eq $group[1].Count) {
            $filter = [string]$value.GroupName
        }
        $value.Bits = $value.Bits | Where-Object { $_[$i] -eq $filter }
        if ($value.Bits.Count -eq 1) {
            break
        }
    }
    $value.Integer = [Convert]::ToInt64($value.Bits, 2)
}
$values[0].Integer * $values[1].Integer
