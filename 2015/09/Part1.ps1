function Get-NextNode {
    [CmdletBinding()]
    param (
        [string]$CurrentNode,

        [string]$Path,

        [int]$Cost,

        [int]$Length = 1
    )

    $Path += ",$CurrentNode"

    $nextNodes = foreach ($node in $nodes[$CurrentNode].Next) {
        if (-not $Path.Contains($node.Name)) {
            $node
        }
    }
    if ($nextNodes) {
        foreach ($node in $nextNodes) {
            $params = @{
                CurrentNode = $node.Name
                Path        = $Path
                Length      = $Length + 1
                Cost        = $Cost + $node.Cost
            }
            Get-NextNode @params
        }
    } else {
        if ($Length -eq $nodes.Count) {
            [PSCustomObject]@{
                Path   = $Path.TrimStart(',')
                Length = $Length
                Cost   = $Cost
            }
        }
    }
}

$nodes = @{}
Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $from, $to, [int]$cost = $_ -split ' to | = '

    foreach ($direction in @($from, $to), @($to, $from)) {
        $name, $next = $direction

        if (-not $nodes.Contains($name)) {
            $nodes[$name] = [PSCustomObject]@{
                Name = $name
                Next = @()
            }
        }

        $nodes[$name].Next += [PSCustomObject]@{
            Name = $next
            Cost = $cost
        }
    }
}

$paths = foreach ($name in $nodes.Keys) {
    Get-NextNode $name
}
($paths | Measure-Object Cost -Minimum).Minimum
