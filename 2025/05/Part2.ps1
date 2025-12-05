using namespace System.Collections.Generic
using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

class Range {
    [long]
    $Start

    [long]
    $End

    [Range[]]
    $OverlapsWith

    [bool]
    $IsMerged

    [long] GetInclusizeSize() {
        return $this.End - $this.Start + 1
    }
    

    [string] ToString() {
        return '{0}-{1}' -f $this.Start, $this.End
    }
}

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$data = [File]::ReadAllText([Path]::Combine($PSScriptRoot, $fileName))

$fresh, $available = $data -split '(\r?\n){2,}'

$fresh = $fresh.Trim() -split '\r?\n'
$available = $available.Trim() -split '\r?\n' -ne '' -as [long[]]

[List[Range]]$ranges = foreach ($range in $fresh) {
    $start, $end = $range -split '-'
    @{ Start = $start; End = $end }
}

do {
    $foundOverlap = $false
    $ranges = foreach ($a in $ranges) {
        if ($a.IsMerged) {
            continue
        }

        foreach ($b in $ranges) {
            if ($a -eq $b) {
                continue
            }

            if (($a.Start -ge $b.Start -and $a.Start -le $b.End) -or
                ($a.End -ge $b.Start -and $a.End -le $b.End)
            ) {
                $foundOverlap = $true
                $a.Start = [Math]::Min($a.Start, $b.Start)
                $a.End = [Math]::Max($a.End, $b.End)
                $b.IsMerged = $true
            }
        }

        $a
    }
} while ($foundOverlap)

$total = 0
foreach ($range in $ranges) {
    $total += $range.GetInclusizeSize()
}
$total