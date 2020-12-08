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

$all = $toplevel | %{ $_; $_.Contains } | group-object Name -AsHashTable -AsString

function Get-BagContent {
    param (
        $Name,
        $NumberOfBags = 1
    )

    $all[$Name] | ? Contains | % Contains | %{
        $cumulativeNumber = $numberOfBags * $_.Count
        Get-BagContent $_.Name -NumberOfBags $cumulativeNumber
        $cumulativeNumber
    }
}
Get-BagContent 'shiny gold' | measure -sum
