$template, $importRules = Get-Content "$PSScriptRoot\input.txt" | Where-Object { $_ }

$rules = @{}
foreach ($rule in $importRules) {
    $element, $value = $rule -split ' -> '
    $rules[$element] = @(
        '{0}{1}' -f $element[0], $value
        '{0}{1}' -f $value, $element[1]
    )
}

$state = @{}
for ($i = 0; $i -lt $template.Length - 1; $i++) {
    $value = $template.Substring($i, 2)

    if ($rules.Contains($value)) {
        $state[$value]++
    }
}

for ($step = 1; $step -le 10; $step++) {
    $current = $state.Clone()

    foreach ($value in [object[]]$current.Keys) {
        $state[$value] -= $current[$value]
        foreach ($newValue in $rules[$value]) {
            $state[$newValue] += $current[$value]
        }
    }
}

$chars = @{}
foreach ($pair in $state.Keys) {
    $chars[[string]$pair[0]] += $state[$pair]
    $chars[[string]$pair[1]] += $state[$pair]
}
$count = $chars.GetEnumerator() | Measure-Object Value -Minimum -Maximum
[Math]::Ceiling($count.Maximum / 2) - [Math]::Ceiling($count.Minimum / 2)
