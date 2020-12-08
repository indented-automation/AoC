using module .\IntCode.psm1

function GetPermutation {
    param (
        [int[]]$Values,
        [int]$Length,
        [string]$Permutation = ''
    )

    if ($Permutation.Length -lt $Length) {
        foreach ($value in $Values) {
            $params = @{
                Values      = $Values -ne $value
                Permutation = $Permutation + $value
                Length      = $Length
            }
            GetPermutation @params
        }
    } else {
        ,($Permutation -as [char[]] -as [string[]] -as [int[]])
    }
}

$output = $null
$highestSignal = 0

$Program =  Get-Content "$PSScriptRoot\input.txt" | Select-Object -First 1

GetPermutation -Values (5..9) -Length 5 | ForEach-Object {
    $amplifiers = for ($i = 0; $i -lt $_.Count; $i++) {
        $intCode = [IntCode]::Init($Program)
        $intCode.AddInputValue($_[$i])
        $intCode
    }

    $signal = 0
    do {
        foreach ($amplifier in $amplifiers) {
            $amplifier.AddInputValue($signal)
            $amplifier.Start()

            $signal = $amplifier.Output
        }
    } until ($amplifier.LastOpCode -eq 'Complete')

    if ($signal -gt $highestSignal) {
        $highestSignal = $signal

        $output = [PSCustomObject]@{
            Code   = -join $_
            Signal = $signal
        }
    }
}
$output
