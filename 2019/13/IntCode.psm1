using namespace System.Collections.Generic

enum OpCode {
    Add                = 1
    Multiply           = 2
    GetInput           = 3
    WriteOutput        = 4
    JumpIfTrue         = 5
    JumpIfFalse        = 6
    LessThan           = 7
    Equals             = 8
    AdjustRelativeBase = 9
    Complete           = 99
}

enum ArgumentMode {
    Position
    Immediate
    Relative
}

enum OutputMode {
    Stop
    StopOnCount
    Continue
}

class Operation {
    [OpCode]         $OpCode
    [long]           $Instruction
    [ArgumentMode[]] $argumentModes
    [long[]]         $InstructionParameters

    hidden [IntCode] $intCode
    hidden [long]    $argument = 0

    Operation(
        $instruction,
        $intCode
    ) {
        $this.intCode = $intCode

        if ($this.argumentCount -gt 0) {
            $modes = $instruction.ToString('00000').Substring(0, 3) -split '' -ne '' -as [ArgumentMode[]]
            [Array]::Reverse($modes)
            $this.argumentModes = $modes[0..($this.argumentCount - 1)]
        }

        $this.Instruction = $instruction
        $this.InstructionParameters = $this.intCode.Peek($this.argumentCount)
    }

    [long] GetValue() {
        return $this.GetValue($false)
    }

    [long] GetValue(
        [bool] $isWriteRequest
    ) {
        $value = $this.intCode.Read()
        $mode = $this.argumentModes[$this.argument++]

        if ($isWriteRequest -and $mode -eq 'Position') {
            $mode = 'Immediate'
        }

        $value = switch ($mode) {
            'Position'  {
                $this.intCode.Read($value)
            }
            'Immediate' {
                $value
            }
            'Relative' {
                if ($isWriteRequest) {
                    $value + $this.intCode.RelativeBase
                } else {
                    $this.intCode.Read($value + $this.intCode.RelativeBase)
                }
            }
        }

        return $value
    }

    [void] Exec() { }

    static [Operation] Create(
        [long]    $instruction,
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
    hidden [int] $argumentCount = 0

    Complete(
        [long]    $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
    }
}

class Add : Operation {
    [long] $Left
    [long] $Right
    [long] $WriteTo
    [long] $Value
    [int] $argumentCount = 3

    Add(
        [long]    $instruction,
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
        $this.Intcode.Write(
            $this.WriteTo,
            $this.Value
        )
    }
}

class Multiply : Operation {
    [long] $Left
    [long] $Right
    [long] $WriteTo
    [long] $Value

    hidden [int] $argumentCount = 3

    Multiply(
        [long]    $instruction,
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
        $this.Intcode.Write(
            $this.WriteTo,
            $this.Value
        )
    }
}

class GetInput : Operation {
    [long] $Value
    [long] $WriteTo

    hidden [int] $argumentCount = 1

    GetInput(
        [long]    $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.WriteTo = $this.GetValue($true)
        $this.Value = $intCode.InputQueue.Dequeue()
    }

    [void] Exec() {
        $this.Intcode.Write(
            $this.WriteTo,
            $this.Value
        )
    }
}

class WriteOutput : Operation {
    [long] $Value

    hidden [int] $argumentCount = 1

    WriteOutput(
        [long]    $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.Value = $this.GetValue()
    }

    [void] Exec() {
        $this.intCode.Output.Add($this.Value)
    }
}

class JumpIfTrue : Operation {
    [bool] $ShouldJump
    [long] $ToPosition

    hidden [int] $argumentCount = 2

    JumpIfTrue(
        [long]    $instruction,
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
    [long] $ToPosition

    hidden [int] $argumentCount = 2

    JumpIfFalse(
        [long]    $instruction,
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
    [long] $Left
    [long] $Right
    [long] $WriteTo
    [bool] $Value

    hidden [int] $argumentCount = 3

    LessThan(
        [long]    $instruction,
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
        $this.Intcode.Write(
            $this.WriteTo,
            $this.Value
        )
    }
}

class Equals : Operation {
    [long] $Left
    [long] $Right
    [long] $WriteTo
    [bool] $Value

    hidden [int] $argumentCount = 3

    Equals(
        [long]    $instruction,
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
        $this.Intcode.Write(
            $this.WriteTo,
            $this.Value
        )
    }
}

class AdjustRelativeBase : Operation {
    [long] $RelativeBase

    hidden [int] $argumentCount = 1

    AdjustRelativeBase(
        [long]    $instruction,
        [IntCode] $intCode
    ) : base(
        $instruction,
        $intCode
    ) {
        $this.RelativeBase = $this.GetValue()
    }

    [void] Exec() {
        $this.IntCode.RelativeBase += $this.RelativeBase
    }
}

class IntCode {
    [List[long]]  $Memory
    [long]        $StreamPosition
    [Queue[long]] $InputQueue        = [Queue[long]]::new()
    [List[long]]  $Output            = [List[long]]::new()
    [OpCode]      $LastOpCode
    [long]        $RelativeBase      = 0
    [OutputMode]  $OutputMode        = 'Continue'
    [int]         $ExpectOutputCount = 1
    [bool]        $IsComplete        = $false

    [IntCode] static Init(
        [string] $initialState
    ) {
        $instance = [IntCode]::new()
        $instance.Memory = $initialState -split ',' -as [long[]]
        $instance.StreamPosition = 0

        return $instance
    }

    [void] Start() {
        while ($true) {
            $operation = [Operation]::Create(
                $this.Read(),
                $this
            )
            $this.LastOpCode = $operation.OpCode

            $operation.Exec()

            if ($operation.OpCode -eq 'Complete') {
                $this.IsComplete = $true
                break
            }
            if ($operation.OpCode -eq 'WriteOutput' -and $this.OutputMode -eq 'Stop') {
                break
            }
            if ($operation.OpCode -eq 'WriteOutput' -and $this.OutputMode -eq 'StopOnCount') {
                if ($this.Output.Count -eq $this.ExpectOutputCount) {
                    break
                }
            }
        }
    }

    [Operation[]] StartDebug() {
        $instruction = 0
        $operations = while ($true) {
            try {
                $instruction = $this.Read()
                $operation = [Operation]::Create(
                    $instruction,
                    $this
                )
                $this.LastOpCode = $operation.OpCode
                $operation

                $operation.Exec()

                if ($operation.OpCode -eq 'Complete') {
                    $this.IsComplete = $true
                    break
                }
                if ($operation.OpCode -eq 'WriteOutput' -and $this.OutputMode -eq 'Stop') {
                    break
                }
                if ($operation.OpCode -eq 'WriteOutput' -and $this.OutputMode -eq 'StopOnCount') {
                    if ($this.Output.Count -eq $this.ExpectOutputCount) {
                        break
                    }
                }
            } catch {
                Write-Host "Failed at $instruction" -ForegroundColor Red
                break
            }
        }

        return $operations
    }

    [void] AddInputValue(
        [IEnumerable[long]] $values
    ) {
        foreach ($value in $values) {
            $this.AddInputValue($value)
        }
    }

    [void] AddInputValue(
        [long] $value
    ) {
        $this.InputQueue.Enqueue($value)
    }

    [void] ClearOutput() {
        $this.Output.Clear()
    }

    [long[]] GetOutput() {
        return $this.Output.ToArray()
    }

    [long[]] Peek(
        [int] $length
    ) {
        return $this.Memory[$this.StreamPosition..($this.StreamPosition + $length - 1)]
    }

    [long] Read() {
        return $this.Memory[$this.StreamPosition++]
    }

    [long] Read(
        [long] $position
    ) {
        if ($position -ge $this.Memory.Count) {
            $this.Resize($position)
        }
        return $this.Memory[$position]
    }

    [void] Resize(
        [long] $position
    ) {
        $size = $position + 1
        $resizedMemory = [long[]]::new($size)
        [Array]::Copy($this.Memory, $resizedMemory, $this.Memory.Count)
        $this.Memory = $resizedMemory
    }

    [void] Seek(
        [long] $position
    ) {
        if ($position -ge $this.Memory.Count) {
            $this.Resize($position)
        }
        $this.StreamPosition = $position
    }

    [void] Write(
        [long] $position,
        [long] $value
    ) {
        if ($position -ge $this.Memory.Count) {
            $this.Resize($position)
        }
        $this.Memory[$position] = $value
    }
}
