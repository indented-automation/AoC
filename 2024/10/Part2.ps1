using namespace System.Collections.Generic

class Position {
    [int]
    $X

    [int]
    $Y

    [int]
    $Height

    Position([int]$x, [int]$y, [int]$height) {
        $this.X = $x
        $this.Y = $y
        $this.Height = $height
    }

    static [Position] Create([string]$x, [string]$y, [string]$height) {
        if ($height -eq 0) {
            return [Trailhead]::new($x, $y, $height)
        }
        return [Position]::new(
            $x,
            $y,
            $height -eq '.' ? 99 : $height
        )
    }

    [string] ToString() {
        return '{0},{1}:{2}' -f $this.X, $this.Y, $this.Height
    }
}

class Trailhead : Position {
    [int]
    $Score

    Trailhead([int]$x, [int]$y, [int]$height) : base($x, $y, $height) {
        [TrailInfo]::Trailheads.Add($this)
    }
}

class TrailInfo {
    static [List[Position]] $Trailheads = [List[Position]]::new()
    hidden static [HashSet[string]] $uniqueStartEnd = [HashSet[string]]::new()

    [Position]
    $Start

    [Position]
    $End

    [Position[]]
    $Path

    TrailInfo([Position[]] $path) {
        $this.Start = $path[0]
        $this.End = $path[-1]
        $this.Path = $path
    }

    static [void] Reset() {
        [TrailInfo]::Trailheads.Clear()
        [TrailInfo]::uniqueStartEnd.Clear()
    }

    static [TrailInfo] Create([Position[]] $path) {
        $trailInfo = [TrailInfo]::new($path)
        $trailInfo.Start.Score++
        return $trailInfo
    }

    [string] ToString() {
        return '{0} -> {1}' -f $this.Start, $this.End
    }
}

function Get-NextPosition {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [Position]
        $Position,

        [Position[]]
        $Path
    )

    begin {
        $directions = @(
            @(0, -1),
            @(-1, 0),
            @(1, 0),
            @(0, 1)
        )
    }

    process {
        if ($Position.Height -eq 9) {
            if ($trailInfo = [TrailInfo]::Create(@($Path; $Position))) {
                return $trailInfo
            }
            return
        }

        foreach ($direction in $directions) {
            $x = $Position.X + $direction[0]
            $y = $Position.Y + $direction[1]

            if ($y -lt 0 -or $y -gt $maxY -or $x -lt 0 -or $x -gt $maxX) {
                continue
            }

            $neighbour = $positions[$y][$x]

            if ($neighbour.Height - $Position.Height -ne 1) {
                continue
            }

            Get-NextPosition -Position $neighbour -Path @(
                $Path | Where-Object { $_ }
                $Position
            )
        }
    }
}

function Show-Trail {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [TrailInfo]
        $Trail,

        [switch]
        $PassThru
    )

    process {
        Clear-Host
        Write-Host $Trail
        Write-Host
        $map | Out-Host

        foreach ($position in $Trail.Path) {
            [Console]::SetCursorPosition($position.X, $position.Y + 2)
            [Console]::Write(('{0}{1}{2}' -f $PSStyle.Foreground.Cyan, $Position.Height, $PSStyle.Reset))
        }
        [Console]::SetCursorPosition(0, $maxY + 2)

        pause

        if ($PassThru) {
            $Trail
        }
    }
}

[TrailInfo]::Reset()

$map = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$maxX = $map[0].Length - 1
$maxY = $map.Count - 1

$positions = for ($y = 0; $y -lt $map.Count; $y++) {
    $row = for ($x = 0; $x -lt $map[$y].Length; $x++) {
        [Position]::Create($x, $y, $map[$y][$x])
    }
    ,$row
}

$trails = [TrailInfo]::Trailheads | Get-NextPosition # | Show-Trail -PassThru
$sum = 0
foreach ($trailhead in [TrailInfo]::Trailheads) {
    $sum += $trailhead.Score
}
$sum