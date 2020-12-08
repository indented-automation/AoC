$o = gc $pwd\input.txt | ?{ $_ -match '(?<o>\S+)\s(?<d>[+-])(?<v>\d+)' } | %{
    [PSCustomObject]@{
        Operation = $matches['o']
        Direction = $matches['d'] -eq '-' ? -1 : 1
        Value     = [int]$matches['v']
    }
}
$nopIndexes = for ($i = 0; $i -lt $o.Count; $i++) { if ($o[$i].Operation -eq 'nop') { $i } }
$jmpIndexes = for ($i = 0; $i -lt $o.Count; $i++) { if ($o[$i].Operation -eq 'jmp') { $i } }

function run {
    param ( $o )

    $hasRun = [System.Collections.Generic.HashSet[int]]::new()
    $accumulator = $i = 0
    while ($hasRun.Add($i) -and $i -le $o.Count) {
        $op = $o[$i]

        switch ($op.Operation) {
            'nop' { $i++ }
            'jmp' { $i += $op.Direction * $op.Value }
            'acc' { $accumulator += $op.Direction * $op.Value; $i++ }
        }
    }
    if ($hasRun.Contains($o.Count)) {
        $accumulator
    }
}

$r = foreach ($n in $nopIndexes) {
    $o[$n].Operation = 'jmp'

    run $o

    $o[$n].Operation = 'nop'
}
if (-not $r) {
    $r = foreach ($j in $jmpIndexes) {
        $o[$j].Operation = 'nop'

        run $o

        $o[$j].Operation = 'jmp'
    }
}
$r
