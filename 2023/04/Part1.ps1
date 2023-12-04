using namespace System.Collections.Generic

$sum = 0
foreach ($card in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    $number, $win, $hand = $card -split ':\s+|\s\|\s+'

    $matching = [HashSet[int]]($hand -split '\s+')
    $matching.IntersectWith(
        [HashSet[int]]($win -split '\s+')
    )

    if ($matching.Count) {
        $score = 1 -shl ($matching.Count - 1)
    } else {
        $score = 0
    }

    $sum += $score
}
$sum
