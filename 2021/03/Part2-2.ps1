$bits = gc "input.txt"
$values = foreach ($bit in $bits) {
    1 * "0b$bit"
}
$length = $bits[0].Length

$most = $true
$ratings = 1
foreach ($component in 1..2) {
    $rating = $bitMask = 0
    $set = $values

    for ($position = $length - 1; $position -ge 0; $position--) {
        $bit = 1 -shl $position

        $ones = $zeroes = 0
        $set = foreach ($value in $set) {
            if (($value -band $bitMask) -eq $rating) {
                if (($value -band $bit) -eq $bit) {
                    $ones++
                } else {
                    $zeroes++
                }
                $value
            }
        }
        if ($set.Count -eq 1) {
            $rating = $set
            break
        }

        if (($most -and $ones -ge $zeroes) -or (-not $most -and $ones -lt $zeroes)) {
            $rating = $rating -bor $bit
        }
        $bitMask = $bitMask -bor $bit
    }
    $ratings *= $rating
    $most = $false
}

$ratings
