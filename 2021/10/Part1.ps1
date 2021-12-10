$score = 0
foreach ($expression in Get-Content "$PSScriptRoot\input.txt") {
    $regex = '\(\)|\[]|\{}|<>'

    # Complete chunks
    while ($expression -match $regex) {
        $expression = $expression -replace $regex
    }
    # Incomplete
    $expression = $expression.TrimEnd('([{<')

    # Corrupt
    if ($expression) {
        $invalid = [Regex]::Match($expression, '([[<{(])[\]>})]+$')
        $invalidChar = $expression[$invalid.Index + 1]
        $score += switch ($invalidChar) {
            ')' { 3; break }
            ']' { 57; break }
            '}' { 1197; break }
            '>' { 25137; break }
        }
    }
}
$score
