$target = 150

[int[]]$containers = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$max = 0
$counts = [System.Collections.Generic.Dictionary[int,int]]::new()

for ($i = 1; $i -le $containers.Count; $i++) {
    $max = $max -bor (1 -shl ($i - 1))
    $counts[$i] = 0
}

$min = $containers.Count
for ($i = 0; $i -le $max; $i++) {
    $containersUsed = 0
    $fill = 0

    for ($j = 0; $j -lt $containers.Count; $j++) {
        if ($i -band (1 -shl $j)) {
            $containersUsed++
            $fill += $containers[$j]
        }
    }

    if ($fill -eq $target) {
        if ($containersUsed -lt $min) {
            $min = $containersUsed
        }
        $counts[$containersUsed]++
    }
}
$counts[$min]
