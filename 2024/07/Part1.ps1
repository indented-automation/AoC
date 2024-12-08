$operators = @(
    '+'
    '*'
)

$sum = 0
$x = 0
$equations = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
foreach ($equation in $equations) {
    $x++
    [long]$expected, [long[]]$values = $equation -split ':?\s'

    :equation
    for ($i = 0; $i -lt $values.Count; $i++) {
        if ($i -eq 0) {
            $results = $values[$i]
            continue
        }

        $next = [List[long]]::new()
        foreach ($result in $results) {
            foreach ($operator in $operators) {
                $new = switch ($operator) {
                    '+'  { $result + $values[$i] }
                    '*'  { $result * $values[$i] }
                    '||' { '{0}{1}' -f $result, $values[$i] -as [long] }
                }

                if ($new -gt $expected) {
                    continue
                }

                if ($i -eq $values.Count - 1 -and $new -eq $expected) {
                    $sum += $expected
                    break equation
                }

                $next.Add($new)
            }
        }

        $results = $next
    }
}
$sum