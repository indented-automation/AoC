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
        $thisPath = ([string[]]$Path)[$Path.Count..0] -join '\'
        $pathItems[$thisPath] = [PSCustomObject]@{
            Name        = Split-Path $thisPath -Leaf
            FullName    = $thisPath
            Directories = [System.Collections.Generic.List[object]]::new()
            Files       = [System.Collections.Generic.List[object]]::new()
            Parent      = $pathItems[(Split-Path $thisPath -Parent)]
            Size        = 0
            TotalSize   = 0
        }
        continue
    }
    'dir (.+)' {
        $pathItems[$thisPath].Directories.Add(
            [PSCustomObject]@{
                Type     = 'Directory'
                Name     = $matches[1]
                FullName = ($thisPath, $matches[1] -join '\')
            }
        )
        continue
    }
    '^(\d+) (.+)' {
        $size = [long]$matches[1]
        $pathItems[$thisPath].Files.Add(
            [PSCustomObject]@{
                Type = 'File'
                Name = $matches[2]
                Size = $size
            }
        )
        $pathItems[$thisPath].Size += $size

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
$pathItems.Values | Sort-Object TotalSize | Where-Object TotalSize -gt $requiredSpace | Select-Object -First 1
