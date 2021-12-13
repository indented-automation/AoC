$directions = Get-Content "$PSScriptRoot\input.txt"

$x = $y = 0
$visited = @{ "$x,$y" = 1 }
switch (@($null; [char[]]$directions)) {
    { $true } { $visited["$x,$y"]++ }
    '^' { $y-- }
    'v' { $y++ }
    '>' { $x++ }
    '<' { $x-- }
}
$visited.Count
