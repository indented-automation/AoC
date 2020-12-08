gc $PSScriptRoot\input.txt | ? { $_ -match '^(?<r>.+?)(?<c>.{3})$' } | %{
    $rows = 0..127
    switch ($matches.r.ToCharArray()) {
        { $true } { $l = ($rows.Count / 2) - 1 }
        'F'       { $rows = $rows[0..$l]  }
        'B'       { $rows = $rows[($l + 1)..($rows.Count - 1)] }
    }
    $row = $rows[0]

    $columns = 0..7
    switch ($matches.c.ToCharArray()) {
        { $true } { $l = ($columns.Count / 2) - 1 }
        'L'       { $columns = $columns[0..$l]  }
        'R'       { $columns = $columns[($l + 1)..($columns.Count - 1)] }
    }
    $column = $columns[0]

    $row * 8 + $column
} | Sort | Select -last 1
