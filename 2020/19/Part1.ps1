$content = Get-Content $PSScriptRoot\input.txt

$i = 0
$rules = do {
    $number, $value = $content[$i] -split ': '
    [PSCustomObject]@{
        Number      = $number
        Rule        = $value
        Regex       = $value -replace '"'
        IsReference = $value -notmatch '"."'
    }
    $i++
} while ($content[$i])
$i++

$rulesByNumber = $rules | Group-Object Number -AsHashTable -AsString

while ($rules.IsReference -contains $true) {
    :rule foreach ($rule in $rules) {
        if ($rule.IsReference) {

            $elements = $rule.Rule -split ' '

            if ($elements -contains '|') {
                $regexBuilder = '('
            } else {
                $regexBuilder = ''
            }

            foreach ($element in $elements) {
                if ($element -ne '|' -and $rulesByNumber[$element].IsReference) {
                    continue rule
                }
                if ($element -eq '|') {
                    $regexBuilder += $element
                } else {
                    $regexBuilder += $rulesByNumber[$element].Regex
                }
            }

            if ($elements -contains '|') {
                $regexBuilder += ')'
            }

            $rule.Regex = $regexBuilder
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
