$Memory = @{}
Get-Content $PSScriptRoot\input.txt | ForEach-Object {
    if ($_ -match '^mask = (?<mask>.+)$') {
        $mask = $matches['mask']
        $1sMask = [Convert]::ToUInt64(($mask.PadLeft(64, '1') -replace 'X', '0'), 2)
        $0sMask = [Convert]::ToUInt64(($mask.PadLeft(64, '0') -replace 'X', '1'), 2)
    }
    if ($_ -match '^mem\[(?<address>\d+)\] = (?<value>\d+)') {
        [ulong]$address, [ulong]$value = $matches['address'], $matches['value']

        $value = $value -bor $1sMask
        $value = $value -band $0sMask
        $value = $value -band 0x0000000FFFFFFFFF

        $Memory[$address] = $value
    }
}

$Memory.Values | Measure-Object -Sum
