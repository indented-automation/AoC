$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$map = @{}
for (($i = 1), ($j = 27); $i -le 26; $i++, $j++) {
    $map[[char](96 + $i)] = $i
    $map[[char](64 + $i)] = $j
}

$sum = 0
foreach ($rucksack in $data) {
    $size = $rucksack.Length / 2
    $first, $second = $rucksack -split "(?<=^.{$size})"
    $intersect = [System.Linq.Enumerable]::Intersect(
        $first.ToCharArray(),
        $second.ToCharArray()
    )
    foreach ($itemType in $intersect) {
        $sum += $map[$itemType]
    }
}
$sum
