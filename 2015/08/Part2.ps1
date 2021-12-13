$total = 0
Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $string = $_

    $encoded = $string -replace '\\', '\\'
    $encoded = $encoded -replace '"', '\"'
    $encoded = '"{0}"' -f $encoded

    $total += $encoded.Length - $string.Length
}
$total
