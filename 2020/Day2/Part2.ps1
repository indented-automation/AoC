gc $PSScriptRoot\input.txt | ?{ $_ -match '^(?<a>\d+)-(?<b>\d+) (?<c>.): (?<p>.+)' } | ?{
    $a, $b = $matches.p[-1 + $matches.a], $matches.p[-1 + $matches.b]
    $matches.c -in $a, $b -and $a, $b -ne $matches.c
} | measure

$i = 0
$content = gc $PSScriptRoot\input.txt
$content | ForEach-Object {
    $_ -match '^(?<min>\d+)-(?<max>\d+) (?<letter>\w):\s(?<chars>.+)$' | Out-Null
    if (($matches.letter -eq $matches.chars[$matches.min -1]) -xor
        ($matches.letter -eq $matches.chars[$matches.max -1])
    ) {
        $i++
    }
}
$i
