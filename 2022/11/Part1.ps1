using namespace System.Collections.Generic

class Monkey {
    [string]       $Number
    [List[int]]    $Items
    [ScriptBlock]  $Operation
    [int]          $Test
    [string]       $IfTrue
    [string]       $IfFalse
    [int]          $Inspected = 0

    static $Monkeys = [Ordered]@{}

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
            $this.Items[$i] = [Math]::Floor($this.Items[$i] / 3)
            if ($this.Items[$i] % $this.Test -eq 0) {
                [Monkey]::Monkeys[$this.IfTrue].Items.Add($this.Items[$i])
            } else {
                [Monkey]::Monkeys[$this.IfFalse].Items.Add($this.Items[$i])
            }
        }

        $this.Items.Clear()
    }
}

[System.IO.File]::ReadAllText("$PSScriptRoot\input.txt") -split '(?m)(?=^Monkey)' -match '.' -as [Monkey[]] | Out-Null

$rounds = 20

for ($round = 1; $round -le $rounds; $round++) {
    foreach ($monkey in [Monkey]::Monkeys.Values) {
        $monkey.Inspect()
    }
}

$values = [Monkey]::Monkeys.Values.Inspected | Sort-Object | Select-Object -Last 2
$values[0] * $values[1]
