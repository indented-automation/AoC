$ribbon = 0
Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $length, $width, $height = $_ -split 'x' -as [int[]]

    $length, $width, $height | Sort-Object | Select-Object -First 2 | ForEach-Object {
        $ribbon += 2 * $_
    }
    $ribbon += $length * $width * $height

}
$ribbon
