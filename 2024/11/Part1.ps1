$stones = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt").Trim() -split '\s+' -as [int[]]

for ($i = 1; $i -le 25; $i++) {
    $stones = foreach ($stone in $stones) {
        $stringStone = $stone.ToString()
        if ($stone -eq 0) {
            1
        } elseif ($stringStone.Length % 2 -eq 0) {
            $size = $stringStone.Length / 2
            +$stringStone.Substring(0, $size)
            +$stringStone.Substring($size)
        } else {
            $stone * 2024
        }
    }
}

$stones.Count
