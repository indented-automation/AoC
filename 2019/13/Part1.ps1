using module .\IntCode.psm1

$intCode = [IntCode]::Init((Get-Content $PSScriptRoot\input.txt | Select-Object -First 1))
$intCode.Start()

$blockTiles = @{}
for ($i = 0; $i -lt $intCode.Output.Count; $i += 3) {
    $x, $y, $id = $intCode.Output[$i, ($i + 1), ($i + 2)]

    if ($id -eq 2) {
        $blockTiles["$x,$y"]++
    }
}
$blockTiles.Count
