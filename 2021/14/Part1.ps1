$template, $importRules = Get-Content "$PSScriptRoot\input.txt" | Where-Object { $_ }

$rules = @{}
foreach ($rule in $importRules) {
    $element, $value = $rule -split ' -> '
    $rules[$element] = $value
}

for ($step = 1; $step -le 10; $step++) {
    $pairs = for ($i = 0; $i -lt $template.Length - 1; $i++) {
        [PSCustomObject]@{
            Value = $template.Substring($i, 2)
            Index = $i
        }
    }

    foreach ($pair in $pairs | Sort-Object Index -Descending) {
        if ($rules.Contains($pair.Value)) {
            $template = $template.Insert($pair.Index + 1, $rules[$pair.Value])
        }
    }
}

$count = [char[]]$template | Group-Object | Measure-Object Count -Minimum -Maximum
$count.Maximum - $count.Minimum
