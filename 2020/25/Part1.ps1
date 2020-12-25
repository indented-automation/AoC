function Find-LoopSize {
    param (
        [int]$PublicKey
    )

    $value = 1
    for ($loopSize = 1;; $loopSize++) {
        $value *= 7
        $value %= 20201227

        if ($value -eq $PublicKey) {
            return $loopSize
        }
    }
}

function Get-Key {
    param (
        [int]$LoopSize,
        [int]$SubjectNumber
    )

    $value = 1
    for ($i = 0; $i -lt $loopSize; $i++) {
        $value *= $subjectNumber
        $value %= 20201227
    }

    return $value
}

$cardPubKey, $doorPubKey = Get-Content $PSScriptRoot\input.txt
$cardLoopSize = Find-LoopSize $cardPubKey
$doorLoopSize = Find-LoopSize $doorPubKey

Get-Key -LoopSize $cardLoopSize -SubjectNumber $doorPubKey
Get-Key -LoopSize $doorLoopSize -SubjectNumber $cardPubKey
