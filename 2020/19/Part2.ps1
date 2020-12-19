function Resolve-RecursiveRule {
    [CmdletBinding()]
    param (
        $Rule,
        $Regex = [System.Text.StringBuilder]::new(),
        $MaxDepth = 10,
        $CurrentDepth = 0
    )

    if ($CurrentDepth -ge $MaxDepth) {
        return $Regex
    }

    $elements = $Rule.Rule -split ' '

    $null = $Regex.Append('(')
    foreach ($element in $elements) {
        if ($element -eq $Rule.Number) {
            $Regex = Resolve-RecursiveRule -Rule $Rule -Regex $Regex -CurrentDepth ($CurrentDepth + 1)
        } elseif ($element -eq '|') {
            $null = $Regex.Append('|')
        } else {
            $null = $Regex.Append($rulesByNumber[$element].Regex)
        }
    }

    $null = $Regex.Append(')')
    $Regex
}

$content = Get-Content $PSScriptRoot\input.txt

$i = 0
$rules = do {
    $number, $value = $content[$i] -split ': '

    if ($number -eq '8') {
        $value = '42 | 42 8'
    }
    if ($number -eq '11') {
        $value = '42 31 | 42 11 31'
    }

    [PSCustomObject]@{
        Number      = $number
        Rule        = $value
        Regex       = $value -replace '"'
        IsReference = $value -notmatch '"."'
    }
    $i++
} while ($content[$i])
$i++
$rules = $rules | Sort-Object { [int]$_.Number }

$rulesByNumber = $rules | Group-Object Number -AsHashTable -AsString

while ($rules.IsReference -contains $true) {
    :rule foreach ($rule in $rules) {
        if ($rule.IsReference) {
            $skipReference = $rule.Rule -split ' ' -match '\d' -ne $rule.Number |
                Where-Object { $rulesByNumber[$_].IsReference }
            if ($skipReference) {
                continue
            }

            $rule.Regex = (Resolve-RecursiveRule -Rule $rule).ToString()
            $rule.IsReference = $false
        }
    }
}

$values = do {
    $content[$i]
    $i++
} while ($content[$i] -and $i -lt $content.Length)
$regex = $rulesByNumber["0"].Regex
($values -match "^$regex$").Count
