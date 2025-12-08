using namespace System.Collections.Generic
using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

class JunctionBox : IEquatable[object] {
    [string]
    $Name

    [int]
    $x

    [int]
    $y

    [int]
    $z

    [Circuit]
    $Circuit

    [HashSet[JunctionBox]]
    $ConnectedTo = [HashSet[JunctionBox]]::new()

    JunctionBox([string] $position) {
        $this.Name = $position
        $this.x, $this.y, $this.z = $position -split ','
        $this.Circuit = [Circuit]::new($this)
    }

    [void] Connect([JunctionBox] $other) {
        if (-not $this.ConnectedTo.Add($other)) {
            return
        }
        $other.ConnectedTo.Add($this)

        if ($this.Circuit -eq $other.Circuit) {
            $this.Connect($other.Circuit)
            return
        }

        foreach ($junctionBox in $other.Circuit.JunctionBoxes) {
            $junctionBox.Disconnect()
            $junctionBox.Connect($this.Circuit)
        }

        return
    }

    [void] Connect([Circuit] $circuit) {
        $this.Circuit = $circuit
        $circuit.Connect($this)
    }

    [void] Disconnect() {
        $this.Circuit.Disconnect($this)
        $this.Circuit = $null
    }

    [bool] Equals([object] $other) {
        return $this.Name -eq $other.Name
    }

    [int] GetHashCode() {
        return $this.Name.GetHashCode()
    }

    [string] ToString() {
        return $this.Name
    }
}

class Circuit {
    static [List[Circuit]] $All = [List[Circuit]]::new()
    static [int] $ID = 1

    [string]
    $Name

    [int]
    $Size

    [HashSet[JunctionBox]]
    $JunctionBoxes = [HashSet[JunctionBox]]::new()

    Circuit([JunctionBox] $junctionBox) {
        $this.Name = 'Circuit {0}' -f [Circuit]::ID++
        [Circuit]::All.Add($this)
        $this.JunctionBoxes.Add($junctionBox)
        $this.Size = $this.JunctionBoxes.Count
    }

    [void] Connect([JunctionBox] $junctionBox) {
        $this.JunctionBoxes.Add($junctionBox)
        $this.Size = $this.JunctionBoxes.Count
        $junctionBox.Circuit = $this
    }

    [void] Disconnect([JunctionBox] $junctionBox) {
        $this.JunctionBoxes.Remove($junctionBox)
        $this.Size = $this.JunctionBoxes.Count

        if ($this.Size -le 0) {
            [Circuit]::All.Remove($this)
        }
    }

    static [double] GetDistance([JunctionBox] $a, [JunctionBox] $b) {
        return [Math]::Sqrt((
            [Math]::Pow($a.x - $b.x, 2) + 
            [Math]::Pow($a.y - $b.y, 2) + 
            [Math]::Pow($a.z - $b.z, 2)
        ))
    }

    static [void] Reset() {
        [Circuit]::All.Clear()
        [Circuit]::ID = 1
    }

    [string] ToString() {
        return '{0} [Junction boxes: {1}]' -f $this.Name, $this.Size
    }
}

class Distance {
    [JunctionBox]
    $a
    
    [JunctionBox]
    $b
    
    [double]
    $Distance

    [string] ToString() {
        return '{0} -> {1} ({2})' -f $this.a, $this.b, $this.Distance
    }
}

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$data = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName))

[Circuit]::Reset()

$junctionBoxes = [JunctionBox[]]$data
$distances = foreach ($a in $junctionBoxes) {
    foreach ($b in $junctionBoxes) {
        if ($a -eq $b) {
            continue
        }

        [Distance]@{
            a        = $a
            b        = $b
            Distance = [Circuit]::GetDistance($a, $b)
        }
    }
}

$distances = $distances | Sort-Object Distance

foreach ($distance in $distances) {
    $distance.a.Connect($distance.b)

    if ([Circuit]::All.Count -le 1) {
        $distance.a.x * $distance.b.x
        break
    }
}
