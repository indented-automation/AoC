function GetArg {
    param (
        [int]$num
    )

    if ($num -eq 3) {
        return $positionnstruction[$num]
    }

    $mode = $opString[-2 - $num]
    $value = $positionnstruction[$num]
    if ($mode -eq '1') {
        return $value
    }
    return $memory[$value]
}

function Add {
    $memory[(GetArg 3)] = (GetArg 1) + (GetArg 2)

}

function Multiply {
    $memory[(GetArg 3)] = (GetArg 1) * (GetArg 2)
}

function GetInput {
    $memory[$positionnstruction[1]] = $inputQueue.Dequeue()
}

function WriteOutput {
    $value = GetArg 1
    if ($EnqueueOutput) {
        $inputQueue.Enqueue($value)
    } else {
        $value
    }
}

function JumpIfTrue {
    if (GetArg 1) {
        $Script:position = (GetArg 2) - 3
    }
}

function JumpIfFalse {
    if ((GetArg 1) -eq 0) {
        $Script:position = (GetArg 2) - 3
    }
}

function LessThan {
    $memory[$positionnstruction[3]] = (GetArg 1) -lt (GetArg 2) -as [int]
}

function Equals {
    $memory[$positionnstruction[3]] = (GetArg 1) -eq (GetArg 2) -as [int]
}

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

function StartIntcode {
    param (
        [int[]]$InputValues,
        [switch]$EnqueueOutput
    )

    $inputQueue = [System.Collections.Generic.Queue[int]]$InputValues
    $memory = (gc $pwd\input.txt | select -first 1) -split ',' -as [int[]]

    $Script:position = 0
    do {
        $opString = $memory[$position] -as [string]
        $opCode = (-join $opString[-2,-1]) -as [int]

        if ($opCode -eq 99) {
            break
        }

        [PSCustomObject]@{
            Address     = $position
            Length      = $length = switch ($opCode) {
                { $_ -in 1, 2, 7, 8 } { 4 }
                { $_ -in 3, 4 }       { 2 }
                { $_ -in 5, 6 }       { 3 }

            }
            Instruction = $positionnstruction = $memory[$position..($position + $length - 1)]
            OpCode      = $opCode
        } | Format-Table | Out-String | Write-Debug

        switch ($OpCode) {
            1       { Add }
            2       { Multiply }
            3       { GetInput }
            4       { WriteOutput }
            5       { JumpIfTrue }
            6       { JumpIfFalse }
            7       { LessThan }
            8       { Equals }
            default { throw "Unexpected code: $opCode" }
        }

        $Script:position += $length
    } while ($position -lt $memory.Count)

    $inputQueue
}

$output = $null
$highestInputSignal = 0
GetPermutation -Values (5..9) -Length 5 | ForEach-Object {
    $inputSignal = 0
    $state = 'OK'

    for ($i = 0; $i -lt $_.Count; $i++) {
        $inputSignal = StartIntcode -InputValues $_[$i], $inputSignal -EnqueueOutput
    }

    [PSCustomObject]@{
        Code        = -join $_
        InputSignal = $inputSignal
        State       = $state
    }

    if ($inputSignal -gt $highestInputSignal) {
        $highestInputSignal = $inputSignal

        $output = [PSCustomObject]@{
            Code        = -join $_
            InputSignal = $inputSignal
        }
    }
}
$output
