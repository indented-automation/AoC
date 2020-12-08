(Get-Content $pwd\input.txt -Raw) -split '(\r?\n){2}' | ?{ $_.Trim() } | ?{
    $h = [PSCustomObject]($_ -split ' ' -replace ':', '=' | Out-String | ConvertFrom-StringData)

    if (@($h.PSObject.Properties).Count -eq 8 -or (@($h.PSObject.Properties).Count -eq 7 -and -not $h.cid)) {
        $r = [PSCustomObject]@{
            byr = $h.byr -match '^\d{4}$' -and [int]$h.byr -ge 1920 -and [int]$h.byr -le 2002
            iyr = $h.iyr -match '^\d{4}$' -and [int]$h.iyr -ge 2010 -and [int]$h.iyr -le 2020
            eyr = $h.eyr -match '^\d{4}$' -and [int]$h.eyr -ge 2020 -and [int]$h.eyr -le 2030
            hgt = ($h.hgt -match '^(\d+)cm$' -and [int]$matches[1] -ge 150 -and [int]$matches[1] -le 193) -or
                ($h.hgt -match '^(\d+)in$' -and [int]$matches[1] -ge 59 -and [int]$matches[1] -le 76)
            hcl = $h.hcl -match '^#[0-9a-f]{6}$'
            ecl = $h.ecl -in 'amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth'
            pid = $h.pid -match '^\d{9}$'
            cid = $true
        }
        -not ($r.PSObject.Properties.Value -contains $false)
    }
} | measure
