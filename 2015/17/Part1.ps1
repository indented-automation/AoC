$target = 150

[int[]]$containers = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$bits = $containers.Count

$max = 0
$bit = 1
$bitToContainer = @{}
foreach ($container in $containers) {
    $bitToContainer["$bit"] = $container
    $max = $max -bor $bit
    $bit = $bit -shl 1
}

$count = 0
for ($i = 0; $i -le $max; $i++) {
    $fill = 0
    for ($j = 0; $j -lt $bits; $j++) {
        $bit = $i -band (1 -shl $j)
        if ($bit) {
            $fill += $bitToContainer["$bit"]
        }
    }
    if ($fill -eq $target) {
        $count++
    }
}
$count
