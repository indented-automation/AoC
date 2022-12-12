$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$reactions = @{}
foreach ($reaction in $data) {
    $in, $out = $reaction -split '\s=>\s'

    $inputChemicals = foreach ($chemical in $in -split ',\s') {
        [int]$quantity, $chemical = $chemical -split '\s'
        [PSCustomObject]@{
            Name     = $chemical
            Quantity = $quantity
        }
    }

    [int]$quantity, $out = $out -split '\s'
    $reactions[$out] = [PSCustomObject]@{
        Name           = $out
        Input          = $inputChemicals
        OutputQuantity = $quantity
        Produced       = 0
        Stored         = 0
    }
}

$productionQueue = [System.Collections.Generic.Queue[object]]::new()
$productionQueue.Enqueue(
    @{
        Name     = 'FUEL'
        Required = 1
    }
)

$ore = 0
while ($productionQueue.Count) {
    $product = $productionQueue.Dequeue()
    $reaction = $reactions[$product.Name]

    $produced = 0

    if ($reaction.Stored) {
        $produced += $reaction.Stored
        $reaction.Stored = 0
    }

    while ($produced -lt $product.Required) {
        $produced += $reaction.OutputQuantity
        $reaction.Produced += $reaction.OutputQuantity

        foreach ($inputProduct in $reaction.Input) {
            if ($inputProduct.Name -eq 'ORE') {
                $ore += $inputProduct.Quantity
            } else {
                $productionQueue.Enqueue(
                    @{
                        Name     = $inputProduct.Name
                        Required = $inputProduct.Quantity
                    }
                )
            }
        }
    }

    if ($produced -gt $product.Required) {
        $reaction.Stored = $produced - $product.Required
    }
}
$ore
