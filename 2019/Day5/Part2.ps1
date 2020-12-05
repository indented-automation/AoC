$memory = (gc $PSScriptRoot\input.txt | select -first 1) -split ',' -as [int[]]

function GetArg {
    param ( $num )

    if ($num -eq 3 -or $mode -in 3) {
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
    $memory[$positionnstruction[3]] = (GetArg 1) + (GetArg 2)

}

function Multiply {
    $memory[$positionnstruction[3]] = (GetArg 1) * (GetArg 2)
}

function GetInput {
    $value = [int](Read-Host "Input")
    $memory[$positionnstruction[1]] = $value
}

function WriteOutput {
    Write-Host (GetArg 1) -ForegroundColor Cyan
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

$position = 0
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
    }

    switch ($OpCode) {
        1 { Add }
        2 { Multiply }
        3 { GetInput }
        4 { WriteOutput }
        5 { JumpIfTrue }
        6 { JumpIfFalse }
        7 { LessThan }
        8 { Equals }
    }

    $position += $length
} while ($position -lt $memory.Count)
