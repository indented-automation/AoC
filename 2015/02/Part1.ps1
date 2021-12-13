$total = 0
Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $length, $width, $height = $_ -split 'x' -as [int[]]

    $slack = [Math]::Min($length * $width, $width * $height)
    $slack = [Math]::Min($slack, $height * $length)
    $total += (
        2 * $length * $width +
        2 * $width * $height +
        2 * $height * $length
    ) + $slack
}
$total
