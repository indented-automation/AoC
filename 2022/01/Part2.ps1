$top = [System.Collections.Generic.SortedSet[int]]::new()
foreach ($group in (Get-Content input.txt -Raw) -split '(\r?\n){2}') {
    $total = 0
    foreach ($value in $group -split '\r?\n' -match '\d') {
        $total += [int]$value
    }
    if ($top.Count -lt 3) {
        $null = $top.Add($total)
    } elseif ($total -gt $top.Min) {
        $null = $top.Add($total)
    }
    if ($top.Count -gt 3) {
        $null = $top.Remove($top.Min)
    }
}
[int[]]$top = $top
$top[0] + $top[1] + $top[2]
