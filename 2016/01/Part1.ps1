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

        $Position[$axis] = $Position[$axis] + $distance
    }

    end {
        return $Position
    }
}

$x, $y = (Get-Content $pwd\input.txt) -split ',\s*' | Trace-Path -Position 1000, 1000
[Math]::Abs($x - 1000) + [Math]::Abs($y - 1000)
