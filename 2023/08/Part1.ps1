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
}

$sequence, $null, [Node[]]$nodes = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$node = [Node]::All['AAA']

$p = $c = 0
do {
    if ($p -ge $sequence.Length) {
        $p = 0
    }
    $node = $node.GetNext($sequence[$p])

    $c++
    $p++
} until ($node.Name -eq 'ZZZ')
$c
