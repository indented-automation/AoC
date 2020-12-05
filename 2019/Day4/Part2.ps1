$m = foreach ($v in 234208..765869) {
    $p = $v -as [string]

    if ([Regex]::Matches($p, '(\d)\1+').Length -eq 2) {
        $d = $false
        for ($i = 1; $i -lt $p.Length; $i++) {
            if ($p[$i] -lt $p[$i - 1]) {
                $d = $true
                break
            }
        }
        if (-not $d) {
            $v
        }
    }
}
$m.Count
