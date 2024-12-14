param (
    [switch]
    $Show,

    [switch]
    $ShowFinal,

    [switch]
    $Sample,

    [switch]
    $Watch,

    [int]
    $From = 0,

    [int]
    $To = 100,

    [int]
    $Sleep = 5
)

function Show-Grid {
    Clear-Host
    $line = @('{0} {0}' -f ('.' * [Robot]::midX))
    $line * [Robot]::midY | Write-Host
    ' ' * ([Robot]::maxX + 1) | Write-Host
    $line * [Robot]::midY | Write-Host
    '', '', '' | Write-Host
}

function Write-Positions {
    param (
        [Hashtable]
        $Positions,

        [int]
        $Second,

        [switch]
        $Reset
    )

    foreach ($position in $Positions.GetEnumerator()) {
        $x, $y = $position.Key -split ',' -as [int[]]
        [Console]::SetCursorPosition($x, $y)

        $isMid = $x -eq [Robot]::midX -or $y -eq [Robot]::midY

        if ($Reset) {
            if ($isMid) {
                [Console]::Write(' ')
            } else {
                [Console]::Write('.')
            }
        } else {
            $colour = $PSStyle.Foreground.Green
            if ($isMid) {
                $colour = $PSStyle.Foreground.BrightBlack
            }
            [Console]::Write(('{0}{1}{2}' -f $colour, $position.Value, $PSStyle.Reset))
        }
    }

    [Console]::SetCursorPosition(0, [Robot]::maxy + 2)
    if ($Second -eq 0) {
        [Console]::Write('Initial state')
    } else {
        [Console]::Write('After {0} seconds' -f $Second)
    }

    [Console]::SetCursorPosition(0, [Robot]::maxy + 3)
}

class Robot {
    static [int] $maxX = 10
    static [int] $maxY = 6
    static [int] $midX
    static [int] $midY

    [int]
    $x

    [int]
    $y

    [int]
    $vx

    [int]
    $vy

    [int]
    $Quadrant

    static [Robot[]] Init() {
        return [Robot]::Init($false)
    }

    static [Robot[]] Init([bool] $sample) {
        if ($sample) {
            [Robot]::maxX = 10
            [Robot]::maxY = 6
            $file = 'sample.txt'
        } else {
            [Robot]::maxX = 100
            [Robot]::maxY = 102
            $file = 'input.txt'
        }

        [Robot]::midX = [Robot]::maxX / 2
        [Robot]::midY = [Robot]::maxY / 2

        $robots = foreach ($entry in [System.IO.File]::ReadAllLines((Join-Path $PSScriptRoot $file))) {
            if ($entry -match '^p=(\d+),(\d+) v=(-?\d+),(-?\d+)') {
                [Robot]@{
                    x  = $matches[1]
                    y  = $matches[2]
                    vx = $matches[3]
                    vy = $matches[4]
                }
            }
        }

        return $robots
    }

    [void] Move() {
        $this.x += $this.vx
        if ($this.x -gt [Robot]::maxX) {
            $this.x -= [Robot]::maxX + 1
        } elseif ($this.x -lt 0) {
            $this.x += [Robot]::maxX + 1
        }

        $this.y += $this.vy
        if ($this.y -gt [Robot]::maxY) {
            $this.y -= [Robot]::maxY + 1
        } elseif ($this.y -lt 0) {
            $this.y += [Robot]::maxY + 1
        }
    }

    [int] GetQuadrant() {
        if ($this.x -eq [Robot]::midX) {
            return 0
        }
        if ($this.y -eq [Robot]::midY) {
            return 0
        }
        if ($this.x -lt [Robot]::midX -and $this.y -lt [Robot]::midY) {
            return 1
        }
        if ($this.x -gt [Robot]::midX -and $this.y -lt [Robot]::midY) {
            return 2
        }
        if ($this.x -lt [Robot]::midX -and $this.y -gt [Robot]::midY) {
            return 3
        }
        return 4
    }

    [void] UpdateQuadrant() {
        $this.Quadrant = $this.GetQuadrant()
    }
}

if ($Watch) {
    $Show = $true
}

$robots = [Robot]::Init($Sample)

for ($second -eq 1; $second -lt $From; $second++) {
    $robots.Move()
}

if ($Show -or $ShowFinal) {
    Show-Grid

    $positions = @{}
    foreach ($robot in $robots) {
        $positions[('{0},{1}' -f $robot.x, $robot.y)]++
    }
    Write-Positions -Positions $positions
    if ($Watch) {
        Start-Sleep -Milliseconds 5
    } else {
        Read-Host
    }
    Write-Positions -Positions $positions -Reset
}

for ($second = $From; $second -le $To; $second++) {
    if ($Show -or $ShowFinal) {
        $positions = @{}
    }

    foreach ($robot in $robots) {
        $robot.Move()

        if ($Show -or $ShowFinal) {
            $positions[('{0},{1}' -f $robot.x, $robot.y)]++
        }
    }

    if ($Show) {
        Write-Positions -Positions $positions -Second $second
        if ($Watch) {
            Start-Sleep -Milliseconds $Sleep
        } else {
            Read-Host
        }
        if ($second -lt $To) {
            Write-Positions -Positions $positions -Reset -Second $second
        }
    }
}

if ($ShowFinal) {
    Write-Positions -Positions $positions -Second $second
}
