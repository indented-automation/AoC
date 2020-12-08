gc $PSScriptRoot\input.txt | % { $f = 0 } {
    $f += [Math]::Floor([decimal]$_ / 3) - 2
} { $f }
