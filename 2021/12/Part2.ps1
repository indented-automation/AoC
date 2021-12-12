function Get-NextNode {
    [CmdletBinding()]
    param (
        [string]$CurrentNode,

        [string]$Path,

        [string]$Revisit
    )

    $Path += ",$CurrentNode"

    if ($CurrentNode -eq 'end') {
        $Path.TrimStart(',')
    } else {
        foreach ($node in $nodes[$CurrentNode]) {
            $params = @{
                CurrentNode = $node
                Path        = $Path
                Revisit     = $Revisit
            }

            $canVisit = $node -cmatch '[A-Z]'
            if ($node -cmatch '[a-z]') {
                if ($Path -cnotmatch $node) {
                    $canVisit = $true
                } elseif ($Revisit -eq '') {
                    $canVisit = $true
                    $params['Revisit'] = $node
                }
            }
            if ($canVisit) {
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
