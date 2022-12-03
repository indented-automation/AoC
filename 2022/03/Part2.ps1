$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$map = @{}
for (($i = 1), ($j = 27); $i -le 26; $i++, $j++) {
    $map[[char](96 + $i)] = $i
    $map[[char](64 + $i)] = $j
}

$sum = 0
for ($i = 0; $i -lt $data.Count; $i += 3) {
    $rucksacks = $data[$i..($i + 3)]
    $possibleBadge = [System.Linq.Enumerable]::Intersect(
        $rucksacks[0].ToCharArray(),
        $rucksacks[1].ToCharArray()
    )
    $badge = [System.Linq.Enumerable]::Intersect(
        $possibleBadge,
        $rucksacks[2].ToCharArray()
    ) | Write-Output

    $sum += $map[$badge]
}
$sum
