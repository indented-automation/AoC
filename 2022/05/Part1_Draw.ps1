$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$i = 0
$initial = do {
    if ($data[$i]) {
        $data[$i]
    }
} while ($data[$i++])

[Array]::Reverse($initial)
$header, $entries = $initial
$header = $header.Trim() -split '\s+'

# Read each column
$stack = [Ordered]@{}
for ($j = 0; $j -lt $header.Count; $j++) {
    $values = foreach ($entry in $entries) {
        $position = $j * 4 + 1
        if ($entry.Length -gt $position) {
            $value = $entry.Substring($position, 1).Trim()
            if ($value) {
                $value
            }
        }
    }
    $stack[$header[$j]] = [System.Collections.Generic.Stack[string]]$values
}

Clear-Host

$height = 50

[Console]::SetCursorPosition(0, $height - 1)
[Console]::Write('-' * (4 * $stack.Count - 1))
[Console]::SetCursorPosition(0, $height)
[Console]::Write(' ')
foreach ($key in $stack.Keys) {
    [Console]::Write($key.PadRight(4, ' '))
}

$column = 0
foreach ($key in $stack.Keys) {
    $row = $height - 2
    foreach ($value in $stack[$key]) {
        [Console]::SetCursorPosition(4 * $column, $row)
        [Console]::Write('[{0}] ' -f $value)
        $row--
    }
    $column++
}

[Console]::SetCursorPosition(0, $height + 2)

for (;$i -le $data.Count; $i++) {
    if ($data[$i] -match 'move (?<count>\d+) from (?<from>\d+) to (?<to>\d+)') {
        [Console]::SetCursorPosition(0, $height + 1)
        [Console]::Write($data[$i])

        for ($j = 1; $j -le [int]$matches['count']; $j++) {
            $item = $stack[$matches['from']].Pop()

            $fromColumn = ([int]$matches['from'] - 1) * 4
            $row = $stack[$matches['from']].Count
            [Console]::SetCursorPosition($fromColumn, $height - $row - 2)
            [Console]::Write('    ')

            $toColumn = ([int]$matches['to'] - 1) * 4
            $row = $stack[$matches['to']].Count
            [Console]::SetCursorPosition($toColumn, $height - $row - 2)
            [Console]::Write('[{0}] ' -f $item)

            $stack[$matches['to']].Push($item)

            [Console]::SetCursorPosition(0, $height + 2)
        }

        Start-Sleep -Milliseconds 5
    }
}

$values = foreach ($name in $header) {
     $stack[$name].Pop()
}
-join $values
