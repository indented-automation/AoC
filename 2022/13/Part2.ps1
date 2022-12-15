class Packet : IComparable {
    [object[]] $Value

    Packet([int] $value) {
        $this.Value = $value
    }

    Packet([string] $packet) {
        $stream = [System.IO.StringReader]$packet
        if ($stream.Peek() -as [char] -eq '[') {
            $stream.Read()
        }
        $this.Parse($stream)
    }

    Packet([System.IO.StringReader] $stream) {
        $this.Parse($stream)
    }

    [void] Parse([System.IO.StringReader] $stream) {
        $this.Value = do {
            $char = $stream.Read() -as [char] -as [string]
            if ($char -eq ',') { continue }

            if ($char -eq '[') {
                [Packet]::new($stream)
                continue
            }

            $parsedValue = 0
            if ([int]::TryParse($char, [ref]$parsedValue)) {
                if ($parsedValue -eq 1 -and $stream.Peek() -as [char] -eq '0') {
                    $null = $stream.Read()
                    $parsedValue = 10
                }
                $parsedValue
            }
        } until ($char -eq ']')
        if (-not $this.Value.Count) {
            $this.Value = @()
        }
    }

    [int] CompareTo([object] $packet) {
        if ($packet -is [int]) {
            return $this.CompareTo([Packet]::new($packet))
        }

        if ($this.Value -is [Packet] -and $packet.Value -is [Packet]) {
            return $this.Value.CompareTo($packet.Value)
        }

        if ($this.Value -is [int] -and $packet.Value -is [int]) {
            return $this.Value.CompareTo($packet.Value)
        }

        if ($this.Value -is [array] -and $packet.Value -is [array]) {
            $min = [Math]::Min($this.Value.Count, $packet.Value.Count)
            for ($i = 0; $i -lt $min; $i++) {
                $left = $this.Value[$i]
                $right = $packet.Value[$i]

                if ($left -is [int] -and $right -is [int]) {
                    $compare = $left.CompareTo($right)
                    if ($compare -ne 0) {
                        return $compare
                    }
                    continue
                }

                if ($left -is [Packet]) {
                    $compare = $left.CompareTo($right)
                    if ($compare -ne 0) {
                        return $compare
                    }
                    continue
                }
                if ($left -is [int]) {
                    $compare = [Packet]::new($left).CompareTo($right)
                    if ($compare -ne 0) {
                        return $compare
                    }
                    continue
                }
            }

            return $this.Value.Count.CompareTo($packet.Value.Count)
        }

        if ($this.Value -is [int]) {
            return [Packet]::new($this.Value).CompareTo($packet)
        }
        if ($packet.Value -is [int]) {
            return $this.CompareTo([Packet]::new($packet.Value))
        }

        return 0
    }

    [string] ToString() {
        return '[{0}]' -f ($this.Value -join ',')
    }
}

[Packet[]]@(
    '[[2]]'
    '[[6]]'
    [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt") | Where-Object Length
) | Sort-Object | ForEach-Object -Begin {
    $key = $index = 1
} -Process {
    if ($_ -in '[[2]]', '[[6]]') {
        $key *= $index
    }

    $index++
} -End {
    $key
}
