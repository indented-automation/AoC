$all = 'abcdefghijklmnopqrstuvwxyz'
$twoPairs = '(.)\1.*(.)\2'

$sequences = for ($i = 0; $i -lt $all.Length - 2; $i++) {
    -join $all[$i, ($i + 1), ($i + 2)]
}
$sequence = $sequences -join '|'

[char[]]$chars = 'vzbxkghb'
$i = $chars.Count - 1

do {
    if ($string -match '(.*?)([oil])(.*)') {
        $chars = '{0}{1}{2}' -f @(
            $matches[1]
            [char]([int][char]$matches[2] + 1)
            'a' * $matches[3].Length
        )
    }

    for ($j = $i; $j -ge 0; $j--) {
        if ($chars[$j] -eq 'z') {
            $chars[$j] = 'a'
        } else {
            $chars[$j] = [int]$chars[$j] + 1
            break
        }
    }

    $string = -join $chars

    $isValid = $string -match $twoPairs -and
        $string -match $sequence
} until ($isValid)

$string
