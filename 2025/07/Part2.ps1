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
$beams = [Dictionary[int,long]]::new()
$beams[$data[0].IndexOf('S')] = 1

for ($y = 1; $y -lt $data.Count; $y++) {
    $line = $data[$y]

    $next = [Dictionary[int,long]]::new()

    for ($x = 0; $x -lt $line.Length; $x++) {
        if (-not $beams.ContainsKey($x)) {
            continue
        }

        if ($line[$x] -ne '^') {
            $next[$x] = $beams[$x]
        }
    }

    for ($x = 0; $x -lt $line.Length; $x++) {
        if ($line[$x] -ne '^') {
            continue
        }

        $next[$x + 1] += $beams[$x]
        $next[$x - 1] += $beams[$x]
    }

    $beams = $next
}

$timelines = 0
foreach ($beam in $beams.GetEnumerator()) {
    $timelines += $beam.Value
}
$timelines
