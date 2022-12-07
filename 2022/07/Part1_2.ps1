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
        $pathItems[$thisPath] = @{
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

$total = 0
foreach ($directory in $pathItems.Values) {
    if ($directory.TotalSize -le 100000) {
        $total += $directory.TotalSize
    }
}
$total
