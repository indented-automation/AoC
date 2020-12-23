using namespace System.Collections.Generic

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

$puzzleInput = '135468729'

$sequence = [RotatingSequence]::new((
    $puzzleInput -split '' -ne '' -as [int[]]
))

$lowest, $highest = ($sequence.values | Sort-Object)[0,-1]

for ($move = 1; $move -le 100; $move++) {
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
$values = for ($i = 0; $i -lt $sequence.values.Count - 1; $i++) {
    $sequence.ReadValue()
}
-join $values
