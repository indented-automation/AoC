$json = Get-Content input.txt -Raw | ConvertFrom-Json

$queue = [Queue[object]]::new()
$queue.Enqueue($json)

$sum = 0
:queue
do {
    $item = $queue.Dequeue() | Write-Output

    if ($item -is [Array]) {
        foreach ($element in $item) {
            $queue.Enqueue($element)
        }
        continue
    }

    if ($item -is [string]) {
        continue
    }

    if ($item -match '^-?\d+$') {
        $sum += $item
        continue
    }

    $toQueue = foreach ($property in $item.PSObject.Properties) {
        if ($property.Value -isnot [Array] -and 'red' -eq $property.Value) {
            continue queue
        }
        $property
    }

    foreach ($property in $toQueue) {
        $queue.Enqueue($property.Value)
    }
} while ($queue.Count)
$sum
