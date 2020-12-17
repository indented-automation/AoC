function GetPermutation {
    param (
        [int[]]$Values,
        [int]$Length = $Values.Count,
        [int[]]$Permutation = @(),
        [System.Collections.Generic.HashSet[string]]$Unique = [System.Collections.Generic.HashSet[string]]::new()
    )

    if ($Permutation.Count -lt $Length) {
        foreach ($value in $Values) {
            $params = @{
                Values      = $Values
                Permutation = @(
                    $Permutation
                    $value
                )
                Length      = $Length
                Unique      = $Unique
            }
            GetPermutation @params
        }
    } else {
        if ($Unique.Add("$Permutation")) {
            ,$Permutation
        }
    }
}

$middle = 15
$maximum = $middle * 2

$directions = GetPermutation -Values -1, 0, 1 -Length 4 | Where-Object { "$_" -ne '0 0 0 0' }
$dimension = [char[,,,]]::new($maximum, $maximum, $maximum, $maximum)

$x = $y = $z = $h = $middle
Get-Content $pwd\input.txt | ForEach-Object {
    for ($x = $middle; $x -lt $middle + $_.Length; $x++) {
        if ($_[$x - $middle] -eq '#') {
            $dimension[$x,$y,$z,$h] = '#'
        } else {
            $dimension[$x,$y,$z,$h] = '.'
        }
    }
    $y++
}

for ($iteration = 0; $iteration -lt 6; $iteration++) {
    $currentState = $dimension.Clone()

    for ($x = 0; $x -le $maximum; $x++) {
        for ($y = 0; $y -le $maximum; $y++) {
            for ($z = 0; $z -le $maximum; $z++) {
                for ($h = 0; $h -le $maximum; $h++) {
                    $isActive = $dimension[$x,$y,$z,$h] -eq '#'

                    $activeNeighbours = 0
                    foreach ($direction in $directions) {
                        $neighbour = $dimension[
                            ($x + $direction[0]),
                            ($y + $direction[1]),
                            ($z + $direction[2]),
                            ($h + $direction[3])
                        ]
                        if ($neighbour -eq '#') {
                            $activeNeighbours++
                        }
                    }

                    if ($isActive -and $activeNeighbours -notin 2, 3) {
                        $currentState[$x,$y,$z,$h] = '.'
                    }

                    if (-not $isActive -and $activeNeighbours -eq 3) {
                        $currentState[$x,$y,$z,$h] = '#'
                    }
                }
            }
        }
    }

    $dimension = $currentState
}

$dimension | Where-Object { $_ -eq '#' } | Measure-Object
