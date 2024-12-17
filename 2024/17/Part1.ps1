using namespace System.Collections.Generic

enum OpCode {
    adv = 0
    bxl = 1
    bst = 2
    jnz = 3
    bxc = 4
    out = 5
    bdv = 6
    cdv = 7
}

class Register {
    static [int] $A
    static [int] $B
    static [int] $C
}

class Operand {
    [int]
    $Value

    Operand([int] $value) {
        $this.Value = $value
    }

    [string] ToString() {
        return $this.Value
    }
}

class LiteralOperand : Operand {
    LiteralOperand([int] $value) : base($value) {}
}

class ComboOperand : Operand {
    ComboOperand([int] $value) : base($value) {
        $this.Value = switch ($value) {
            { $_ -ge 0 -and $_ -le 3 } { $_; break }
            4 { [Register]::A; break }
            5 { [Register]::B; break }
            6 { [Register]::C; break }
            7 {
                throw 'Reserved'
            }
            default {
                throw 'Unexpected'
            }
        }
    }
}

class Computer {
    [int[]]
    $Program

    [int]
    $Pointer

    [List[int]]
    $Output = [List[int]]::new()

    [OpCode]
    $OpCode

    hidden [bool] $_movePointer = $true

    [int[]] Run() {
        while ($this.Pointer -lt $this.Program.Count) {
            $this.RunInstruction()
        }

        return $this.Output
    }

    [void] RunInstruction() {
        $this.OpCode, $operand = $this.Program[$this.Pointer, ($this.Pointer + 1)]
        $this.($this.OpCode)($operand)

        if ($this._movePointer) {
            $this.Pointer += 2
        }
        $this._movePointer = $true
    }

    [void] adv([ComboOperand] $operand) {
        [Register]::A = [Math]::Floor(
            [Register]::A / [Math]::Pow(2, $operand.Value)
        )
    }

    [void] bxl([LiteralOperand] $operand) {
        [Register]::B = [Register]::B -bxor $operand.Value
    }

    [void] bst([ComboOperand] $operand) {
        [Register]::B = $operand.Value % 8
    }

    [void] jnz([LiteralOperand] $operand) {
        if ([Register]::A -eq 0) {
            return
        }

        $this.Pointer = $operand.Value
        $this._movePointer = $false
    }

    [void] bxc([LiteralOperand] $operand) {
        [Register]::B = [Register]::B -bxor [Register]::C
    }

    [void] out([ComboOperand] $operand) {
        $this.Output.Add($operand.Value % 8)
    }

    [void] bdv([ComboOperand] $operand) {
        [Register]::B = [Math]::Floor(
            [Register]::A / [Math]::Pow(2, $operand.Value)
        )
    }

    [void] cdv([ComboOperand] $operand) {
        [Register]::C = [Math]::Floor(
            [Register]::A / [Math]::Pow(2, $operand.Value)
        )
    }
}

$computer = [Computer]::new()

foreach ($line in [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")) {
    if ($line -match 'Register (.): (\d+)') {
        [Register]::($matches[1]) = $matches[2]
    }
    if ($line -match 'Program: (.+)') {
        $computer.Program = $matches[1] -split ','
    }
}

$computer.Run() -join ','