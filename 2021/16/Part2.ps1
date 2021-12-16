class Packet {
    [string]   $Name
    [byte]     $Version
    [byte]     $TypeID
    [int]      $Length
    [Packet[]] $Packets
    [int64]    $Value

    [int] $AtPosition
    [int] $AtBit

    Packet(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) {
        $this.Name = $this.GetType().Name
        $this.Version = $version
        $this.TypeID = $typeID
        $this.Length = 6

        $this.AtPosition = $bitReader.Position
        $this.AtBit = $bitReader.BitPosition - 6
        if ($this.AtBit -lt 0) {
            $this.AtPosition--
            $this.AtBit = 8 + $this.AtBit
        }
    }

    static [Packet] Read($bitReader) {
        $packetVersion = $bitReader.ReadBits(3)
        $packetTypeID = $bitReader.ReadBits(3)

        if ($bitReader.Position -ge $bitReader.stream.Count) {
            return $null
        }

        $type = switch ($packetTypeID) {
            0 { [SumOperator] }
            1 { [ProductOperator] }
            2 { [MinimumOperator] }
            3 { [MaximumOperator] }
            4 { [LiteralValue] }
            5 { [GreaterThanOperator] }
            6 { [LessThanOperator] }
            7 { [EqualToOperator] }
        }
        $packet = $type::new($packetVersion, $packetTypeID, $bitReader)

        return $packet
    }
}

class LiteralValue : Packet {
    LiteralValue(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.ReadLiteral($bitReader)
    }

    [void] ReadLiteral($bitReader) {
        $fragments = do {
            $fragment = $bitReader.ReadBits(5)
            $this.Length += 5
            $fragment -band 0b01111
        } while (($fragment -band 0b10000) -eq 0b10000)

        for ($i = 0; $i -lt $fragments.Count; $i++) {
            $shift = 4 * ($fragments.Count - $i - 1)
            $this.Value = [uint64]$this.Value -bor ([uint64]$fragments[$i] -shl $shift)
        }
    }

    [string] ToString() {
        return $this.Value.ToString()
    }
}

class Operator : Packet {
    [ValidateSet('Length', 'Count')]
    [string] $Mode

    [int] $TotalLength
    [int] $SubPacketCount

    Operator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $modeToggle = $bitReader.ReadBits(1)
        if ($modeToggle -eq 0) {
            $this.Mode = 'Length'
        } else {
            $this.Mode = 'Count'
        }
        $this.Length += 1

        if ($this.Mode -eq 'Length') {
            $this.GetByLength($bitReader)
        } else {
            $this.GetByCount($bitReader)
        }
    }

    [void] GetByLength($bitReader) {
        $this.TotalLength = $bitReader.ReadBits(15)
        $this.Length += 15

        $remaining = $this.TotalLength
        $this.Packets = do {
            $packet = [Packet]::Read($bitReader)
            $packet

            $remaining -= $packet.Length
            $this.Length += $packet.Length
        } while ($remaining -gt 0)
    }

    [void] GetByCount($bitReader) {
        $this.SubPacketCount = $bitReader.ReadBits(11)
        $this.Length += 11

        $this.Packets = for ($i = 1; $i -le $this.SubPacketCount; $i++) {
            $packet = [Packet]::Read($bitReader)
            $packet

            $this.Length += $packet.Length
        }
    }
}

class SumOperator : Operator {
    SumOperator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.Value = 0
        foreach ($packet in $this.Packets) {
            $this.Value += $packet.Value
        }
    }
}

class ProductOperator : Operator {
    ProductOperator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.Value = 1
        foreach ($packet in $this.Packets) {
            $this.Value *= $packet.Value
        }
    }
}

class MinimumOperator : Operator {
    MinimumOperator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.Value = ($this.Packets.Value | Measure-Object -Minimum).Minimum
    }
}

class MaximumOperator : Operator {
    MaximumOperator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.Value = ($this.Packets.Value | Measure-Object -Maximum).Maximum
    }
}

class GreaterThanOperator : Operator {
    GreaterThanOperator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.Value = $this.Packets[0].Value -gt $this.Packets[1].Value
    }
}

class LessThanOperator : Operator {
    LessThanOperator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.Value = $this.Packets[0].Value -lt $this.Packets[1].Value
    }
}

class EqualToOperator : Operator {
    EqualToOperator(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base(
        $version,
        $typeID,
        $bitReader
    ) {
        $this.Value = $this.Packets[0].Value -eq $this.Packets[1].Value
    }
}

class BitReader {
    [System.Collections.Generic.List[byte]] $stream
    [int] $position = 0
    [int] $bitPosition = 0

    BitReader([string]$hex) {
        $this.stream = $hex -split '(?<=\G.{2})' -match '[a-z0-9]' -replace '^', '0x' -as [byte[]]
    }

    [byte] ReadByte() {
        return $this.stream[$this.position++]
    }

    [ushort] ReadBits([int] $bits) {
        $value = 0
        if ($this.bitPosition + $bits -gt 8) {
            $remaining = $bits

            if ($this.bitPosition + $remaining -gt 8) {
                $bitsToRead = 8 - $this.bitPosition
                $value = $this.ReadBits($bitsToRead) -shl ($remaining - $bitsToRead)
                $remaining -= $bitsToRead
            }

            while ($remaining) {
                if ($remaining -gt 8) {
                    $bitsToRead = 8
                    $remaining -= 8
                    $value = ($this.ReadBits(8) -shl $remaining) -bor $value
                } else {
                    $value = $this.ReadBits($remaining) -bor $value
                    $remaining = 0
                }
            }

            return $value
        }

        $shift = 8 - ($this.bitPosition + $bits)
        $mask = '0b{0}{1}' -f @(
            '1' * $bits
            '0' * $shift
        )
        $value = $this.ReadByte()

        $value = ($value -band $mask) -shr $shift

        $this.bitPosition += $bits
        if ($this.bitPosition -lt 8) {
            $this.position--
        } else {
            $this.bitPosition -= 8
        }

        return $value
    }
}

$bitReader = [BitReader]::new((Get-Content "$PSScriptRoot\input.txt" -Raw))

[Packet]::Read($bitReader).Value

