using namespace System.Collections.Generic

enum OpCode {
    Add         = 1
    Multiply    = 2
    GetInput    = 3
    WriteOutput = 4
    JumpIfTrue  = 5
    JumpIfFalse = 6
    LessThan    = 7
    Equals      = 8
    Complete    = 99
}

enum ArgumentMode {
    Position
    Immediate
}

class Argument {
    [ArgumentMode] $Mode
    [int]          $Value
}

class Operation {
    [OpCode] $OpCode

    [ArgumentMode[]] $argumentModes

    hidden [IntCode] $intCode
    hidden [int]     $argument = 0

    Operation(
        $instruction,
        $intCode
    ) {
        $this.intCode = $intCode
        $modes = $instruction.ToString('00000').Substring(0, 3) -split '' -ne '' -as [ArgumentMode[]]
        [Array]::Reverse($modes)
        $this.argumentModes = $modes

        ($instruction -as [string] -as [char[]])[-2..-4]
    }

    [int] GetValue() {
        return $this.GetValue($false)
    }

    [int] GetValue(
        [bool] $forceImmediate
    ) {
        $value = $this.intCode.ReadInt()
        $mode = $this.argumentModes[$this.argument++]

        if ($forceImmediate) {
            return $value
        }

        $value = switch ($mode) {
            'Position'  {
                $this.intCode.Memory[$value]
            }
            'Immediate' {
                $value
            }
        }

        return $value
    }

    [void] Exec() { }

    static [Operation] Create(
        [int]     $instruction,
        [IntCode] $intCode
    ) {
        $code = $instruction.ToString('00000').Substring(3) -as [OpCode]
        $instance = ($code -as [string] -as [Type])::new(
            $instruction,
            $intCode
        )
        $instance.OpCode = $code

        return $instance
    }
}

class Complete : Operation {
    Complete(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) { }
}

class Add : Operation {
    [int] $Left
    [int] $Right
    [int] $WriteTo
    [int] $Value

    Add(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.Left = $this.GetValue()
        $this.Right = $this.GetValue()
        $this.WriteTo = $this.GetValue($true)
        $this.Value = $this.Left + $this.Right
    }

    [void] Exec() {
        $this.Intcode.WriteInt(
            $this.WriteTo,
            $this.Value
        )
    }
}

class Multiply : Operation {
    [int] $Left
    [int] $Right
    [int] $WriteTo
    [int] $Value

    Multiply(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.Left = $this.GetValue()
        $this.Right = $this.GetValue()
        $this.WriteTo = $this.GetValue($true)
        $this.Value = $this.Left * $this.Right
    }

    [void] Exec() {
        $this.Intcode.WriteInt(
            $this.WriteTo,
            $this.Value
        )
    }
}

class GetInput : Operation {
    [int] $Value
    [int] $WriteTo

    GetInput(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.WriteTo = $this.GetValue($true)
        $this.Value = $intCode.InputQueue.Dequeue()
    }

    [void] Exec() {
        $this.Intcode.WriteInt(
            $this.WriteTo,
            $this.Value
        )
    }
}

class WriteOutput : Operation {
    [int] $Value

    WriteOutput(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.Value = $this.GetValue()
    }

    [void] Exec() {
        $this.intCode.Output = $this.Value
    }
}

class JumpIfTrue : Operation {
    [bool] $ShouldJump
    [int]  $ToPosition

    JumpIfTrue(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.ShouldJump = $this.GetValue()
        $this.ToPosition = $this.GetValue()
    }

    [void] Exec() {
        if ($this.ShouldJump) {
            $this.intCode.Seek($this.ToPosition)
        }
    }
}

class JumpIfFalse : Operation {
    [bool] $ShouldJump
    [int]  $ToPosition

    JumpIfFalse(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.ShouldJump = -not $this.GetValue()
        $this.ToPosition = $this.GetValue()
    }

    [void] Exec() {
        if ($this.ShouldJump) {
            $this.intCode.Seek($this.ToPosition)
        }
    }
}

class LessThan : Operation {
    [int]  $Left
    [int]  $Right
    [int]  $WriteTo
    [bool] $Value

    LessThan(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.Left = $this.GetValue()
        $this.Right = $this.GetValue()
        $this.WriteTo = $this.GetValue($true)
        $this.Value = $this.Left -lt $this.Right
    }

    [void] Exec() {
        $this.Intcode.WriteInt(
            $this.WriteTo,
            $this.Value
        )
    }
}

class Equals : Operation {
    [int]  $Left
    [int]  $Right
    [int]  $WriteTo
    [bool] $Value

    Equals(
        [int]     $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.Left = $this.GetValue()
        $this.Right = $this.GetValue()
        $this.WriteTo = $this.GetValue($true)
        $this.Value = $this.Left -eq $this.Right
    }

    [void] Exec() {
        $this.Intcode.WriteInt(
            $this.WriteTo,
            $this.Value
        )
    }
}

class IntCode {
    [List[int]]  $Memory
    [int]        $StreamPosition
    [Queue[int]] $InputQueue = [Queue[int]]::new()
    [int]        $Output
    [OpCode]     $LastOpCode

    [IntCode] static Init(
        [string] $initialState
    ) {
        $instance = [IntCode]::new()
        $instance.Memory = $initialState -split ',' -as [int[]]
        $instance.StreamPosition = 0

        return $instance
    }

    [void] Start() {
        while ($true) {
            $operation = [Operation]::Create(
                $this.ReadInt(),
                $this
            )
            $this.LastOpCode = $operation.OpCode

            $operation.Exec()

            if ($operation.OpCode -in 'Complete', 'WriteOutput') {
                break
            }
        }
    }

    [void] AddInputValue(
        [int] $value
    ) {
        $this.InputQueue.Enqueue($value)
    }

    [int] ReadInt() {
        return $this.Memory[$this.StreamPosition++]
    }

    [void] Seek(
        [int] $position
    ) {
        $this.StreamPosition = $position
    }

    [void] WriteInt(
        [int] $position,
        [int] $value
    ) {
        $this.Memory[$position] = $value
    }
}
