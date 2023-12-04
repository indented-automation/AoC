using namespace System.Collections.Generic

$cards = foreach ($card in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $null, $win, $hand = $card -split ':\s+|\s\|\s+'

    $matching = [HashSet[int]]($hand -split '\s+')
    $matching.IntersectWith(
        [HashSet[int]]($win -split '\s+')
    )

    @{ MatchCount = $matching.Count; Copies = 1 }
}

$sum = 0
for ($i = 0; $i -lt $cards.Count; $i++) {
    $current = $cards[$i]

    if ($current['MatchCount']) {
        for ($j = $i + 1; $j -le $i + $current['MatchCount']; $j++) {
            $cards[$j]['Copies'] += $current['Copies']
        }
    }

    $sum += $current['Copies']
}
$sum
