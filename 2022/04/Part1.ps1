$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$count = 0
foreach ($assignment in $data) {
    $sections = foreach ($section in $assignment -split ',') {
        $start, $end = $section -split '-' -as [int[]]
        $area = 0
        for ($i = $start; $i -le $end; $i++) {
            $area += [BigInt]1 -shl ($i - 1)
        }
        $area
    }

    if (($sections[0] -band $sections[1]) -in $sections) {
        $count++
    }
}
$count
