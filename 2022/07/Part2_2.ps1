$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$pathItems = [Ordered]@{}
$Path = [System.Collections.Generic.Stack[string]]::new()
switch -wildcard ($data) {
    '$ cd ..' {
        $null = $Path.Pop()
        continue
    }
    '$ cd*' {
        $null, $null, $name = $_.Split()
        if ($name -eq '/') {
            $Path.Push('root')
        } else {
            $Path.Push($name)
        }
        continue
    }
    '$ ls*' {
        $thisPath = $Path -join '/'
        $pathItems[$thisPath] = [PSCustomObject]@{
            Path      = $thisPath
            Parent    = $pathItems[$thisPath -replace '^.+?/']
            TotalSize = 0
        }
        continue
    }
    '[0-9]* *' {
        [long]$size, $file = $_.Split()

        $parent = $pathItems[$thisPath]
        while ($parent) {
            $parent.TotalSize += $size
            $parent = $parent.Parent
        }
        continue
    }
}

$freeSpace = 70000000 - $pathItems['root'].TotalSize
$requiredSpace = 30000000 - $freeSpace
$totals = [System.Collections.Generic.SortedSet[int]]::new()

foreach ($directory in $pathItems.Values) {
    if ($directory.TotalSize -gt $requiredSpace) {
        $null = $totals.Add($directory.TotalSize)
    }
}

$totals.Min
