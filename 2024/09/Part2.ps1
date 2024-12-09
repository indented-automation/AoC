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
    static [SortedList[int,FreeSpace]] $freespace = [SortedList[int,FreeSpace]]::new()
    static [Stack[File]] $files = [Stack[File]]::new()

    [int]
    $Position

    [int]
    $Size

    DiskEntry([int] $size) {
        $this.Position = [DiskEntry]::totalSize
        $this.Size = $size

        [DiskEntry]::totalSize += $size
        [DiskEntry]::entries.Add($this)
    }

    static [void] Reset() {
        [DiskEntry]::totalSize = 0
        [DiskEntry]::layout = [string]::Empty
        [DiskEntry]::entries.Clear()
        [DiskEntry]::freespace.Clear()
        [DiskEntry]::files.Clear()
    }

    static [void] InitializeLayout() {
        [DiskEntry]::layout = @('.') * [DiskEntry]::totalSize
        $j = 0
        foreach ($entry in [DiskEntry]::entries) {
            if ($entry -is [File]) {
                for ($i = 0; $i -lt $entry.Size; $i++) {
                    [DiskEntry]::layout[$j + $i] = $entry.ID
                }
            }
            $j += $entry.Size
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

        [DiskEntry]::files.Push($this)
    }

    static [void] Add([int] $id, [int] $size) {
        [File]::new($id, $size)
    }

    [string] ToString() {
        return [string]$this.ID *  $this.Size
    }
}

class FreeSpace : DiskEntry {
    Freespace([int] $size) : base($size) {
        [DiskEntry]::freespace.Add([DiskEntry]::totalSize - $this.Size, $this)
    }

    Freespace([int] $size, [int] $position) : base($size) {
        $this.Position = $position
        [DiskEntry]::freespace.Add($position, $this)
    }

    static [void] Add([int] $size) {
        [FreeSpace]::new($size)
    }

    static [void] Add([int] $size, [int] $position) {
        [FreeSpace]::new($size, $position)
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

while ([DiskEntry]::freespace.Count -and [DiskEntry]::files.Count) {
    $file = [DiskEntry]::files.Pop()

    $destination = foreach ($entry in [DiskEntry]::freespace.GetEnumerator()) {
        if ($entry.Value.Size -ge $file.Size) {
            $entry.Value
            break
        }
    }

    if (-not $destination) {
        # The algorithm never revisits a file.
        continue
    }

    if ($destination.Position -gt $file.Position) {
        continue
    }

    if ($file.Size -lt $destination.Size) {
        $position = $destination.Position + $file.Size
        [Freespace]::Add(
            $destination.Size - $file.Size,
            $destination.Position + $file.Size
        )
    }

    $null = [DiskEntry]::freespace.Remove($destination.position)

    for ($i = $file.Position; $i -lt $file.Position + $file.Size; $i++) {
        [DiskEntry]::layout[$i] = '.'
    }
    for ($i = $destination.Position; $i -lt $destination.Position + $file.Size; $i++) {
        [DiskEntry]::layout[$i] = $file.ID
    }

    if ($Show) {
        [DiskEntry]::ShowLayout()
    }
}

$checksum = 0
for ($i = 0; $i -lt [DiskEntry]::layout.Count; $i++) {
    $block = [DiskEntry]::layout[$i]
    if ($block -eq '.') {
        continue
    }
    $checksum += [int]$block * $i
}
$checksum