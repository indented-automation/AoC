:end foreach ($p1 in 0..99) {
    foreach ($p2 in 0..99) {
        $p = (gc $PSScriptRoot\input.txt -raw) -split ',' -as [int[]]
        $p[1] = $p1
        $p[2] = $p2

        $i = 0
        do {
            if ($p[$i] -eq 99) { break }
            if ($p[$i] -notin 1, 2) { throw }

            $lhs = $p[$p[$i + 1]]
            $rhs = $p[$p[$i + 2]]
            $p[$p[$i + 3]] = switch ($p[$i]) {
                1 { $lhs + $rhs }
                2 { $lhs * $rhs }
            }
            $i += 4
        } while ($i -lt $p.Count)

        if ($p[0] -eq 19690720) {
            100 * $p1 + $p2
            break end
        }
    }
}
