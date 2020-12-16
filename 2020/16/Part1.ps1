function ConvertTo-Ticket {
    [CmdletBinding()]
    param (
        [int[]]$Values,

        [object[]]$Rules
    )

    $mappedFields = foreach ($value in $values) {
        [PSCustomObject]@{
            Value         = $value
            PossibleRules = foreach ($rule in $Rules) {
                if ($value -in $rule.ValidValues) {
                    $rule.Name
                }
            }
        }
    }

    $ticket = [Ordered]@{
        InvalidValues = ($mappedFields | Where-Object { $_.PossibleRules.Count -eq 0 }).Value
    }
    foreach ($mappedField in $mappedFields) {
        if ($mappedField.PossibleRules -and $mappedField.PossibleRules.Count -eq 1) {
            $ticket[$mappedField.PossibleRules] = $mappedField.Value
        }
    }

    [PSCustomObject]$ticket | Select-Object -Property @(
        'InvalidValues'
        $rules.Name
    )
}

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
            ValidValues = $validValues
        }
    }

    $i++
} until ($line -eq '')

do {
    $myTicket = $content[$i]
    $i++
} until ($content[$i] -eq '')

$tickets = do {
    if ($content[$i] -and $content[$i] -ne 'nearby tickets:') {
        $values = $content[$i] -split ',' -as [int[]]
        ConvertTo-Ticket -Values $values -Rules $rules
    }
    $i++
} until ($i -ge $content.Count)

$tickets.InvalidValues | Measure-Object -Sum
