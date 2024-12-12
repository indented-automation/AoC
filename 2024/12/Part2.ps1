using namespace System.Collections.Generic

class Point {
    static [Dictionary[string,Point]] $All = [Dictionary[string,Point]]::new()

    [string]
    $Name

    [int]
    $x

    [int]
    $y

    [HashSet[string]]
    $Edges

    [GardenPlot]
    $GardenPlot

    Point([string] $name, [string] $x, [string] $y) {
        $this.Name = $name
        $this.x = $x
        $this.y = $y

        [Point]::All[$this.ToString()] = $this
    }

    static [void] Reset() {
        [Point]::All.Clear()
    }

    [string] ToString() {
        return '{0},{1}' -f $this.x, $this.y
    }
}

class GardenPlot {
    static [List[GardenPlot]] $All = [List[GardenPlot]]::new()
    static [int] $_id = 0

    [int]
    $ID

    [string]
    $Plant

    [int]
    $Area

    [int]
    $Perimeter

    [int]
    $Edges

    [int]
    $Price

    [List[Point]]
    $Points = [List[Point]]::new()

    hidden [List[Point]] $perimeterPoint = [List[Point]]::new()
    hidden [hashtable] $edgeLookup = @{
        n = @{}
        s = @{}
        e = @{}
        w = @{}
    }

    GardenPlot([Point] $point) {
        $this.ID = [GardenPlot]::_id++
        $this.Plant = $point.Name
        $this.AddPoint($point)

        [GardenPlot]::All.Add($this)
    }

    [void] AddPoint([Point] $point) {
        $this.Points.Add($point)
        $point.GardenPlot = $this
        $this.Perimeter += $point.Edges.Count
        $this.Area = $this.Points.Count

        if (-not $point.Edges) {
            return
        }

        $this.perimeterPoint.Add($point)

        foreach ($direction in $point.Edges) {
            $groupBy = $direction -in 'n', 's' ? 'y' : 'x'
            $this.edgeLookup[$direction][$point.$groupBy] += @($point)
        }
    }

    [void] SortEdge() {
        foreach ($direction in $this.edgeLookup.Keys) {
            $sortBy = $direction -in 'n', 's' ? 'x' : 'y'
            foreach ($group in [int[]]$this.edgeLookup[$direction].Keys) {
                $this.edgeLookup[$direction][$group] = $this.edgeLookup[$direction][$group] |
                    Sort-Object $sortBy
            }
        }
    }

    [void] UpdateEdge() {
        $this.SortEdge()

        $count = 0
        foreach ($direction in $this.edgeLookup.Keys) {
            $scan = $direction -in 'n', 's' ? 'x' : 'y'

            foreach ($group in $this.edgeLookup[$direction].Keys) {
                $last = $null
                $count++
                foreach ($edge in $this.edgeLookup[$direction][$group]) {
                    if ($last -and $edge.$scan - $last.$scan -gt 1) {
                        $count++
                    }
                    $last = $edge
                }
            }
        }
        $this.Edges = $count
    }

    [void] UpdatePrice() {
        $this.Price = $this.Edges * $this.Area
    }

    static [void] Reset() {
        [GardenPlot]::_id = 0
        [GardenPlot]::All.Clear()
    }
}

function Get-Neighbour {
    param (
        [Parameter(Mandatory)]
        [Point]
        $Current,

        [HashSet[string]]
        $Visited = [HashSet[string]]::new()
    )

    $null = $Visited.Add($Current.ToString())

    $directions = @{
        e = 1, 0
        w = -1, 0
        n = 0, 1
        s = 0, -1
    }

    $edges = [HashSet[string]][string[]]$directions.Keys
    foreach ($direction in $directions.Keys) {
        $next = '{0},{1}' -f @(
            $Current.x + $directions[$direction][0]
            $Current.y + $directions[$direction][1]
        )

        $neighbour = $null
        if (-not [Point]::All.TryGetValue($next, [ref]$neighbour)) {
            continue
        }

        if ($neighbour.Name -ne $Current.Name) {
            continue
        }

        $null = $edges.Remove($direction)

        if (-not $Visited.Add($next)) {
            continue
        }

        $neighbour

        Get-Neighbour -Current $neighbour -Visited $Visited
    }

    $Current.Edges = $edges
}

[Point]::Reset()
[GardenPlot]::Reset()

$map = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

[List[Point]]$points = for ($y = 0; $y -lt $map.Count; $y++) {
    for ($x = 0; $x -lt $map[$y].Length; $x++) {
        [Point]::new($map[$y][$x], $x, $y)
    }
}

while ($points.Count) {
    $point = $points[0]
    $null = $points.RemoveAt(0)

    $neighbours = Get-Neighbour $point
    $point.GardenPlot = [GardenPlot]::new($point)

    foreach ($neighbour in $neighbours) {
        $point.GardenPlot.AddPoint($neighbour)
        $null = $points.Remove($neighbour)
    }
}

[GardenPlot]::All.UpdateEdge()
[GardenPlot]::All.UpdatePrice()

$total = 0
foreach ($plot in [GardenPlot]::All) {
    $total += $plot.Price
}
$total