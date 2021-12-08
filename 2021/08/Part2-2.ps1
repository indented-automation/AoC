[Flags()]
enum Segments {
    a = 1
    b = 2
    c = 4
    d = 8
    e = 16
    f = 32
    g = 64
}

$wellKnown = @{
    2 = 1
    4 = 4
    3 = 7
    7 = 8
}

$signalPatterns = Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $signal, $output = $_ -split '\s*\|\s*'
    $signal = $signal -split '\s'
    $output = $output -split '\s'
    $signal = foreach ($value in $signal -split '\s') {
        $array = $value.ToCharArray()
        [Array]::Sort($array)
        [string]::new($array)
    }
    $output = foreach ($value in $output -split '\s') {
        $array = $value.ToCharArray()
        [Array]::Sort($array)
        [string]::new($array)
    }
    [PSCustomObject]@{
        Signal = $signal
        Output = $output
        All    = [System.Collections.Generic.HashSet[string]]@($signal + $output)
    }
}

$segmentRules = @(
    @{
        Name       = 'a'
        Rule       = { $numbers.Contains(1) -and $numbers.Contains(7) }
        Expression = { $numbers[1] -bxor $numbers[7] }
    }
    @{
        Name       = 'b'
        Rule       = { $numbers.Contains(3) -and $numbers.Contains(9) }
        Expression = { $numbers[9] - $numbers[3] }
    }
    @{
        Name       = 'c'
        Rule       = { $numbers.Contains(1) -and $numbers.Contains(5) }
        Expression = { $numbers[1] - ($numbers[1] -band $numbers[5]) }
    }
    @{
        Name       = 'c'
        Rule       = { $numbers.Contains(3) -and $numbers.Contains(5) }
        Expression = { $numbers[3] - ($numbers[3] -band $numbers[5]) }
    }
    @{
        Name       = 'd'
        Rule       = { $numbers.Contains(3) -and $numbers.Contains(7) -and $segments.Contains('g') }
        Expression = { $numbers[3] - $numbers[7] - $segments['g'] }
    }
    @{
        Name       = 'e'
        Rule       = { $numbers.Contains(3) -and $numbers.Contains(2) }
        Expression = { $numbers[2] - ($numbers[2] -band $numbers[3]) }
    }
    @{
        Name       = 'f'
        Rule       = { $numbers.Contains(1) -and $numbers.Contains(2) }
        Expression = {
            $numbers[1] - ($numbers[1] -band $numbers[2])
        }
    }
    @{
        Name       = 'g'
        Rule       = { $numbers.Contains(3) -and $numbers.Contains(4) -and $numbers.Contains(7) }
        Expression = { $numbers[3] - ($numbers[3] -band ($numbers[4] -bor $numbers[7])) }
    }
)

$numberRules = @{
    5 = @(
        @{
            Value = 2
            Rule  = {
                $numbers.Contains(3) -and $numbers.Contains(5)
            }
        }
        @{
            Value = 3
            Rule  = {
                $numbers.Contains(1) -and
                ($valueData.Bits -band $numbers[1]) -eq $numbers[1]
            }
        }
        @{
            Value = 5
            Rule = {
                $segments.Contains('b') -and
                ($valueData.Bits -band $segments['b']) -eq $segments['b']
            }
        }
    )
    6 = @(
        @{
            Value = 0
            Rule  = {
                if ($segments.Contains('c') -and $segments.Contains('e')) {
                    $mask = $segments['c'] -bor $segments['e']
                    ($valueData.Bits -band $mask) -eq $mask
                }
            }
        }
        @{
            Value = 6
            Rule  = {
                $numbers.Contains(0) -and $numbers.Contains(9)
            }
        }
        @{
            Value = 9
            Rule  = {
                $numbers.Contains(3) -and $numbers.Contains(4) -and $numbers.Contains(7) -and
                $valueData.Bits -eq ($numbers[3] -bor $numbers[4] -bor $numbers[7])
            }
        }
    )
}

$total = 0
foreach ($signalPattern in $signalPatterns) {
    $values = @{}
    foreach ($value in $signalPattern.All) {
        $values[$value] = [PSCustomObject]@{ Name = $value; Value = -1; Bits = [Segments][string[]][char[]]$value }
    }

    $numbers = @{}
    $segments = @{}
    $matched = 0

    foreach ($value in [string[]]$values.Keys) {
        if ($wellKnown.Contains($value.Length)) {
            $values[$value].Value = $wellKnown[$value.Length]
            $numbers[$wellKnown[$value.Length]] = $values[$value].Bits
            $matched++
        }
    }

    do {
        foreach ($rule in $segmentRules) {
            if (-not $segments.Contains($rule.Name)) {
                if (& $rule.Rule) {
                    $segments[$rule.Name] = & $rule.Expression
                }
            }
        }

        foreach ($value in [string[]]$values.Keys) {
            $valueData = $values[$value]

            if ($valueData.Value -gt -1) {
                continue
            }

            :rule foreach ($rule in $numberRules.($value.Length)) {
                if (& $rule.Rule) {
                    $numbers[$rule.Value] = $values[$value].Bits
                    $valueData.Value = $rule.Value
                    $matched++

                    break rule
                }
            }
        }
    } while ($segments.Count -lt 7 -or $matched -lt 10)

    $output = 0
    for (($i = 3), ($j = 0); $i -ge 0; ($i--), ($j++)) {
        $output += $values[$signalPattern.Output[$j]].Value * [Math]::Pow(10, $i)
    }
    $total += $output
}
Write-Host $total
