param (
    [switch]
    $Show
)

class Ingredient {
    [string]
    $Name

    [long]
    $Capacity

    [long]
    $Durability

    [long]
    $Flavor

    [long]
    $Texture

    [long]
    $Calories

    [long]
    $Teaspoons = 0

    Ingredient(
        [string] $record
    ) {
        $values = $record -split '[:,]\s'
        $this.Name = $values[0]
        for ($i = 1; $i -lt $values.Count; $i++) {
            $n, $v = $values[$i] -split '\s'
            $this.$n = $v
        }
    }
}

class Cookie {
    [long]
    $Capacity

    [long]
    $Durability

    [long]
    $Flavor

    [long]
    $Texture

    [long]
    $Calories

    [long]
    $Score = 1

    Cookie(
        [Ingredient[]] $ingredients
    ) {
        foreach ($ingredient in $ingredients) {
            if (-not $ingredient.Teaspoons) {
                continue
            }

            foreach ($property in 'Capacity', 'Durability', 'Flavor', 'Texture') {
                $this.$property += $ingredient.$property * $ingredient.Teaspoons
            }
        }

        foreach ($property in 'Capacity', 'Durability', 'Flavor', 'Texture') {
            if ($this.$property -lt 0) {
                $this.$property = 0
            }
            $this.Score *= $this.$property
        }
    }
}

$max = 100

$ingredients = [Ingredient[]][System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$combinations = for ($a = 0; $a -le $max; $a++) {
    for ($b = 0; $b -le $max - $a; $b++) {
        for ($c = 0; $c -le $max - $a - $b; $c++) {
            $d = 100 - $a - $b - $c
            if ($d -lt 0) {
                continue
            }

            ,@($d, $c, $b, $a)
        }
    }
}

$score = 0
foreach ($combination in $combinations) {
    for ($i = 0; $i -lt $combination.Count; $i++) {
        $ingredients[$i].Teaspoons = $combination[$i]
    }

    $cookie = [Cookie]::new($ingredients)
    if ($cookie.Score -gt $score) {
        $score = $cookie.Score
    }
}
$score
