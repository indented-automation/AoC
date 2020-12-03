$n = (gc $PSScriptRoot\input.txt) -as [int[]]
:all foreach ($n1 in $n) {
    foreach ($n2 in $n) {
        foreach ($n3 in $n) {
            if ($n1 + $n2 + $n3 -eq 2020) {
                $n1 * $n2 * $n3
                break all
            }
        }
    }
}
