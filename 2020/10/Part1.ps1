$last = 0
$adapters = @(
    0
    Get-Content $pwd\input.txt | ForEach-Object { [int]$_ } | Sort-Object
)
$adapters += $adapters[-1] + 3

$all = for ($i = 0; $i -lt $adapters.Count; $i++) {
    [PSCustomObject]@{ Value = $adapters[$i]; Diff = $adapters[$i] - $last }
    $last = $adapters[$i]
}
$values = $all | Group-Object Diff -AsHashTable -AsString
$values['1'].Count * $values['3'].Count
