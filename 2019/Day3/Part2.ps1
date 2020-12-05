function Trace-Path {
    [CmdletBinding()]
    param (
        [char]$ID,
        [string[]]$Directions,
        [int[]]$Position = @(0, 0),
        [Hashtable]$Visited
    )

    $Directions | % { $steps = 0 } {
        $isX = $isY = $false
        $direction, [int]$distance = $_ -split '(?<=[a-z])'
        if ($direction -in 'R', 'L') { $axis = 0; $isX = $true }
        if ($direction -in 'U', 'D') { $axis = 1; $isY = $true }
        if ($direction -in 'L', 'D') { $distance = $distance * -1 }

        foreach ($point in $Position[$axis]..($Position[$axis] + $distance)) {
            $coordinates = '{0},{1}' -f @(
                @($Position[0], $point)[$isX]
                @($Position[1], $point)[$isY]
            )

            if ($visited.ContainsKey($coordinates) -and $visited[$coordinates].ID -ne $ID) {
                $visited[$coordinates] = @{
                    ID    = 'X'
                    Steps = $visited[$coordinates].Steps + @{
                        $ID = $steps
                    }
                }
            } else {
                $visited[$coordinates] = @{
                    ID = $ID
                    Steps = @{
                        $ID = $steps
                    }
                }
            }
            $steps++
        }
        $steps--
        $Position[$axis] = $Position[$axis] + $distance
    }
}

$visited = @{}

$wire1, $wire2 = gc $PSScriptRoot\input.txt
Trace-Path ($wire1 -split ',') -ID 1 -Visited $visited
Trace-Path ($wire2 -split ',') -ID 2 -Visited $visited

$visited.Keys | ?{ $_ -ne '0,0' -and $visited[$_].ID -eq 'X' } | %{
    [int]$x, [int]$y = $_ -split ','
    [PSCustomObject]@{
        Coordinates   = $_
        CombinedSteps = $visited[$_].Steps.Values | %{ $i = 0 } { $i += $_ } { $i }
    }
} | sort CombinedSteps | select -first 1
