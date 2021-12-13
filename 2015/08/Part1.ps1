$literals = $inMemory = 0
Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $string = $_

    $literals += $string.Length

    $string = $string -replace '^"|"$'
    # Just cheat a bit.
    $string = $string -replace '\\\\', '#'

    foreach ($match in [Regex]::Matches($string, '(?<=\\x)..') | Sort-Object Index -Descending) {
        $string = $string.Remove(
            $match.Index - 2,
            4
        ).Insert(
            $match.Index - 2,
            [char][int]"0x$($match.Value)"
        )
    }

    $string = $string -replace '#', '\'
    $string = $string -replace '\\"', '"'

    $inMemory += $string.Length
}
$literals - $inMemory
