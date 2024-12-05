$ruleSet, $updates = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt") -split '(\r?\n){2}'

$rules = @{}
foreach ($rule in $ruleSet -split '\r?\n' -match '.') {
    $before, $after = $rule -split '\|'
    if (-not $rules.Contains($before)) {
        $rules[$before] = @()
    }
    $rules[$before] += $after
}

$sum = 0
:update
foreach ($update in $updates -split '\r?\n' -match '.') {
    $pages = $update -split ','
    $index = @{}
    for ($i = 0; $i -lt $pages.Count; $i++) {
        $index[$pages[$i]] = $i
    }

    for ($i = 0; $i -lt $pages.Count; $i++) {
        $page = $pages[$i]

        if ($rules.Contains($page)) {
            foreach ($after in $rules[$page]) {
                if (-not $index.Contains($after)) {
                    continue
                }

                if ($i -gt $index[$after]) {
                    # Rule is violated.
                    continue update
                }
            }
        }
    }

    $sum += $pages[[Math]::Floor($pages.Count / 2)]
}
$sum