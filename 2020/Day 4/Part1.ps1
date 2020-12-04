(Get-Content $pwd\input.txt -Raw) -split '(\r?\n){2}' | ?{ $_.Trim() } | ?{
    $h = $_ -split ' ' -replace ':', '=' | Out-String | ConvertFrom-StringData
    $h.Keys.Count -eq 8 -or ($h.Keys.Count -eq 7 -and -not $h.ContainsKey('cid'))
} | measure
