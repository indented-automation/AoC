$o = gc $pwd\input.txt | ?{ $_ -match '(?<o>\S+)\s(?<d>[+-])(?<v>\d+)' } | %{
    [PSCustomObject]@{
        Operation = $matches['o']
        Direction = $matches['d'] -eq '-' ? -1 : 1
        Value     = [int]$matches['v']
    }
}
$hasRun = [System.Collections.Generic.HashSet[int]]::new()
$accumulator = $i = 0
while ($hasRun.Add($i)) {
    $op = $o[$i]
    switch ($op.Operation) {
        'nop' { $i++ }
        'jmp' { $i += $op.Direction * $op.Value }
        'acc' { $accumulator += $op.Direction * $op.Value; $i++ }
    }
}
$accumulator
