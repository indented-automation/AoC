$aunties = foreach ($entry in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $sue, $things = $entry -split ':\s', 2 -replace 'Sue\s'

    $record = @{
        Sue = $sue
    }
    foreach ($thing in $things -split ',\s') {
        $name, [int]$count = $thing -split ':\s'
        $record[$name] = $count
    }
    $record
}

$analysis = @(
    @{ Name = 'children';    Operator = 'Equals';      Value = 3 }
    @{ Name = 'samoyeds';    Operator = 'Equals';      Value = 2 }
    @{ Name = 'akitas';      Operator = 'Equals';      Value = 0 }
    @{ Name = 'vizslas';     Operator = 'Equals';      Value = 0 }
    @{ Name = 'cars';        Operator = 'Equals';      Value = 2 }
    @{ Name = 'perfumes';    Operator = 'Equals';      Value = 1 }
    @{ Name = 'cats';        Operator = 'GreaterThan'; Value = 7 }
    @{ Name = 'trees';       Operator = 'GreaterThan'; Value = 3 }
    @{ Name = 'pomeranians'; Operator = 'LessThan';    Value = 3 }
    @{ Name = 'goldfish';    Operator = 'LessThan';    Value = 5 }
)

foreach ($thing in $analysis) {
    $name = $thing['Name']

    $aunties = foreach ($aunty in $aunties) {
        if (-not $aunty.Contains($name)) {
            $aunty
            continue
        }
        $shouldInclude = ($thing['Operator'] -eq 'Equals' -and $aunty[$name] -eq $thing['Value']) -or
            ($thing['Operator'] -eq 'GreaterThan' -and $aunty[$name] -gt $thing['Value']) -or
            ($thing['Operator'] -eq 'LessThan' -and $aunty[$name] -lt $thing['Value'])

        if ($shouldInclude) {
            $aunty
        }
    }
}
$aunties
