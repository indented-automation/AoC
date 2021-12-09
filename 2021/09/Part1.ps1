$heightMap = (Get-Content "$PSScriptRoot\input.txt") -ne ''

$riskLevel = 0
$count = 0
for ($y = 0; $y -lt $heightMap.Count; $y++) {
    for ($x = 0; $x -lt $heightMap[$y].Length; $x++) {
        $current = $heightMap[$y][$x]

        $up = $y -gt 0 ? $heightMap[$y - 1][$x] : $null
        $down = $y -lt $heightMap.Count - 1 ? $heightMap[$y + 1][$x] : $null
        $left = $x -gt 0 ? $heightMap[$y][$x - 1] : $null
        $right = $x -lt $heightMap[$y].Length - 1 ? $heightMap[$y][$x + 1] : $null

        if (-not (@($up, $down, $left, $right -ne $null) -le $current)) {
            $count++
            $riskLevel += [int]::Parse($current) + 1
        }
    }
}
$count
$riskLevel
