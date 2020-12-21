$allAllergens = @{}
$allIngredients = @{}
$matched = @{}

$index = 0
$list = gc $PSScriptRoot\input.txt | ForEach-Object {
    $ingredients, $allergens = $_ -split ' \(' -replace '\)'

    $ingredients = $ingredients -split ' '
    $allergens = $allergens -replace 'contains ' -split ', '

    foreach ($allergen in $allergens) {
        $allAllergens[$allergen] += @($index)
    }
    foreach ($ingredient in $ingredients) {
        if ($allIngredients[$ingredient]) {
            $allIngredients[$ingredient].Count++
        } else {
            $allIngredients[$ingredient] = [PSCustomObject]@{
                Name     = $ingredient
                Count    = 1
                Allergen = ''
            }
        }
    }

    [PSCustomObject]@{
        Index       = ($index++)
        Ingredients = $ingredients -split ' '
        Allergens   = $allergens -replace 'contains ' -split ', '
    }
}

do {
    foreach ($allergen in [string[]]$allAllergens.Keys) {
        $matchedIngredient = $list[$allAllergens[$allergen]].Ingredients |
            Group-Object |
            Where-Object Count -eq $allAllergens[$allergen].Count

        if (@($matchedIngredient).Count -eq 1) {
            $allIngredients[$matchedIngredient.Name].Allergen = $allergen
            $matched[$matchedIngredient.Name] = 1

            $allAllergens.Remove($allergen)
        }
    }
    foreach ($listItem in $list) {
        $listItem.Ingredients = $listItem.Ingredients | Where-Object { -not $matched.Contains($_) }
    }
} until ($allAllergens.Count -eq 0)

($allIngredients.Values | Where-Object Allergen | Sort-Object Allergen).Name -join ','
