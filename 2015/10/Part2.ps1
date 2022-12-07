$data = '1321131112'

$maxIterations = 50
for ($i = 1; $i -le $maxIterations; $i++) {
    $newData = foreach ($match in [Regex]::Matches($data, '(.)(\1)*')) {
        $match.Length
        $match.Value[0]
    }
    $data = -join $newData

    "${i}: $($data.Length)"
}
$data.Length
