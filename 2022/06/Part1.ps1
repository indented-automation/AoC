$data = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt").Trim()

for ($i = 0; $i -le $data.Length - 4; $i++) {
    [System.Collections.Generic.HashSet[string]]$marker = $data[$i..($i + 4 - 1)]
    if ($marker.Count -eq 4) {
        $i + 4
        break
    }
}
