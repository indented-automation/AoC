$numbers = @{}

$puzzleInput = 11,0,1,10,5,19
for ($index = 0; $index -lt $puzzleInput.Count; $index++) {
    $numbers.Add(
        $puzzleInput[$index],
        @{
            Last     = $index
            Previous = $index
        }
    )
}
$last = $puzzleInput[-1]

while ($index -lt 30000000) {
    if ($numbers.Contains($last)) {
        $current = $numbers[$last].Last - $numbers[$last].Previous
    }
    if ($numbers.Contains($current)) {
        $numbers[$current] = @{ Last = $index; Previous = $numbers[$current].Last }
    } else {
        $numbers[$current] = @{ Last = $index; Previous = $index }
    }

    $last = $current

    $index++
}
$last
