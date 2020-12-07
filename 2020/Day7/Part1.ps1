class Bag {
    [string] $Name
    [Bag[]]  $Contains
    [Bag]    $WhenContainedBy
    [int]    $Count

    [string] ToString() {
        return $this.Name
    }
}

$topLevel = gc $pwd\input.txt | ?{ $_ -match '^(?<name>.+?) bags contain' } | %{
    $top = [Bag]@{ Name = $matches['name'] }
    $top.Contains = [Regex]::Matches($_, '(?<count>\d+) (?<name>.+?) bag') | %{
        $node = [Bag]@{ Name = $_.Groups['name'].Value; Count = $_.Groups['count'].Value }
        $node.WhenContainedBy = $top
        $node
    }
    $top
}

$all = $toplevel | %{ $_; $_.Contains }

function Get-ContainingBags {
    [CmdletBinding()]
    param (
        $Name,
        $hasVisited = @{}
    )

    $all | ? Name -eq $Name | ?{ $_.WhenContainedBy -and -not $hasVisited.ContainsKey($_.WhenContainedBy.Name) } | %{
        $hasVisited[$_.WhenContainedBy.Name] = 1
        $_.WhenContainedBy
        Get-ContainingBags -Name $_.WhenContainedBy -hasVisited $hasVisited
    }
}
Get-ContainingBags -Name 'shiny gold' | measure
