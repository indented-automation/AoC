class RotatingSequence {
    [object[]] $values
    [int]      $position

    RotatingSequence(
        [object[]] $values
    ) {
        $this.values = $values
    }

    RotatingSequence(
        [object[]] $values,
        [object]   $initialValue
    ) {
        $this.values = $values
        $this.position = $values.IndexOf($initialValue)
    }

    [object] Get() {
        return $this.values[$this.position]
    }

    [object] GetNext() {
        if (++$this.position -ge $this.values.Count) {
            $this.position = 0
        }
        return $this.values[$this.position]
    }

    [object] GetNext(
        [int] $Number
    ) {
        $value = $this.values[$this.position]
        for ($i = 0; $i -lt $Number; $i++) {
            $value = $this.GetNext()
        }
        return $value
    }

    [object] GetPrevious() {
        $this.position--
        if ($this.position -lt 0) {
            $this.position = $this.values.Count - 1
        }
        return $this.values[$this.position]
    }

    [object] GetPrevious(
        [int] $Number
    ) {
        $value = $this.values[$this.position]
        for ($i = 0; $i -lt $Number; $i++) {
            $value = $this.GetPrevious()
        }
        return $value
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
        $facing = [RotatingSequence]::new(@('N', 'E', 'S', 'W'), 'E')
    }

    process {
        $moveInDirection, [int]$distance = $_ -split '(?<=[a-z])'

        if ($moveInDirection -in 'L', 'R') {
            $rotate = $distance / 90
            $null = switch ($moveInDirection) {
                'L' { $facing.GetPrevious($rotate); break }
                'R' { $facing.GetNext($rotate); break }
            }
        } else {
            switch ($moveInDirection) {
                'F'                 { $_ = $moveInDirection = $facing.Get() }
                { $_ -in 'W', 'E' } { $axis = 0 }
                { $_ -in 'N', 'S' } { $axis = 1 }
                { $_ -in 'W', 'S' } { $distance = $distance * -1 }
            }
            $Position[$axis] = $Position[$axis] + $distance
        }
    }

    end {
        $Position
    }
}

$x, $y = Get-Content $pwd\input.txt |
    Trace-Path -Position 1000, 1000 |
    Select-Object -Last 2
[Math]::Abs($x - 1000) + [Math]::Abs($y - 1000)
