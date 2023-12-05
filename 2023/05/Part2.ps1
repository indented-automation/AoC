$from = @{}
$to = @{}
$defaultFrom = @{}
$defaultTo = @{}

$toPlace = [System.Collections.Generic.Queue[object]]::new()

foreach ($entry in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    if ($entry -match '^seeds: (.*)') {
        $values = -split $matches[1] -as [long[]]
        for ($i = 0; $i -lt $values.Count; $i += 2) {
            $toPlace.Enqueue(
                @{
                    From   = 'seed'
                    Start  = $values[$i]
                    End    = $values[$i] + $values[$i + 1]
                    Length = $values[$i + 1]
                }
            )
        }
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
            Offset      = [long]$matches[2] - [long]$matches[1]
            Length      = [long]$matches[3]
        }
        $from[$fromName] += @($record)
        $to[$toName] += @($record)
    }
}

$low = [int]::MaxValue
while ($toPlace.Count) {
    $value = $toPlace.Dequeue()

    $fromName = $value['From']
    $toName = $defaultFrom[$fromName]

    if (-not $toName) {
        if ($value['Start'] -lt $low) {
            $low = $value['Start']
        }
        continue
    }

    :search
    do {
        $split = $false
        foreach ($record in $from[$fromName]) {
            if ($value['Start'] -ge $record['Source']['Start'] -and $value['End'] -le $record['Source']['End']) {
                $toPlace.Enqueue(
                    @{
                        From  = $record['To']
                        Start = $value['Start'] - $record['Offset']
                        End   = $value['End'] - $record['Offset']
                    }
                )
                $value = $null
                break search
            }

            if ($value['Start'] -ge $record['Source']['Start'] -and $value['Start'] -le $record['Source']['End']) {
                $toPlace.Enqueue(
                    @{
                        From  = $record['To']
                        Start = $value['Start'] - $record['Offset']
                        End   = $record['Source']['End'] - $record['Offset']
                    }
                )

                $value['Start'] = $record['Source']['End'] + 1
                $split = $true
            } elseif ($value['End'] -ge $record['Source']['Start'] -and $value['End'] -le $record['Source']['End']) {
                $toPlace.Enqueue(
                    @{
                        From  = $record['To']
                        Start = $record['Source']['Start'] - $record['Offset']
                        End   = $value['End'] - $record['Offset']
                    }
                )

                $value['End'] = $record['Source']['Start'] - 1
                $split = $true
            }
        }
    } while ($split)

    if ($value) {
        $toPlace.Enqueue(
            @{
                From  = $toName
                Start = $value['Start']
                End   = $value['End']
            }
        )
    }
}

$low
