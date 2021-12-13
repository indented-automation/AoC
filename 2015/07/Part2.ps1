$instructions = @{}
$pendingExecution = [System.Collections.Generic.HashSet[string]]::new()

Get-Content "$PSScriptRoot\input.txt" | Where-Object { $_ -match '(.+) -> ([a-z]+)' } | ForEach-Object {
    $operation = $matches[1]

    $instruction = [PSCustomObject]@{
        Name       = $matches[2]
        Requires   = [System.Collections.Generic.List[string]]::new()
        Left       = $null
        Operator   = ''
        Right      = $null
    }

    switch -Regex ($operation) {
        '^(\w+)' {
            $instruction.Operator = 'SET'
            $instruction.Left = $matches[1]
        }
        'NOT (\w+)' {
            $instruction.Operator = 'NOT'
            $instruction.Left = $matches[1]
        }
        '(\w+) (\S+) (\w+)' {
            $instruction.Operator = $matches[2]
            $instruction.Left = $matches[1]
            $instruction.Right = $matches[3]
        }
    }

    foreach ($side in 'Left', 'Right') {
        if ($instruction.$side -match '\d+') {
            $instruction.$side = [ushort]$instruction.$side
        } elseif ($instruction.$side) {
            $instruction.Requires.Add($instruction.$side)
        }
    }

    $instructions[$instruction.Name] = $instruction
    $null = $pendingExecution.Add($instruction.Name)
}

while ($pendingExecution.Count) {
    :instruction foreach ($instruction in $pendingExecution) {
        $instruction = $instructions[$instruction]

        foreach ($dependency in $instruction.Requires) {
            if ($pendingExecution.Contains($dependency)) {
                continue instruction
            }
        }

        foreach ($side in 'Left', 'Right') {
            if ($instruction.$side -is [string]) {
                $instruction.$side = $wires[$instruction.$side]
            }
        }

        $wires[$instruction.Name] = switch ($instruction.Operator) {
            'SET'    {
                if ($instruction.Name -eq 'b') {
                    3176
                } else {
                    $instruction.Left
                }
            }
            'NOT'    { -bnot $instruction.Left -band [ushort]::MaxValue }
            'AND'    { $instruction.Left -band $instruction.Right }
            'OR'     { $instruction.Left -bor $instruction.Right }
            'LSHIFT' { $instruction.Left -shl $instruction.Right }
            'RSHIFT' { $instruction.Left -shr $instruction.Right }
            default  { throw "Invalid operation $_" }
        }

        $null = $pendingExecution.Remove($instruction.Name)
    }
}

$wires['a']
