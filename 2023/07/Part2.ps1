using namespace System.IO
using namespace System.Collections.Generic

enum HandType {
    HighCard = 1
    OnePair
    TwoPair
    ThreeOfAKind
    FullHouse
    FourOfAKind
    FiveOfAKind
}

class Hand : IComparable[object] {
    [string]
    $Hand

    [HandType]
    $HandType

    [int]
    $Rank

    [int]
    $Bid

    [string]
    $Cards

    [int[]]
    $Values

    [long]
    $Winnings

    static [Hashtable] $Map = @{
        'J' = 1
        '2' = 2
        '3' = 3
        '4' = 4
        '5' = 5
        '6' = 6
        '7' = 7
        '8' = 8
        '9' = 9
        'T' = 10
        'Q' = 11
        'K' = 12
        'A' = 13
    }

    Hand(
        [string] $hand
    ) {
        $this.Cards, $this.Bid = $hand -split '\s+'
        $this.Hand = $this.Cards

        $this.SortCards()
        $this.GetValues()

        $this.HandType = switch -Regex ($this.Cards) {
            '(.)\1{4}'                    { 'FiveOfAKind'; break }
            '(.)\1{3}'                    { 'FourOfAKind'; break }
            '(.)\1{2}(.)\2|(.)\3(.)\4{2}' { 'FullHouse'; break }
            '(.)\1{2}'                    { 'ThreeOfAKind'; break }
            '(.)\1.*(.)\2'                { 'TwoPair'; break }
            '(.)\1'                       { 'OnePair'; break }
            default                       { 'HighCard' }
        }
        $this.TryUpgradeHand()
    }

    [void] SortCards() {
        $this.Cards = -join ([string[]][char[]]$this.Cards | Sort-Object { [Hand]::Map[$_] })
    }

    [void] GetValues() {
        $this.Values = foreach ($card in [string[]][char[]]$this.Hand) {
            [Hand]::Map[$card]
        }
    }

    [void] TryUpgradeHand() {
        if ($this.Cards -notmatch 'J') {
            return
        }

        switch ($this.HandType) {
            'FourOfAKind' {
                $this.HandType = 'FiveOfAKind'
                break
            }
            'FullHouse' {
                $this.HandType = 'FiveOfAKind'
                break
            }
            'ThreeOfAKind' {
                $this.HandType = 'FourOfAKind'
                break
            }
            'TwoPair' {
                if ($this.Cards -match 'JJ') {
                    $this.HandType = 'FourOfAKind'
                } else {
                    $this.HandType = 'FullHouse'
                }
                break
            }
            'OnePair' {
                $this.HandType = 'ThreeOfAKind'
                break
            }
            'HighCard' {
                $this.HandType = 'OnePair'
            }
        }
    }

    [int] CompareTo(
        [object] $other
    ) {
        $type = $this.HandType.CompareTo($other.HandType)
        if ($type -ne 0) {
            return $type
        }

        for ($i = 0; $i -lt $this.Values.Count; $i++) {
            $card = $this.Values[$i].CompareTo($other.Values[$i])
            if ($card -ne 0) {
                return $card
            }
        }

        return 0
    }
}

$totalWinnings = 0
$set = [List[Hand]][SortedSet[Hand]][File]::ReadAllLines("$PSScriptRoot\input.txt")
for ($i = 0; $i -lt $set.Count; $i++) {
    $hand = $set[$i]

    $hand.Rank = $i + 1
    $hand.Winnings = $hand.Rank * $hand.Bid
    $totalWinnings += $hand.Winnings
}
$totalWinnings
