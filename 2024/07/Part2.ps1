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
    '||'
)

# This lets me pre-calculate the combinations needed because while I have 850 equations, there are only
# only 10 sets of operator combinations.
$min = [int]::MaxValue
$max = 0
foreach ($equation in $equations -replace '.+:\s*') {
    $size = ($equation -replace '\S').Length

    $min = [Math]::Min($min, $size)
    $max = [Math]::Max($max, $size)
}

$stopWatch = [System.Diagnostics.StopWatch]::StartNew()
$solverTable = @{}
for ($i = $min; $i -le $max; $i++) {
    Write-Host ('<{0}> [{1,2}/{2,2}] Calculating permutations' -f $stopWatch.Elapsed, $i, $max)
    $solverTable[$i] = Get-Permutation -Values $operators -Length $i
}

$sum = 0l
$x = 0
foreach ($equation in $equations) {
    $x++
    Write-Host ('<{0}> [{1,3}/{2,3}] Solving {3,-50}' -f $stopWatch.Elapsed, $x, $equations.Count, $equation) -NoNewline

    [long]$expected, [long[]]$values = $equation -split ':?\s'

    $operatorSets = $solverTable[$values.Count - 1]
    $solved = $false
    :operators
    foreach ($operators in $operatorSets) {
        $i = 0
        [long]$result = $values[$i++]
        switch ($operators) {
            { $result -gt $expected } { continue operators }
            '+'  { $result += $values[$i++] }
            '*'  { $result *= $values[$i++] }
            '||' { $result = '{0}{1}' -f $result, $values[$i++] }
        }

        if ($result -eq $expected) {
            $solved = $true
            $sum += $expected
            break
        }
    }

    if ($solved) {
        Write-Host ' OK!' -ForegroundColor Green
    } else {
        Write-Host
    }
}
Write-Host ('Completed in {0}' -f $stopWatch.Elapsed)
$sum