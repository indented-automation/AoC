using namespace System.Collections.Generic

$antinode = [HashSet[string]]::new()

$grid = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$maxX = $grid[0].Length - 1
$maxY = $grid.Count - 1

$antenna = @{}
for ($y = 0; $y -lt $grid.Count; $y++) {
    for ($x = 0; $x -lt $grid[$y].Length; $x++) {
        if ($grid[$y][$x] -notmatch '[.#]') {
            $antenna[$grid[$y][$x]] += ,@($x, $y)
        }
    }
}

foreach ($frequency in $antenna.Keys) {
    $all = $antenna[$frequency]

    $pairs = for ($i = 0; $i -lt $all.Count; $i++) {
        for ($j = $i + 1; $j -lt $all.Count; $j++) {
            ,$all[$i,$j]
        }
    }

    foreach ($pair in $pairs) {
        $a, $b = $pair

        $dx = $a[0] - $b[0]
        $dy = $a[1] - $b[1]

        if ($a.x - $dx -eq $b.x) {
            $dx = -$dx
        }
        if ($a.y - $dy -eq $b.y) {
            $dy = -$dy
        }

        $null = $antinode.Add("$a")
        $null = $antinode.Add("$b")

        $ax = $a[0] - $dx
        $ay = $a[1] - $dy

        while ($ax -ge 0 -and $ax -le $maxX -and $ay -ge 0 -and $ay -le $maxY) {
            $null = $antinode.Add("$ax $ay")
            $ax -= $dx
            $ay -= $dy
        }

        $bx = $b[0] + $dx
        $by = $b[1] + $dy

        while ($bx -ge 0 -and $bx -le $maxX -and $by -ge 0 -and $by -le $maxY) {
            $null = $antinode.Add("$bx $by")
            $bx += $dx
            $by += $dy
        }
    }
}
$antinode.Count
