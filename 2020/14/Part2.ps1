function GetPermutation {
    param (
        [string[]]$Values,
        [int]$Length,
        [string]$Permutation = '',
        [System.Collections.Generic.HashSet[string]]$Unique = [System.Collections.Generic.HashSet[string]]::new()
    )

    if ($Permutation.Length -lt $Length) {
        foreach ($value in $Values) {
            $params = @{
                Values      = $Values
                Permutation = $Permutation + $value
                Length      = $Length
                Unique      = $Unique
            }
            GetPermutation @params
        }
    } else {
        if ($Unique.Add($Permutation)) {
            $Permutation
        }
    }
}

$Memory = @{}
Get-Content $PSScriptRoot\input.txt | ForEach-Object {
    if ($_ -match '^mask = (?<mask>.+)$') {
        $mask = $matches['mask']
        $length = ($mask -replace '[^X]').Length

        $masks = foreach ($permutation in GetPermutation -Values 0, 1 -Length $length) {
            $thisMask = [PSCustomObject]@{
                OnesMask  = $mask
                ZerosMask = $mask -replace '0', '1'
            }

            for ($i = 0; $i -lt $length; $i++) {
                $index = $thisMask.OnesMask.IndexOf('X')

                $thisMask.OnesMask = $thisMask.OnesMask.Remove($index, 1).Insert($index, $permutation[$i])
                $thisMask.ZerosMask = $thisMask.ZerosMask.Remove($index, 1).Insert($index, $permutation[$i])
            }

            $thisMask.OnesMask = [Convert]::ToUInt64($thisMask.OnesMask.PadLeft(64, '1'), 2)
            $thisMask.ZerosMask = [Convert]::ToUInt64($thisMask.ZerosMask, 2)

            $thisMask
        }
    }

    if ($_ -match '^mem\[(?<address>\d+)\] = (?<value>\d+)') {
        [long]$address, [long]$value = $matches['address'], $matches['value']

        foreach ($mask in $masks) {
            $thisAddress = $address -bor $mask.OnesMask
            $thisAddress = $thisAddress -band $mask.ZerosMask
            $thisAddress = $thisAddress -band 0x0000000FFFFFFFFF

            $Memory[$thisAddress] = $value
        }
    }
}
$Memory.Values | Measure-Object -Sum
