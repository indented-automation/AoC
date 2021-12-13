$nice = Get-Content "$PSScriptRoot\input.txt" | Where-Object {
    $_ -notmatch 'ab|cd|pq|xy' -and
    $_ -match '([a-z])\1' -and
    [Regex]::Matches($_, '[aeiou]').Count -ge 3
}
$nice.Count
