$sum = 0
Select-String -Path $PSScriptRoot\input.txt -Pattern 'mul\((\d+),(\d+)\)' -AllMatches |
    & { process { $_.Matches } } |
    & { begin { $sum = 0 } process { $sum += [int]$_.Groups[1].Value * $_.Groups[2].Value } end { $sum } }
