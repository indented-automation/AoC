$signalPatterns = Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $signal, $output = $_ -split '\s*\|\s*'
    $signal = $signal -split '\s'
    $output = $output -split '\s'

    [PSCustomObject]@{
        Signal = $signal
        Output = $output
        All    = $signal + $output
    }
}
$signalPatterns.Output | Where-Object Length -in 2, 3, 4, 7 | Measure-Object
