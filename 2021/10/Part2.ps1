[int64[]]$scores = foreach ($expression in Get-Content "$PSScriptRoot\input.txt") {
    $regex = '\(\)|\[]|\{}|<>'

    # Complete chunks
    while ($expression -match $regex) {
        $expression = $expression -replace $regex
    }

    # Not corrupt
    if (-not $expression.TrimEnd('([{<')) {
        [int64]$score = 0
        $tail = ''

        $incompleteExpression = [char[]]$expression
        [Array]::Reverse($incompleteExpression)
        switch ($incompleteExpression) {
            { $true } { $score *= 5 }
            '('       { $tail += ')'; $score += 1; continue }
            '['       { $tail += ']'; $score += 2; continue }
            '{'       { $tail += '}'; $score += 3; continue }
            '<'       { $tail += '>'; $score += 4; continue }
        }

        $score
    }
}
[Array]::Sort($scores)
$scores[[Math]::Floor($scores.Count / 2)]
