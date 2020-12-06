(gc $PSScriptRoot\input.txt -Raw) -split '(\r?\n){2}' | ?{ $_.Trim() } | %{
    $groupSize = @($_.Trim() -split '\r?\n').Count
    $_ -replace '[^a-z]' -as [char[]] | group-object { $_ } | ? Count -eq $groupSize
} | measure | % count
