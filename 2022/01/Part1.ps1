$max = 0
foreach ($elf in (Get-Content input.txt -Raw) -split '\n{2}') {
    $total = 0
    foreach ($value in $elf -split '\n' -match '\d') {
        $total += [int]$value
    }
    if ($total -gt $max) {
        $max = $total
    }
}
$max
