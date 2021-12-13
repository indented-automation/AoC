$instructions = Get-Content "$PSScriptRoot\input.txt" | Where-Object { $_ -match '(?:turn\s)?(\S+)\s(\d+),(\d+)\sthrough\s(\d+),(\d+)'  } | ForEach-Object {
    [PSCustomObject]@{
        Action = $matches[1]
        From   = @( [int]$matches[2], [int]$matches[3] )
        To     = @( [int]$matches[4], [int]$matches[5] )
    }
}

$on = 0
$lights = [byte[][]]::new(1000, 1000)

foreach ($instruction in $instructions) {
    for ($x = $instruction.From[0]; $x -le $instruction.To[0]; $x++) {
        for ($y = $instruction.From[1]; $y -le $instruction.To[1]; $y++) {
            $isOn = $lights[$x][$y]

            switch ($instruction.Action) {
                'On' {
                    $lights[$x][$y] = 1
                    if (-not $isOn) {
                        $on++
                    }
                    break
                }
                'Off'    {
                    $lights[$x][$y] = 0
                    if ($isOn) {
                        $on--
                    }
                }
                'Toggle' {
                    if ($isOn) {
                        $lights[$x][$y] = 0
                        $on--
                    } else {
                        $lights[$x][$y] = 1
                        $on++
                    }
                }
            }
        }
    }
}
$on

