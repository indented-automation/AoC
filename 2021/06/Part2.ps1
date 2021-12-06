$days = 256

$lifecycleMain = @{
    '0' = 0
    '1' = 0
    '2' = 0
    '3' = 0
    '4' = 0
    '5' = 0
    '6' = 0
}
$lifecycleFirst = $lifecycleMain + @{
    '7' = 0
    '8' = 0
}

(gc $PSScriptRoot\input.txt) -split ',' | ForEach-Object {
    $lifecycleMain[$_]++
}

for ($day = 1; $day -le $days; $day++) {
    $lifecycleMainState = $lifecycleMain.Clone()
    $lifecycleFirstState = $lifecycleFirst.Clone()

    for ($stage = 0; $stage -le 8; $stage++) {
        if ($stage -gt 0) {
            $lifecycleFirst[$stage - 1 -as [string]] = $lifecycleFirstState[$stage -as [string]]
            if ($lifecycleMain.Contains($stage -as [string])) {
                $lifecycleMain[$stage - 1 -as [string]] = $lifecycleMainState[$stage -as [string]]
            }
        } else {
            $lifecycleFirst['8'] = $lifecycleFirstState['0'] + $lifecycleMainState['0']
            $lifecycleMain['6'] = $lifecycleFirstState['0'] + $lifecycleMainState['0']
            $lifecycleFirst['0'] = 0
        }
    }

    $total = 0
    $lifecycleFirst.Keys | Sort-Object { [int]$_ } -Descending | ForEach-Object {
        $value = $lifecycleFirst[$_] + $lifecycleMain[$_]
        $total += $value
    }
}
$total
