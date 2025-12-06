using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

class Problem {
    [int] $ID

    [string] $Operator

    [int] $ColumnWidth

    [string[]] $RawValues

    [long[]] $Values

    [long] $Result
}

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$data = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName))

# Data is fixed width. The operators field can be used to get the column width.

$operators = $data[-1]
$length = $data.Count - 1
$problems = @(
    $problem = $null
    for (($i = 0), ($j = 1); $i -lt $operators.Length; $i++) {
        if (($operator = $operators[$i]) -ne ' ') {
            if ($problem) {
                $problem.ColumnWidth--
                $problem 
            }

            $problem = [Problem]@{
                ID          = $j++
                Operator    = $operator
                RawValues   = [string[]]::new($length)
                Values      = [long[]]::new($length)
                ColumnWidth = 1
            }
            continue
        }
        if ($problem) {
            $problem.ColumnWidth++
        }
    }
    $problem
)

# Collect the values
for (($i = 0); $i -lt $data.Count - 1; $i++) {
    $j = 0
    $line = $data[$i]

    foreach ($problem in $problems) {
        $rawValue = $line.Substring($j, $problem.ColumnWidth)
        $j += $problem.ColumnWidth + 1
        $problem.RawValues[$i] = $rawValue
    }
}

# And finally, rotate the values
$sum = 0
foreach ($problem in $problems) {
    for ($i = 0; $i -lt $problem.ColumnWidth; $i++) {
        $values = foreach ($value in $Problem.RawValues) {
            $value[$i]
        }

        $problem.Values[$i] = -join $values

        if ($i -eq 0) {
            $problem.Result = $problem.Values[$i]
            continue
        }

        if ($problem.Operator -eq '+') {
            $problem.Result += $problem.Values[$i]
        }
        if ($problem.Operator -eq '*') {
            $problem.Result *= $problem.Values[$i]
        }
    }

    $sum += $problem.Result
}
$sum