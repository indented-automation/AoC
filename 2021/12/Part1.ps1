function Get-NextNode {
    [CmdletBinding()]
    param (
        [string]$CurrentNode,

        [string]$Path
    )

    $Path += ",$CurrentNode"

    if ($CurrentNode -eq 'end') {
        $Path.TrimStart(',')
    } else {
        foreach ($node in $nodes[$CurrentNode]) {
            if ($node -cmatch '[A-Z]' -or $Path -cnotmatch $node) {
                $params = @{
                    CurrentNode = $node
                    Path        = $Path
                }
                Get-NextNode @params
            }
        }
    }
}

$nodes = @{}

Get-Content input.txt | ForEach-Object {
    $first, $second = $_ -split '-'
    if ($first -ne 'end') {
        $nodes[$first] += @($second)
    }
    if ($first -ne 'start' -and $second -ne 'end') {
        $nodes[$second] += @($first)
    }
}

$paths = Get-NextNode 'start'
$paths.Count
