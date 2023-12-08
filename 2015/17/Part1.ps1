$target = 150

[int[]]$containers = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$max = 0

for ($i = 1; $i -le $containers.Count; $i++) {
    $max = $max -bor (1 -shl ($i - 1))
}

$count = 0
for ($i = 0; $i -le $max; $i++) {
    $fill = 0
    for ($j = 0; $j -lt $containers.Count; $j++) {
        if ($i -band (1 -shl $j)) {
            $fill += $containers[$j]
        }
    }
    if ($fill -eq $target) {
        $count++
    }
}
$count
