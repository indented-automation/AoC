$from = @{}
$to = @{}
$defaultFrom = @{}
$defaultTo = @{}

foreach ($entry in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    if ($entry -match '^seeds: (.*)') {
        $seeds = -split $matches[1] -as [long[]]
        continue
    }

    if ($entry -match '^(\S+)-to-(\S+) map:') {
        $fromName, $toName = $matches[1, 2]
        $defaultFrom[$fromName] = $toName
        $defaultTo[$toName] = $fromName
        continue
    }

    if ($entry -match '^(\d+)\s+(\d+)\s+(\d+)') {
        $record = @{
            From        = $fromName
            To          = $toName
            Destination = @{
                Start = [long]$matches[1]
                End   = [long]$matches[1] + [long]$matches[3]
            }
            Source      = @{
                Start = [long]$matches[2]
                End   = [long]$matches[2] + [long]$matches[3]
            }
            Length      = [long]$matches[3]
        }
        $from[$fromName] += @($record)
        $to[$toName] += @($record)
    }
}

$low = [int]::MaxValue
foreach ($seed in $seeds) {
    $fromName = 'seed'
    $value = $seed

    :search
    while ($true) {
        $toName = $defaultFrom[$fromName]

        if (-not $toName) {
            break
        }

        foreach ($record in $from[$fromName]) {
            if ($value -ge $record['Source']['Start'] -and $value -le $record['Source']['End']) {
                $value = $value - $record['Source']['Start'] + $record['Destination']['Start']
                $fromName = $record['To']
                continue search
            }
        }

        $fromName = $defaultFrom[$fromName]
    }

    if ($value -lt $low) {
        $low = $value
    }
}

$low
