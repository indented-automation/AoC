Describe IntCode {
    Context 'Stream' {
        BeforeEach {
            $computer = [IntCode]::Init('1,0,0,0,99')
        }

        It 'Read' {
            $computer.Read() | Should -Be 1
            $computer.StreamPosition | Should -Be 1

            $computer.Read() | Should -Be 0
            $computer.StreamPosition | Should -Be 2
        }

        It 'Write' {
            $computer.Write(1, 10)
            $computer.Memory[1] | Should -Be 10
        }

        It 'Seek' {
            $computer.Read()
            $computer.Read()
            $computer.StreamPosition | Should -Be 2
            $computer.Seek(1)
            $computer.StreamPosition | Should -Be 1
        }

        It 'AddInputValue' {
            $computer.AddInputValue(1)
            $computer.InputQueue | Should -Be 1
        }
    }

    Context 'Operations, Position mode' {
        It 'Add' {
            $computer = [IntCode]::Init('1,2,3,5,99,0')
            $add = [Operation]::Create(
                $computer.Read(),
                $computer
            )
            $add.Left | Should -Be 3
            $add.Right | Should -Be 5
            $add.Value | Should -Be 8
        }

        It 'Multiply' {
            $computer = [IntCode]::Init('2,2,3,5,99,0')
            $multiply = [Operation]::Create(
                $computer.Read(),
                $computer
            )
            $multiply.Left | Should -Be 3
            $multiply.Right | Should -Be 5
            $multiply.Value | Should -Be 15
        }
    }

    Context 'Operations, Immediate mode' {
        It 'Add' {
            $computer = [IntCode]::Init('11101,2,3,5,99,0')
            $add = [Operation]::Create(
                $computer.Read(),
                $computer
            )
            $add.Left | Should -Be 2
            $add.Right | Should -Be 3
            $add.Value | Should -Be 5
        }

        It 'Multiply' {
            $computer = [IntCode]::Init('11102,2,3,5,99,0')
            $multiply = [Operation]::Create(
                $computer.Read(),
                $computer
            )
            $multiply.Left | Should -Be 2
            $multiply.Right | Should -Be 3
            $multiply.Value | Should -Be 6
        }
    }

    Context 'Programs' {
        It 'Add: <Program>' -TestCases @(
            @{ Program = '1,0,0,0,99'; Position = 0; ExpectedValue = 2 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.Start()
            $computer.Memory[$Position] | Should -Be $ExpectedValue
        }

        It 'Multiply: <Program>' -TestCases @(
            @{ Program = '2,3,0,3,99';   Position = 3; ExpectedValue = 6 }
            @{ Program = '2,4,4,5,99,0'; Position = 5; ExpectedValue = 9801 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.Start()
            $computer.Memory[$Position] | Should -Be $ExpectedValue
        }

        It 'Multiply and Add: <Program>' -TestCases @(
            @{ Program = '1,1,1,4,99,5,6,0,99'; Position = 0; ExpectedValue = 30 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.Start()
            $computer.Memory[$Position] | Should -Be $ExpectedValue
        }

        It 'Equal: <Program>: With <Value> returns <ExpectedValue>' -TestCases @(
            @{ Program = '3,9,8,9,10,9,4,9,99,-1,8'; Value = 1;  ExpectedValue = 0 }
            @{ Program = '3,9,8,9,10,9,4,9,99,-1,8'; Value = 8;  ExpectedValue = 1 }
            @{ Program = '3,9,8,9,10,9,4,9,99,-1,8'; Value = 10; ExpectedValue = 0 }
            @{ Program = '3,3,1108,-1,8,3,4,3,99';   Value = 1;  ExpectedValue = 0 }
            @{ Program = '3,3,1108,-1,8,3,4,3,99';   Value = 8;  ExpectedValue = 1 }
            @{ Program = '3,3,1108,-1,8,3,4,3,99';   Value = 10; ExpectedValue = 0 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.AddInputValue($Value)
            $computer.Start()
            $computer.Output | Should -Be $ExpectedValue
        }

        It 'LessThan: <Program>: With <Value> returns <ExpectedValue>' -TestCases @(
            @{ Program = '3,9,7,9,10,9,4,9,99,-1,8'; Value = 1;  ExpectedValue = 1 }
            @{ Program = '3,9,7,9,10,9,4,9,99,-1,8'; Value = 8;  ExpectedValue = 0 }
            @{ Program = '3,9,7,9,10,9,4,9,99,-1,8'; Value = 10; ExpectedValue = 0 }
            @{ Program = '3,3,1107,-1,8,3,4,3,99';   Value = 1;  ExpectedValue = 1 }
            @{ Program = '3,3,1107,-1,8,3,4,3,99';   Value = 8;  ExpectedValue = 0 }
            @{ Program = '3,3,1107,-1,8,3,4,3,99';   Value = 10; ExpectedValue = 0 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.AddInputValue($Value)
            $computer.Start()
            $computer.Output | Should -Be $ExpectedValue
        }

        It 'Jump: <Program>: With <Value> returns <ExpectedValue>' -TestCases @(
            @{ Program = '3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9'; Value = 0;  ExpectedValue = 0 }
            @{ Program = '3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9'; Value = 1;  ExpectedValue = 1 }
            @{ Program = '3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9'; Value = 10; ExpectedValue = 1 }
            @{ Program = '3,3,1105,-1,9,1101,0,0,12,4,12,99,1';      Value = 0;  ExpectedValue = 0 }
            @{ Program = '3,3,1105,-1,9,1101,0,0,12,4,12,99,1';      Value = 1;  ExpectedValue = 1 }
            @{ Program = '3,3,1105,-1,9,1101,0,0,12,4,12,99,1';      Value = 10; ExpectedValue = 1 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.AddInputValue($Value)
            $computer.Start()
            $computer.Output | Should -Be $ExpectedValue
        }

        It 'Combined: <Program>: With <Value> returns <ExpectedValue>' -TestCases @(
            @{
                Program       = '3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99'
                Value         = 7
                ExpectedValue = 999
            }
            @{
                Program       = '3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99'
                Value         = 8
                ExpectedValue = 1000
            }
            @{
                Program       = '3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99'
                Value         = 9
                ExpectedValue = 1001
            }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.AddInputValue($Value)
            $computer.Start()
            $computer.Output | Should -Be $ExpectedValue
        }

        It 'Highest value: <Program>: With <Value> returns <ExpectedValue>' -TestCases @(
            @{
                Program        = '3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0'
                Values         = 4, 3, 2, 1, 0
                ExpectedValue  = 43210
            }
            @{
                Program        = '3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0'
                Values         = 0,1,2,3,4
                ExpectedValue  = 54321
            }
            @{
                Program        = '3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0'
                Values         = 1, 0, 4, 3, 2
                ExpectedValue  = 65210
            }
        ) {
            $computers= for ($i = 0; $i -lt $Values.Count; $i++) {
                $computer = [IntCode]::Init($Program)
                $computer.AddInputValue($Values[$i])
                $computer
            }

            $output = 0
            foreach ($computer in $computers) {
                $computer.AddInputValue($output)
                $computer.Start()

                $output = $computer.Output
            }

            $output | Should -Be $ExpectedValue
        }

        It 'Highest recursive value: <Program>: With <Values> returns <ExpectedValue>' -TestCases @(
            @{
                Program        = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5'
                Values         = 9, 8, 7, 6, 5
                ExpectedValue  = 139629729
            }
            @{
                Program        = '3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10'
                Values         = 9, 7, 8, 5, 6
                ExpectedValue  = 18216
            }
        ) {
            $computers = for ($i = 0; $i -lt $Values.Count; $i++) {
                $computer = [IntCode]::Init($Program)
                $computer.AddInputValue($Values[$i])
                $computer.OutputMode = 'Stop'
                $computer
            }

            $output = 0
            do {
                foreach ($computer in $computers) {
                    $computer.ClearOutput()
                    $computer.AddInputValue($output)
                    $computer.Start()

                    $iterationOutput = $computer.GetOutput()
                    if ($iterationOutput) {
                        $output = $iterationOutput
                    }
                }
            } until ($computer.LastOpCode -eq 'Complete')

            $output | Should -Be $ExpectedValue
        }

        It 'Relative: <Program>: Returns <ExpectedValue>' -TestCases @(
            @{
                Program        = '109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99'
                ExpectedValue  = '109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99' -split ',' -as [long[]]
            }
            @{
                Program        = '1102,34915192,34915192,7,4,7,99,0'
                ExpectedValue  = 1219070632396864
            }
            @{
                Program        = '104,1125899906842624,99'
                ExpectedValue  = 1125899906842624
            }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.Start()
            $computer.GetOutput() | Should -Be $ExpectedValue
        }
    }

    Context 'External tests' {
        It 'External: <Program>: Returns <ExpectedValue>' -TestCases @(
            @{ Program = '109,-1,4,1,99';            ExpectedValue = -1 }
            @{ Program = '109,-1,104,1,99';          ExpectedValue = 1 }
            @{ Program = '109,-1,204,1,99';          ExpectedValue = 109 }
            @{ Program = '109,1,9,2,204,-6,99';      ExpectedValue = 204 }
            @{ Program = '109,1,109,9,204,-6,99';    ExpectedValue = 204 }
            @{ Program = '109,1,209,-1,204,-106,99'; ExpectedValue = 204 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.Start()
            $computer.GetOutput() | Should -Be $ExpectedValue
        }

        It 'External: <Program> with <Value>: Returns <ExpectedValue>' -TestCases @(
            @{ Program = '109,1,3,3,204,2,99';   Value = 5; ExpectedValue = 5 }
            @{ Program = '109,1,203,2,204,2,99'; Value = 5; ExpectedValue = 5 }
        ) {
            $computer = [IntCode]::Init($Program)
            $computer.AddInputValue($Value)
            $computer.Start()
            $computer.GetOutput() | Should -Be $ExpectedValue
        }
    }

}
