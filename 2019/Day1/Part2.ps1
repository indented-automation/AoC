gc $PSScriptRoot\input.txt | % { $f = 0 } {
    $m = $_
    do {
        $ef = [Math]::Floor([decimal]$m / 3) - 2
        $m = $ef
        if ($ef -gt 0) {
            $f += $ef
        }
    } while ($ef -gt 0)
} { $f }
