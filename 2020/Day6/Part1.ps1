(gc $PSScriptRoot\input.txt -Raw) -split '(\r?\n){2}' | ?{ $_.Trim() } | %{
    ($_ -replace '[^a-z]' -as [char[]] -as [System.Collections.Generic.HashSet[char]]).Count
} | measure -sum | % sum
