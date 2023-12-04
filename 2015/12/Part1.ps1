[Regex]::Matches((Get-Content "$PSScriptRoot\input.txt" -Raw), '-?\d+').Value | Measure-Object -Sum
