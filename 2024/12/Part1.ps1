using namespace System.Collections.Generic

class Point {
    static [Dictionary[string,Point]] $All = [Dictionary[string,Point]]::new()

    [string]
    $Name

    [int]
    $x

    [int]
    $y

    [int]
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
    $Price

    [List[Point]]
    $Points = [List[Point]]::new()

    GardenPlot([Point] $point) {
        $this.ID = [GardenPlot]::_id++
        $this.Plant = $point.Name
        $this.AddPoint($point)

        [GardenPlot]::All.Add($this)
    }

    [void] AddPoint([Point] $point) {
        $this.Points.Add($point)
        $point.GardenPlot = $this
        $this.Perimeter += $point.Edges
        $this.Area = $this.Points.Count
    }

    [void] UpdatePrice() {
        $this.Price = $this.Perimeter * $this.Area
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

    $directions = @(
        @(1, 0),
        @(-1, 0),
        @(0, 1),
        @(0, -1)
    )

    $edges = 4
    foreach ($direction in $directions) {
        $next = '{0},{1}' -f @(
            $Current.x + $direction[0]
            $Current.y + $direction[1]
        )

        $neighbour = $null
        if (-not [Point]::All.TryGetValue($next, [ref]$neighbour)) {
            continue
        }

        if ($neighbour.Name -ne $Current.Name) {
            continue
        }

        $edges--

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

[GardenPlot]::All.UpdatePrice()
$total = 0
foreach ($plot in [GardenPlot]::All) {
    $total += $plot.Price
}
$total