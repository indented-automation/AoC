function Explode {
    [CmdletBinding()]
    param (
        [string]$String,

        [int]$Position
    )

    $Script:hasUpdated = $true

    $explodeExpression = $String.Substring($Position)
    $explodeExpression = $explodeExpression.Substring(0, $explodeExpression.IndexOf(']') + 1)

    $explode = $explodeExpression.Substring(1, $explodeExpression.Length - 2) -split ','

    $left = GetNumber -String $String -Start $Position -SearchDirection 'Left'
    $right = GetNumber -String $String -Start ($Position + $explodeExpression.Length) -SearchDirection 'Right'

    if ($right) {
        $String = $String.Remove(
            $right.Position,
            $right.Length
        ).Insert(
            $right.Position,
            $right.Value + $explode[1]
        )
    }

    $String = $String.Remove(
        $Position,
        $explodeExpression.Length
    ).Insert(
        $Position,
        '0'
    )

    if ($left) {
        $String = $String.Remove(
            $left.Position,
            $left.Length
        ).Insert(
            $left.Position,
            $left.Value + $explode[0]
        )
    }

    $String
}

function Split {
    [CmdletBinding()]
    param (
        [string]$String,

        [int]$Position
    )

    $match = [Regex]::Match($String, '\d{2}')[0]

    if ($match.Success) {
        $Script:hasUpdated = $true

        $value = '[{0},{1}]' -f @(
            [Math]::Floor([int]$match.Value / 2)
            [Math]::Ceiling([int]$match.Value / 2)
        )

        $String.Remove(
            $match.Index,
            $match.Length
        ).Insert(
            $match.Index,
            $value
        )
    } else {
        $String
    }
}

function GetNumber {
    [CmdletBinding()]
    param (
        [string]$String,

        [int]$Start,

        [string]$SearchDirection
    )

    if ($SearchDirection -eq 'Left') {
        $leftPart = $String.Substring(0, $Start)
        $match = [Regex]::Match($leftPart, '\d+', 'RightToLeft')[0]
    } else {
        $rightPart = $String.Substring($Start)
        $match = [Regex]::Match($rightPart, '\d+')[0]
    }

    if ($match.Success) {
        if ($SearchDirection -eq 'Right') {
            $index = $match.Index + $Start
        } else {
            $index = $match.Index
        }

        [PSCustomObject]@{
            Direction = $SearchDirection
            Value     = $match.Value -as [int]
            Position  = $index
            Length    = $match.Length
        }
    }
}

function Reduce {
    [CmdletBinding()]
    param (
        [string]$String
    )

    do {
        $Script:hasUpdated = $false

        $open = $position = 0
        foreach ($char in [char[]]$String) {
            if ($char -eq '[') {
                $open++
            }
            if ($char -eq ']') {
                $open--
            }
            if ($open -eq 5) {
                $String = Explode -String $String -Position $position
                break
            }
            $position++
        }

        if (-not $Script:hasUpdated) {
            $String = Split -String $String
        }
    } while ($Script:hasUpdated)

    $String
}

function GetMagnitude {
    [CmdletBinding()]
    param (
        [string]$String
    )

    do {
        $gettingMagnitude = $false
        foreach ($match in [Regex]::Matches($String, '\[(\d+),(\d+)\]') | Sort-Object -Descending Index)  {
            $gettingMagnitude = $true

            $left = $match.Groups[1].Value -as [int]
            $right = $match.Groups[2].Value -as [int]

            $value = 3 * $left + 2 * $right

            $String = $String.Remove(
                $match.Index,
                $match.Length
            ).Insert(
                $match.Index,
                $value
            )
        }
    } while ($gettingMagnitude)
    [int]$String
}

$magnitude = 0
$values = Get-Content "$PSScriptRoot\input.txt"
foreach ($firstValue in $values) {
    foreach ($secondValue in $values) {
        if ($firstValue -ne $secondValue) {
            $string = '[{0},{1}]' -f $firstValue, $secondValue
            $string = Reduce -String $string

            $value = GetMagnitude $string
            if ($value -gt $magnitude) {
                $magnitude = $value
            }
        }
    }
}
$magnitude
