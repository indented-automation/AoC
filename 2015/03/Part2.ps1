$directions = Get-Content "$PSScriptRoot\input.txt"
$sx = $sy = $rx = $ry = 0
$visited = @{ "$sx,$sy" = 2 }

for ($i = 0; $i -lt $directions.Length; $i += 2) {
    switch ($directions[$i]) {
        '^' { $sy-- }
        'v' { $sy++ }
        '>' { $sx++ }
        '<' { $sx-- }
    }
    switch ($directions[$i + 1]) {
        '^' { $ry-- }
        'v' { $ry++ }
        '>' { $rx++ }
        '<' { $rx-- }
    }

    $visited["$sx,$sy"]++
    $visited["$rx,$ry"]++
}

$visited.Count
