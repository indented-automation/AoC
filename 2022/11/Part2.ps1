using namespace System.Collections.Generic

class Monkey {
    [string]       $Number
    [List[bigint]] $Items
    [ScriptBlock]  $Operation
    [int]          $Test
    [string]       $IfTrue
    [string]       $IfFalse
    [int]          $Inspected = 0

    static $Monkeys = [Ordered]@{}

    # Greatest Common Devisor for all numbers is 1.
    static [bigint] $LeastCommonMultiple = 1

    Monkey(
        [string] $description
    ) {
        $values = $description -split '\r?\n'

        $this.Number = $values[0] -replace '^.+\s|:'
        $this.Items = $values[1] -replace '^.+:\s' -split ', '

        $this.Operation = [ScriptBlock]::Create(
            ($values[2] -replace '.+=\s' -replace 'old', '$args[0]')
        )

        $this.Test = $values[3] -replace '.+\sby\s'
        $this.IfTrue = $values[4] -replace '^.+\s'
        $this.IfFalse = $values[5] -replace '^.+\s'

        [Monkey]::Monkeys[$this.Number] = $this
    }

    [void] Inspect() {
        for ($i = 0; $i -lt $this.Items.Count; $i++) {
            $this.Inspected++
            $this.Items[$i] = & $this.Operation $this.Items[$i]

            # Always attempt to reduce the value using the LCM to keep the number from being too large.
            $this.Items[$i] %= [Monkey]::LeastCommonMultiple

            if ($this.Items[$i] % $this.Test -eq 0) {
                [Monkey]::Monkeys[$this.IfTrue].Items.Add($this.Items[$i])
            } else {
                [Monkey]::Monkeys[$this.IfFalse].Items.Add($this.Items[$i])
            }
        }

        $this.Items.Clear()
    }

    # The least common multiple of *all* divisors
    # The greatest common demoninator for these 1 (small numbers)
    static [void] SetLeastCommonMultiple() {
        foreach ($value in [Monkey]::Monkeys.Values.Test) {
            [Monkey]::LeastCommonMultiple *= [Monkey]::LeastCommonMultiple * $value
        }
    }
}

[System.IO.File]::ReadAllText("$PSScriptRoot\input.txt") -split '(?m)(?=^Monkey)' -match '.' -as [Monkey[]] | Out-Null

# Get the Greatest Common Divisor. This value will be 1, otherwise would be used to calculate the LCM.
$gcd, $divisors = [Monkey]::Monkeys.Values.Test
foreach ($divisor in $divisors) {
    $gcd = [bigint]::GreatestCommonDivisor($gcd, $divisor)
}

[Monkey]::SetLeastCommonMultiple()

$rounds = 10000

for ($round = 1; $round -le $rounds; $round++) {
    foreach ($monkey in [Monkey]::Monkeys.Values) {
        $monkey.Inspect()
    }
}

$values = [Monkey]::Monkeys.Values.Inspected | Sort-Object | Select-Object -Last 2
$values[0] * $values[1]
