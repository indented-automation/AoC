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
        $params = @{
            Values      = $Values
            Permutation = @(
                $Permutation
                $value
            )
            Length      = $Length
        }
        Get-Permutation @params
    }
}

$equations = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$operators = @(
    '*'
    '+'
)

# This lets me pre-calculate the combinations needed because while I have 850 equations, there are only
# only 10 sets of operator combinations in my input.
$min = [int]::MaxValue
$max = 0
foreach ($equation in $equations -replace '.+:\s*') {
    $size = ($equation -replace '\S').Length

    $min = [Math]::Min($min, $size)
    $max = [Math]::Max($max, $size)
}

$solverTable = @{}
for ($i = $min; $i -le $max; $i++) {
    $solverTable[$i] = Get-Permutation -Values $operators -Length $i
}

$sum = 0l
foreach ($equation in $equations) {
    [long]$expected, [long[]]$values = $equation -split ':?\s'

    $operatorSets = $solverTable[$values.Count - 1]
    :operators
    foreach ($operators in $operatorSets) {
        $i = 0
        $result = $values[$i++]
        switch ($operators) {
            { $result -gt $expected } { continue operators }
            '+' { $result += $values[$i++] }
            '*' { $result *= $values[$i++] }
        }

        if ($result -eq $expected) {
            # Write-Host ('{0}: Solved {1}' -f ($operators -join ' '), $equation) -ForegroundColor Green
            $sum += $expected
            break
        }
    }
}
$sum