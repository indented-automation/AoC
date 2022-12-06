$data = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt").Trim()

for ($i = 0; $i -le $data.Length - 14; $i++) {
    [System.Collections.Generic.HashSet[string]]$marker = $data[$i..($i + 14 - 1)]
    if ($marker.Count -eq 14) {
        $i + 14
        break
    }
}
