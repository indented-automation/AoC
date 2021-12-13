$nice = Get-Content "$PSScriptRoot\input.txt" | Where-Object {
    $_ -match '(.).\1' -and
    $_ -match '(..).*\1'
}
$nice.Count
