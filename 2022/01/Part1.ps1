$max = 0
foreach ($elf in (Get-Content input.txt -Raw) -split '(\r?\n){2}') {
    $total = 0
    foreach ($value in $elf -split '\r?\n' -match '\d') {
        $total += [int]$value
    }
    if ($total -gt $max) {
        $max = $total
    }
}
$max
