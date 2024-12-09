using namespace System.Collections.Generic

param (
    [switch]
    $Show
)

enum EntryType {
    File
    FreeSpace
}

class DiskEntry {
    static [int] $totalSize = 0
    static [string[]] $layout
    static [List[DiskEntry]] $entries = [List[DiskEntry]]::new()
    static [SortedSet[int]] $freespace = [SortedSet[int]]::new()
    static [Stack[int]] $blocks = [Stack[int]]::new()

    [int]
    $Size

    DiskEntry([int] $size) {
        $this.Size = $size

        [DiskEntry]::totalSize += $size

        [DiskEntry]::entries.Add($this)
    }

    static [void] Reset() {
        [DiskEntry]::totalSize = 0
        [DiskEntry]::layout = [string]::Empty
        [DiskEntry]::entries.Clear()
        [DiskEntry]::freespace.Clear()
        [DiskEntry]::blocks.Clear()
    }

    static [void] InitializeLayout() {
        [DiskEntry]::layout = [string[]]::new([DiskEntry]::totalSize)
        $j = 0
        foreach ($entry in [DiskEntry]::entries) {
            for ($i = 0; $i -lt $entry.Size; ($i++), ($j++)) {
                if ($entry -is [File]) {
                    [DiskEntry]::layout[$j] = $entry.ID
                    [DiskEntry]::blocks.Push($j)
                } else {
                    [DiskEntry]::layout[$j] = '.'
                    [DiskEntry]::freespace.Add($j)
                }
            }
        }
    }

    static [string] ShowLayout() {
        return (-join [DiskEntry]::layout).PadRight([DiskEntry]::totalSize, '.')
    }
}

class File : DiskEntry {
    [int]
    $ID

    File([int] $id, [int] $size) : base($size) {
        $this.ID = $id
    }

    static [void] Add([int] $id, [int] $size) {
        [File]::new($id, $size)
    }

    [string] ToString() {
        return [string]$this.ID *  $this.Size
    }
}

class FreeSpace : DiskEntry {
    Freespace([int] $size) : base($size) { }

    static [void] Add([int] $size) {
        [FreeSpace]::new($size)
    }

    [string] ToString() {
        return '.' * $this.Size
    }
}

$map = [System.IO.File]::ReadAllText("$PSScriptRoot\input.txt")

[DiskEntry]::Reset()

[EntryType]$EntryType = 'File'
for (($i = 0), ($j = 0); $i -lt $map.Length; $i++) {
    if ($EntryType -eq 'File') {
        [File]::Add($j++, [string]$map[$i])
    } else {
        [FreeSpace]::Add([string]$map[$i])
    }

    $EntryType = $EntryType -bxor 1
}

[DiskEntry]::InitializeLayout()
if ($Show) {
    [DiskEntry]::ShowLayout()
}

while ([DiskEntry]::freespace.Count) {
    $freespaceIndex = [DiskEntry]::freespace.Min
    $null = [DiskEntry]::freespace.Remove($freespaceIndex)

    $blockIndex = [DiskEntry]::blocks.Pop()

    if ($freespaceIndex -gt $blockIndex) {
        break
    }

    [DiskEntry]::layout[$freespaceIndex] = [DiskEntry]::layout[$blockIndex]
    [DiskEntry]::layout[$blockIndex] = '.'
    $null = [DiskEntry]::freespace.Add($blockIndex)

    if ($Show) {
        [DiskEntry]::ShowLayout()
    }
}

$checksum = 0
for ($i = 0; $i -lt [DiskEntry]::layout.Count; $i++) {
    $block = [DiskEntry]::layout[$i]
    if ($block -eq '.') {
        break
    }
    $checksum += [int]$block * $i
}
$checksum