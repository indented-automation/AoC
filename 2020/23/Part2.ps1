using namespace System.Collections.Generic
using namespace System.Diagnostics

class RotatingSequence {
    [LinkedList[int]]     $Values
    [LinkedListNode[int]] $CurrentNode
    [Hashtable]           $allNodes = @{}

    RotatingSequence(
        [int[]] $values
    ) {
        $this.Values = [LinkedList[int]]::new($values)
        $this.CurrentNode = $this.Values.First

        $node = $this.Values.First
        while ($node) {
            $this.allNodes[$node.Value] = $node
            $node = $node.Next
        }
    }

    [int] ReadValue() {
        $value = $this.CurrentNode.Value
        $this.CurrentNode = $this.GetNextNode()

        return $value
    }

    [LinkedListNode[int]] GetNextNode() {
        if ($this.CurrentNode.Next) {
            $this.CurrentNode = $this.CurrentNode.Next
        } else {
            $this.CurrentNode = $this.Values.First
        }
        return $this.CurrentNode
    }

    [LinkedListNode[int]] FindNode(
        [int] $value
    ) {
        return $this.allNodes[$value]
    }

    [LinkedListNode[int][]] TakeNodes(
        [int] $Number
    ) {
        $nodes = for ($i = 0; $i -lt $Number; $i++) {
            $node = $this.CurrentNode
            $node

            $null = $this.GetNextNode()
            $this.Values.Remove($node)
        }
        return $nodes
    }

    [void] InsertAfter(
        [LinkedListNode[int]]   $after,
        [LinkedListNode[int][]] $nodes
    ) {
        foreach ($node in $nodes) {
            $this.Values.AddAfter($after, $node)

            $after = $node
        }
    }
}

$stopWatch = [StopWatch]::StartNew()

$puzzleInput = '135468729'
$values = $puzzleInput -split '' -ne '' -as [int[]]
$lowest, $highest = ($values | Sort-Object)[0,-1]

$sequence = [RotatingSequence]::new(@(
    $values
    for ($i = $highest; $i -lt 1000000; $i++) {
        $i + 1
    }
))

$highest = 1000000

for ($move = 1; $move -le 10000000; $move++) {
    $cup = $sequence.ReadValue()
    $taken = $sequence.TakeNodes(3)
    $destination = $cup - 1
    while ($true) {
        if ($destination -lt $lowest) {
            $destination = $highest
        }
        $node = $sequence.FindNode($destination)

        if (-not $node -or $node.Value -in $taken.Value) {
            $destination--
        } else {
            break
        }
    }
    $sequence.InsertAfter(
        $node,
        $taken
    )
}

$sequence.CurrentNode = $sequence.FindNode(1)
$null = $sequence.GetNextNode()
[PSCustomObject]@{
    Values    = $value1, $value2 = $sequence.ReadValue(), $sequence.ReadValue()
    Answer    = $value1 * $value2
    TimeTaken = $stopWatch.Elapsed
}
