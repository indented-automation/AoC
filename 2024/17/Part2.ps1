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
    static [long] $A
    static [long] $B
    static [long] $C
}

class Operand {
    [long]
    $Value

    Operand([long] $value) {
        $this.Value = $value
    }

    [string] ToString() {
        return $this.Value
    }
}

class LiteralOperand : Operand {
    LiteralOperand([long] $value) : base($value) {}
}

class ComboOperand : Operand {
    ComboOperand([long] $value) : base($value) {
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
    $Output

    [OpCode]
    $OpCode

    hidden [bool] $_movePointer = $true

    [int[]] Run() {
        $this.Pointer = 0
        $this.Output = [List[int]]::new()

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
        $expected = $matches[1]

    }
}

function Invoke-ComputerWithA {
    param (
        [Parameter(Mandatory)]
        [long]
        $a
    )

    [Register]::A = $a
    [Register]::B = 0
    [Register]::C = 0

    $computer.Run()
}

# The length of the program increases based on some power of 8.
# To get a program of length 16 out, A needs a value between 8^15 and 8^16 - 1.
# That's still an absurdly large range: 246,290,604,621,824
$min = [Math]::Pow(8, 15)
# The first value in the array increases with every iteration, 8^0
# The second with every 8 iterations, 8^1.
# The third with everty 64, 8^2.
# And so on.

# Play the rate of change backwards and try and find the point where all elements match.
$minimums = $min
for ($power = 15; $power -ge 0; $power--) {
    $interval = [Math]::Pow(8, $power)

    $minimums = foreach ($min in $minimums) {
        for ($i = 0; $i -lt 8; $i++) {
            $a = $min + ($interval * $i)

            $output = Invoke-ComputerWithA -a $a
            if ($output[$power] -eq $computer.Program[$power]) {
                $a
            }
        }
    }
}
$minimums[0]