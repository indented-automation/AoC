$towels, $null, $designs = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$towels = $towels -split ',\s*'

$towelsLongestFirst = @(
    $towels | Sort-Object { $_.Length } -Descending
) -join '|'

$anyTowelAtStart = '^({0})' -f $towelsLongestFirst
$anyTowelAtEnd = '({0})$' -f $towelsLongestFirst

$towelsLongestFirstAnchored = '^({0})+$' -f $towelsLongestFirst

$count = 0
foreach ($design in $designs) {
    if ($design -notmatch $anyTowelAtStart -or $design -notmatch $anyTowelAtEnd) {
        continue
    }

    try {
        # Attempt a match using the anchored pattern with a timeout because otherwise this will burn.
        if ([Regex]::Match($design, $towelsLongestFirstAnchored, 'None', [TimeSpan]::FromMilliseconds(50)).Success) {
            $count++
        }
    } catch {
        # Ignore errors raised here.
    }
}
$count