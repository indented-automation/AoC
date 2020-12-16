$content = Get-Content input.txt
$i = 0

$rules = do {
    $line = $content[$i]

    $name, $ranges = $line -split ': '
    if ($name -and $ranges) {
        $validValues = [Regex]::Matches($ranges, '(\d+)-(\d+)') | ForEach-Object {
            [int]$_.Groups[1].Value..[int]$_.Groups[2].Value
        }
        [PSCustomObject]@{
            Name        = $name
            AppliesTo   = -1
            CanApplyTo  = [System.Collections.Generic.List[int]]::new()
            ValidValues = $validValues
        }
    }

    $i++
} until ($line -eq '')

do {
    $myTicket = $content[$i] -split ',' -as [int[]]
    $i++
} until ($content[$i] -eq '')

$allTickets = @(
    ,($myTicket -split ',' -as [int[]])
    do {
        if ($content[$i] -and $content[$i] -ne 'nearby tickets:') {
            ,($content[$i] -split ',' -as [int[]])
        }
        $i++
    } until ($i -ge $content.Count)
)

$allTickets = foreach ($ticket in $allTickets) {
    $isValid = $true
    foreach ($value in $ticket) {
        $hasMatchingRule = $false
        foreach ($rule in $rules) {
            if ($rule.ValidValues -contains $value) {
                $hasMatchingRule = $true
                break
            }
        }
        if (-not $hasMatchingRule) {
            $isValid = $false
            break
        }
    }
    if ($isValid) {
        ,$ticket
    }
}


foreach ($rule in $rules) {
    $rule.CanApplyTo.AddRange([int[]](0..($allTickets[0].Count - 1)))
}
$appliedRules = @{}

do {
    # This is going to repeat
    for ($i = 0; $i -lt $allTickets[0].Count; $i++) {
        foreach ($ticket in $allTickets) {
            foreach ($rule in $rules) {
                if ($rule.AppliesTo -eq -1 -and $rule.CanApplyTo.Contains($i) -and $rule.ValidValues -notcontains $ticket[$i]) {
                    $null = $rule.CanApplyTo.Remove($i)
                }
            }
        }
    }
    foreach ($rule in $rules) {
        if ($rule.CanApplyTo.Count -eq 1) {
            $rule.AppliesTo = $rule.CanApplyTo[0]
            $appliedRules.Add($rule.CanApplyTo[0], $rule.Name)
        }
    }
    foreach ($rule in $rules) {
        foreach ($index in $appliedRules.Keys) {
            $null = $rule.CanApplyTo.Remove($index)
        }
    }
} while ($rules.AppliesTo -contains -1)

$i = 1
foreach ($rule in $rules) {
    if ($rule.Name -match 'departure') {
        $i *= $myTicket[$rule.AppliesTo]
    }
}
$i
