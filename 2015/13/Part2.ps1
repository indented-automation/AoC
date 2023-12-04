using namespace System.Collections.Generic

function Get-Permutation {
    param (
        [string[]]
        $Values,

        [string[]]
        $Permutation = @(),

        [int]
        $Length = $Values.Count
    )

    if ($Permutation.Count -ge $Length) {
        return ,$Permutation
    }

    foreach ($value in $Values) {
        if ($value -in $Permutation) {
            continue
        }

        $params = @{
            Values      = $Values
            Permutation = @(
                $Permutation
                $value
            )
        }
        Get-Permutation @params
    }
}

$seatingHappiness = Get-Content input.txt
$allPeople = [HashSet[string]]@($seatingHappiness -replace '\s.+')

$seatingHappiness += foreach ($person in $allPeople) {
    'Me would gain 0 happiness units by sitting next to {0}.' -f $person
    '{0} would gain 0 happiness units by sitting next to Me.' -f $person
}

$people = @{}
foreach ($item in $seatingHappiness) {
    $values = $item.TrimEnd('.') -split '\s+'
    $name, $operator, [int]$value, $neighbour = $values[0, 2, 3, -1]

    if ($operator -eq 'lose') {
        $value = -$value
    }

    if (-not $people.Contains($name)) {
        $people[$name] = @{
            n = $name
            h = @{}
        }
    }
    $people[$name]['h'][$neighbour] = $value
}

$seatingOrder = Get-Permutation $people.Keys -Permutation @($people.Keys)[0]

$happiest = 0
foreach ($order in $seatingOrder) {
    $sum = 0
    for ($i = -1; $i -lt $order.Count - 1; $i++) {
        $a, $b = $order[$i, ($i + 1)]

        $sum += $people[$a]['h'][$b] + $people[$b]['h'][$a]
    }
    if ($sum -gt $happiest) {
        $happiest = $sum
    }
}
$happiest
