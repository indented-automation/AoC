$memory = (gc $PSScriptRoot\input.txt -raw) -split ',' -as [int[]]

function GetArg {
    param ( $num )

    if ($num -eq 3 -or $mode -in 3, 4) {
        return $instruction[$num]
    }

    $mode = $opString[-2 - $num]
    $value = $instruction[$num]
    if ($mode -eq '1') {
        return $value
    }
    return $memory[$value]
}

function Add {
    $memory[$instruction[3]] = (GetArg 1) + (GetArg 2)

}

function Multiply {
    $memory[$instruction[3]] = (GetArg 1) * (GetArg 2)
}

function GetInput {
    $value = [int](Read-Host "Input")
    $memory[$instruction[1]] = $value
}

function WriteOutput {
    Write-Host $memory[$instruction[1]] -ForegroundColor Cyan
}

$i = 0
do {
    $opString = $memory[$i] -as [string]
    $opCode = (-join $opString[-2,-1]) -as [int]

    if ($opCode -eq 99) {
        break
    }

    [PSCustomObject]@{
        Address     = $i
        Length      = $length = @(2, 4)[$opCode -in 1, 2]
        Instruction = $instruction = $memory[$i..($i + $length - 1)]
        OpCode      = $opCode
    }

    switch ($OpCode) {
        1 { Add }
        2 { Multiply }
        3 { GetInput }
        4 { WriteOutput }
    }

    $i += $length
} while ($i -lt $memory.Count)
