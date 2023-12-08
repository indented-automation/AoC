$target = 150

[int[]]$containers = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$bits = $containers.Count

$max = 0
$bit = 1
$bitToContainer = @{}
$counts = @{}

foreach ($container in $containers) {
    $bitToContainer["$bit"] = $container
    $max = $max -bor $bit
    $bit = $bit -shl 1
}

for ($i = 1; $i -le $containers.Count; $i++) {
    $counts["$i"] = 0
}

$min = $containers.Count
for ($i = 0; $i -le $max; $i++) {
    $containersUsed = 0
    $fill = 0

    # If I could just make this part faster...
    for ($j = 0; $j -lt $bits; $j++) {
        $bit = $i -band (1 -shl $j)
        if ($bit) {
            $containersUsed++
            $fill += $bitToContainer["$bit"]
        }
    }

    if ($fill -eq $target) {
        if ($containersUsed -lt $min) {
            $min = $containersUsed
        }
        $counts["$containersUsed"]++
    }
}
$counts["$min"]
