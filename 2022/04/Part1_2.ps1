$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$count = 0
foreach ($assignment in $data) {
    $sections = foreach ($section in $assignment -split ',') {
        $start, $end = $section -split '-' -as [int[]]
        @{ Start = $start; End = $end }
    }

    if ($sections[0].Start -ge $sections[1].Start -and $sections[0].End -le $sections[1].End) {
        $count++
    } elseif ($sections[1].Start -ge $sections[0].Start -and $sections[1].End -le $sections[0].End) {
        $count++
    }
}
$count
