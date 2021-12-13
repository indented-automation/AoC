$instructions = Get-Content "$PSScriptRoot\input.txt" | Where-Object { $_ -match '(?:turn\s)?(\S+)\s(\d+),(\d+)\sthrough\s(\d+),(\d+)'  } | ForEach-Object {
    [PSCustomObject]@{
        Action = $matches[1]
        From   = @( [int]$matches[2], [int]$matches[3] )
        To     = @( [int]$matches[4], [int]$matches[5] )
    }
}

$lights = [int64[][]]::new(1000, 1000)

foreach ($instruction in $instructions) {
    for ($x = $instruction.From[0]; $x -le $instruction.To[0]; $x++) {
        for ($y = $instruction.From[1]; $y -le $instruction.To[1]; $y++) {
            switch ($instruction.Action) {
                'On' {
                    $lights[$x][$y]++
                    break
                }
                'Off'    {
                    if ($lights[$x][$y] -gt 0) {
                        $lights[$x][$y]--
                    }
                    break
                }
                'Toggle' {
                    $lights[$x][$y] += 2
                    break
                }
            }
        }
    }
}

[int64]$total = 0
for ($x = 0; $x -lt 1000; $x++) {
    for ($y = 0; $y -lt 1000; $y++) {
        $total += $lights[$x][$y]
    }
}
$total
