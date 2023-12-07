$analysis = @'
children: 3
cats: 7
samoyeds: 2
pomeranians: 3
akitas: 0
vizslas: 0
goldfish: 5
trees: 3
cars: 2
perfumes: 1
'@ | ConvertFrom-StringData -Delimiter ':'

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

foreach ($thing in $analysis.Keys) {
    $value = $analysis[$thing]

    $aunties = foreach ($aunty in $aunties) {
        if (-not $aunty.Contains($thing)) {
            $aunty
            continue
        }
        if ($aunty[$thing] -eq $value) {
            $aunty
        }
    }
}
$aunties['Sue']
