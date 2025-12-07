using namespace System.Collections.Generic
using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$data = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName))

$split = 0
$beams = [HashSet[int]]::new([int[]]$data[0].IndexOf('S'))

for ($y = 1; $y -lt $data.Count; $y++) {
    $line = $data[$y]

    for ($x = 0; $x -lt $line.Length; $x++) {
        if ($line[$x] -ne '^') {
            continue
        }

        if (-not $beams.Contains($x)) {
            continue
        } 

        $split++
        $null = $beams.Remove($x)
        $null = $beams.Add($x + 1)
        $null = $beams.Add($x - 1)
    }
}
$split
