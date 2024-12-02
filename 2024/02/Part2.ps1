using namespace System.Collections.Generic

function Test-Safe {
    param (
        [int[]]
        $Levels
    )

    $report = [PSCustomObject]@{
        Levels          = $Levels -join ' '
        Direction       = ''
        Problems        = 0
        ProblemPosition = @()
        Safe            = $true
        String          = @("$($levels[0])")
    }

    $position = [HashSet[int]]::new()

    for ($i = 1; $i -lt $Levels.Count; $i++) {
        $a, $b = $Levels[($i - 1), $i]
        $change = $b - $a

        $direction = if ($change -gt 0) {
            'Increment'
         } elseif ($change -lt 0) {
            'Decrement'
         }

        $isUnsafe = $change -eq 0 -or $change -gt 3 -or $change -lt -3 -or
            ($report.Direction -and $direction -ne $report.Direction)

        if ($isUnsafe) {
            $report.Problems++
            $null = $position.Add($i - 1)
            $null = $position.Add($i)
        }

        if (-not $report.Direction) {
            $report.Direction = $direction
        }

        $report.String += "    $change {0}" -f ($isUnsafe ? '*' : '')
        $report.String += "$b"
    }

    $report.ProblemPosition = $position | Write-Output

    if ($report.Problems) {
        $report.Safe = $false
    }

    $report.String += '{0}: {1}' -f $report.Levels, ($report.Safe ? 'Safe' : 'Unsafe')

    $report
}

$reports = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")

$count = 0

foreach ($reportString in $reports) {
    $levels = -split $reportString -as [int[]]

    $report = Test-Safe -Level $levels

    if ($report.Problems -eq 1 -and
        (
            $report.ProblemPosition -eq 0 -or
            $report.ProblemPosition -eq $levels.Count - 1
        )
    ) {
        $report.Safe = $true
    } elseif ($report.Problems -eq $levels.Count - 2) {
        $fixedLevels = $levels | Select-Object -Index $report.ProblemPosition
        $report = Test-Safe -Levels $fixedLevels

        # This is getting really dirty. I had to read through all 1000 of my examples to find these
        # two tiny cases I don't account for.
        if (-not $report.Safe) {
            foreach ($position in $report.ProblemPosition) {
                $fixedLevels = $levels | Select-Object -SkipIndex $position
                $report = Test-Safe -Levels $fixedLevels

                if ($report.Safe) {
                    break
                }
            }
        }
    } elseif (
        $report.Problems -gt 0 -and (
            $report.Problems -eq 1 -or
            ($report.Problems -eq 2 -and $report.ProblemPosition[1] - $report.ProblemPosition[0] -eq 1)
        )
    ) {
        foreach ($position in $report.ProblemPosition) {
            $fixedLevels = $levels | Select-Object -SkipIndex $position
            $report = Test-Safe -Levels $fixedLevels

            if ($report.Safe) {
                break
            }
        }
    }

    if ($report.Safe) {
        $count++
    }
}
$count