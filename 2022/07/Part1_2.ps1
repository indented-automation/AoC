$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$pathItems = [Ordered]@{}
$Path = [System.Collections.Generic.Stack[string]]::new()
switch -regex ($data) {
    '\$ cd [.]{2}' {
        $null = $Path.Pop()
        continue
    }
    '\$ cd (.+)' {
        if ($matches[1] -eq '/') {
            $Path.Push('root')
        } else {
            $Path.Push($matches[1])
        }
        continue
    }
    '\$ ls' {
        $thisPath = $Path -join '/'
        $pathItems[$thisPath] = [PSCustomObject]@{
            Path      = $thisPath
            Parent    = $pathItems[$thisPath -replace '^.+?/']
            TotalSize = 0
        }
        continue
    }
    '^(\d+) (.+)' {
        $size = [long]$matches[1]

        $parent = $pathItems[$thisPath]
        while ($parent) {
            $parent.TotalSize += $size
            $parent = $parent.Parent
        }

        continue
    }
}
$pathItems.Values | Where-Object TotalSize -le 100000 | Measure-Object TotalSize -Sum
