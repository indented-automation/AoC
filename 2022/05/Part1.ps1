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

for (;$i -lt $data.Count; $i++) {
    if ($data[$i] -match 'move (?<count>\d+) from (?<from>\d+) to (?<to>\d+)') {
        for ($j = 1; $j -le [int]$matches['count']; $j++) {
            $item = $stack[$matches['from']].Pop()
            $stack[$matches['to']].Push($item)
        }
    }
}

$values = foreach ($name in $header) {
     $stack[$name].Pop()
}
-join $values
