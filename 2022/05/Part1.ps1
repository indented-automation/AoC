$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$i = 0
$stackState = do {
    if ($data[$i]) {
        $data[$i]
    }
} while ($data[$i++])

[Array]::Reverse($stackState)
$header, $entries = $stackState
$stackState = @(
    $header.Trim() -replace '\s+', ','
    foreach ($entry in $entries) {
        $entry = $entry.PadRight($header.Length + 1)
        $entries = for ($j = 0; $j -lt $entry.Length; $j += 4) {
            $entry.Substring($j + 1, 1).Trim()
        }
        $entries -join ','
    }
)

$stackState = $stackState | ConvertFrom-Csv
$properties = $stackState[0].PSObject.Properties.Name

$stack = [Ordered]@{}
foreach ($property in $properties) {
    $stack[$property] = [System.Collections.Generic.Stack[string]]($stackState.$property | Where-Object { $_ })
}

for (;$i -lt $data.Count; $i++) {
    if ($data[$i] -match 'move (?<count>\d+) from (?<from>\d+) to (?<to>\d+)') {
        for ($j = 1; $j -le [int]$matches['count']; $j++) {
            $item = $stack[$matches['from']].Pop()
            $stack[$matches['to']].Push($item)
        }
    }
}

$values = foreach ($property in $properties) {
     $stack[$property].Pop()
}
-join $values
