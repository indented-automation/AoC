class RotatingSequence {
    [object[]] $Values

    [void] RotateRight() {
        $this.RotateRight(1)
    }

    [void] RotateRight(
        [int] $Offset
    ) {
        if ($Offset -lt 0) {
            $Offset = $this.Values.Count + $Offset
        }
        $tempValues = $this.Values.Clone()
        for ($i = 0; $i -lt $this.Values.Count; $i++) {
            $position = $i + $Offset
            if ($position -ge $this.Values.Count) {
                $position = $position - $this.Values.Count
            }
            $this.Values[$position] = $tempValues[$i]
        }
    }

    [void] RotateLeft() {
        $this.RotateRight(-1)
    }

    [void] RotateLeft(
        [int] $Offset
    ) {
        $this.RotateRight($Offset * -1)
    }
}

function Trace-Path {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]$Direction,

        [int[]]$Position = @(0, 0),

        $Waypoint
    )

    begin {
        $rotatingSequence = [RotatingSequence]::new()
    }

    process {
        $instruction, [int]$magnitude = $_ -split '(?<=[a-z])'

        if ($instruction -in 'L', 'R') {
            $rotatingSequence.Values = [int[]]$Waypoint.PSObject.Properties.Value

            $rotate = $magnitude / 90
            switch ($instruction) {
                'L' { $rotatingSequence.RotateLeft($rotate); break }
                'R' { $rotatingSequence.RotateRight($rotate); break }
            }
            $Waypoint = [PSCustomObject]@{
                N =  $rotatingSequence.Values[0]
                E =  $rotatingSequence.Values[1]
                S =  $rotatingSequence.Values[2]
                W =  $rotatingSequence.Values[3]
            }
        }

        if ($instruction -in 'N', 'E', 'S', 'W') {
            $Waypoint.$instruction += $magnitude
        }

        if ($instruction -eq 'F') {
            $Position[0] += ($Waypoint.E - $Waypoint.W) * $magnitude
            $Position[1] += ($Waypoint.N - $Waypoint.S) * $magnitude
        }
    }

    end {
        $Position
    }
}

$x, $y = Get-Content $pwd\input.txt | Trace-Path -Waypoint ([PSCustomObject]@{
    N = 1
    E = 10
    S = 0
    W = 0
})
[Math]::Abs($x) + [Math]::Abs($y)
