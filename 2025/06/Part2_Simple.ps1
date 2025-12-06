using namespace System.IO

[CmdletBinding()]
param (
    [switch]
    $Sample
)

$fileName = 'input.txt'
if ($Sample) {
    $fileName = 'sample.txt'
}

$data = [File]::ReadAllLines([Path]::Combine($PSScriptRoot, $fileName))

$sum = 0l
$rows = @()
for ($i = 0; $i -lt $data[0].Length; $i++) {
    $characters = for ($j = 0; $j -lt $data.Count; $j++) {
        $data[$j][$i]
    }
    $row = [string]::new($characters)
    $rows += $row
    if (!$row.Trim()) {
        $operator = -join $rows -replace '[\r\n\d\s]'
        $values = $rows -split '\s+' -replace '[+*]' -match '\d'
        $result = $operator -eq '+' ? 0l : 1l
        foreach ($value in $values) {
            $null = $operator -eq '+' ? ($result += $value) : ($result *= $value)
        }
        $rows = @()
        $sum += $result
    }
}

# Last column
$operator = -join $rows -replace '[\r\n\d\s]'
$values = $rows -split '\s+' -replace '[+*]' -match '\d'
$result = $operator -eq '+' ? 0l : 1l
foreach ($value in $values) {
    $null = $operator -eq '+' ? ($result += $value) : ($result *= $value)
}
$rows = @()

$sum += $result
$sum