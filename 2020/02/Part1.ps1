gc $PSScriptRoot\input.txt | ?{ $_ -match '^(?<a>\d+)-(?<b>\d+) (?<c>.): (?<p>.+)' } | ?{
    $l = ($matches.p -replace "[^$($matches.c)]").Length
    $l -ge [int]$matches.a -and $l -le [int]$matches.b
} | measure
