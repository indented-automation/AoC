class Node {
    static [Hashtable] $All = @{}

    [string]
    $Name

    [string]
    $L

    [string]
    $R

    Node(
        [string] $record
    ) {
        $this.Name, $this.L, $this.R = $record -split '\s*[,=]\s' -replace '\W'
        [Node]::All[$this.Name] = $this
    }

    [Node] GetNext(
        [string] $Direction
    ) {
        return [Node]::All[$this.$Direction]
    }

    [string] ToString() {
        return '{0} = ({1}, {2})' -f $this.Name, $this.L, $this.R
    }
}

function Get-Lcm {
    param (
        [long]$Value1,
        [long]$Value2
    )

    for ($lcm = 1; ; $lcm++) {
        if (($Value1 * $lcm) % $Value2 -eq 0) {
            return $Value1 * $lcm
        }
    }
}

$sequence, $null, [Node[]]$nodes = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$nodes = [Node]::All.Values | Where-Object Name -like '*A'

$lcm = 0
foreach ($node in $nodes) {
    $p = $c = 0
    do {
        if ($p -ge $sequence.Length) {
            $p = 0
        }
        $node = $node.GetNext($sequence[$p])

        $c++
        $p++
    } until ($node.Name -like '*Z')

    if ($lcm) {
        $lcm = Get-Lcm $lcm $c
    } else {
        $lcm = $c
    }
}
$lcm
