$sum = 0
Select-String -Path $PSScriptRoot\input.txt -Pattern '(mul)\((\d+),(\d+)\)|(do(?:n''t)?)\(\)' -AllMatches |
    & { process { $_.Matches } } |
    & {
        begin {
            $do = $true
            $sum = 0
        }
        process {
            if ($_.Groups[4].Value -eq 'do') {
                $do = $true
            }
            if ($_.Groups[4].Value -eq 'don''t') {
                $do = $false
            }
            if ($do -and $_.Groups[1].Value -eq 'mul') {
                $sum += [int]$_.Groups[2].Value * $_.Groups[3].Value
            }
        }
        end {
            $sum
        }
    }
