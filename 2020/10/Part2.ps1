function GetNext {
    param ( $index, $count = 0n, $state = @{} )

    if ($index -eq $max) {
        return 1
    }

    foreach ($v in $possibleStepHash["$index"].ToValue) {
        if ($state.Contains("$v")) {
            $count = $count + $state["$v"]
        } else {
            $partial = GetNext $v -count $count -state $state
            $state["$v"] = $partial
            $count = $count + $partial
        }
    }

    $count
}

$adapters = @(
    0
    Get-Content $pwd\input.txt | ForEach-Object { [int]$_ } | Sort-Object
)
$adapters += $adapters[-1] + 3

$possibleSteps = for ($i = 0; $i -lt $adapters.Count; $i++) {
    $currentNode = $adapters[$i]
    foreach ($j in 1..3) {
        $candidateNode = $adapters[$i + $j]
        if ($candidateNode -and $candidateNode - $currentNode -le 3) {
            [PSCustomObject]@{
                From      = $i
                FromValue = $currentNode
                To        = $i + $j
                ToValue   = $candidateNode
                Gap       = $candidateNode - $currentNode
            }
        }
    }
}

$possibleStepHash = $possibleSteps | Group-Object FromValue -AsHashtable -AsString

$max = $adapters[-1]
GetNext 0
