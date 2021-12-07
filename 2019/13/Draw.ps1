using module .\IntCode.psm1

$intCode = [IntCode]::Init((Get-Content $PSScriptRoot\input.txt | Select-Object -First 1))
$intCode.Start()

$highX = $highY = 0
$tiles = for ($i = 0; $i -lt $intCode.Output.Count; $i += 3) {
    $x, $y, $type = $intCode.Output[$i, ($i + 1), ($i + 2)]
    $highX = [Math]::Max($x, $highX)
    $highY = [Math]::Max($y, $highY)

    [PSCustomObject]@{ x = $x; y = $y; type = $type }
}

$grid = [char[][]]::new($highY + 1, $highX + 1)
foreach ($tile in $tiles) {
    $fill = switch ($tile.type) {
        0 { ' ' }
        1 { '#' }
        2 { '&' }
        3 { '_' }
        4 { '*' }
    }

    $grid[$tile.y][$tile.x] = [char]$fill
}

for ($y = 0; $y -le $highY; $y++) {
    [string]::new($grid[$y]) | Write-Host
}
