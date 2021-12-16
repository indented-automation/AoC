class Packet {
    [byte]     $Version
    [byte]     $TypeID
    [int]      $Length
    [Packet[]] $Packets

    Packet(
        [byte] $version,
        [byte] $typeID
    ) {
        $this.Version = $version
        $this.TypeID = $typeID
        $this.Length = 6
    }

    static [Packet] Read($bitReader) {
        $packetVersion = $bitReader.ReadBits(3)
        $packetTypeID = $bitReader.ReadBits(3)

        if ($bitReader.Position -ge $bitReader.stream.Count) {
            return $null
        }

        if ($packetTypeID -eq 4) {
            $packet = [LiteralValue]::new($packetVersion, $packetTypeID, $bitReader)
        } else {
            $packet = [Operator]::new($packetVersion, $packetTypeID, $bitReader)
        }

        $Script:allPackets.Add($packet)

        return $packet
    }
}

class LiteralValue : Packet {
    [uint64] $Value

    LiteralValue(
        [byte] $version,
        [byte] $typeID,
        $bitReader
    ) : base($version, $typeID) {
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
            $this.Value = $this.Value -bor ($fragments[$i] -shl $shift)
        }
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
    ) : base($version, $typeID) {
        $modeToggle = $bitReader.ReadBits(1)
        if ($modeToggle -eq 0) {
            $this.Mode = 'Length'
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
                $value = $this.ReadBits($bitsToRead)
                $value = $value -shl ($remaining - $bitsToRead)

                $remaining -= $bitsToRead
            }

            while ($remaining) {
                if ($remaining -gt 8) {
                    $bitsToRead = 8
                    $remaining -= 8
                    $value = ($this.ReadBits(8) -shl $remaining) -bor $value
                } else {
                    $read = $this.ReadBits($remaining)
                    $value = $read -bor $value
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
        $value = ($this.ReadByte() -band $mask) -shr $shift

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

$allPackets = [System.Collections.Generic.List[Packet]]::new()

[Packet]::Read($bitReader) | Out-Null

($allPackets.Version | Measure-Object -Sum).Sum
