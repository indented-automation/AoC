using namespace System.Collections.Generic

class RotatingSequence {
    [object[]] $values
    [int]      $position

    RotatingSequence(
        [object[]] $values
    ) {
        $this.values = $values
    }

    [object] GetNext() {
        if (++$this.position -ge $this.values.Count) {
            $this.position = 0
        }
        return $this.values[$this.position]
    }

    [object] GetPrevious() {
        $this.position--
        if ($this.position -lt 0) {
            $this.position = $this.values.Count - 1
        }
        return $this.values[$this.position]
    }
}

function Trace-Path {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]$Direction,

        [int[]]$Position = @(0, 0)
    )

    begin {
        $facing = [RotatingSequence]::new(@('N', 'E', 'S', 'W'))
        $visited = [HashSet[string]]::new()
    }

    process {

        $rotate, [int]$distance = $_ -split '(?<=[a-z])'
        $moveInDirection = switch ($rotate) {
            'L' { $facing.GetPrevious(); break }
            'R' { $facing.GetNext(); break }
        }

        if ($moveInDirection -in 'W', 'E') { $axis = 0 }
        if ($moveInDirection -in 'N', 'S') { $axis = 1 }
        if ($moveInDirection -in 'W', 'S') { $distance = $distance * -1 }

        # Already at the first point, skip that one
        foreach ($point in $Position[$axis]..($Position[$axis] + $distance) | Select-Object -Skip 1) {
            $coordinates = @(
                $axis -eq 0 ? $point : $Position[0]
                $axis -eq 1 ? $point : $Position[1]
            )
            $positionAsString = '{0},{1}' -f $coordinates
            if (-not $visited.Add($positionAsString)) {
                $coordinates
            }
        }

        $Position[$axis] = $Position[$axis] + $distance
    }
}

$x, $y = (Get-Content $pwd\input.txt) -split ',\s*' |
    Trace-Path -Position 1000, 1000 |
    Select-Object -First 2
[Math]::Abs($x - 1000) + [Math]::Abs($y - 1000)
