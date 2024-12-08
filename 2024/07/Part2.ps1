$operators = @(
    '+'
    '*'
    '||'
)

$sum = 0
$x = 0
$stopWatch = [System.Diagnostics.StopWatch]::StartNew()
$equations = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
foreach ($equation in $equations) {
    $x++
    Write-Host ('<{0}> [{1,3}/{2,3}] Solving {3,-50}' -f $stopWatch.Elapsed, $x, $equations.Count, $equation) -NoNewline

    [long]$expected, [long[]]$values = $equation -split ':?\s'
    $solved = $false

    :equation
    for ($i = 0; $i -lt $values.Count; $i++) {
        if ($i -eq 0) {
            $results = $values[$i]
            continue
        }

        $next = [List[long]]::new()
        # Update all existing results using each operator
        foreach ($result in $results) {
            # Each operator we visit will spawn a new result to track.
            foreach ($operator in $operators) {
                $new = switch ($operator) {
                    '+'  { $result + $values[$i] }
                    '*'  { $result * $values[$i] }
                    '||' { '{0}{1}' -f $result, $values[$i] -as [long] }
                }

                if ($new -gt $expected) {
                    # Discard this result. Not solvable in this tree.
                    continue
                }

                if ($i -eq $values.Count - 1 -and $new -eq $expected) {
                    # We're done with this equation.
                    $sum += $expected
                    $solved = $true
                    break equation
                }

                $next.Add($new)
            }
        }

        $results = $next
    }

    if ($solved) {
        Write-Host ' OK!' -ForegroundColor Green
    } else {
        Write-Host ' Failed!' -ForegroundColor Red
    }
}
$sum