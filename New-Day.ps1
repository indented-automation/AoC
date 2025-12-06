using namespace System.IO

[CmdletBinding()]
param (
    [string]
    $Day = [DateTime]::Now.Day.ToString('D2'),

    [string]
    $Year = [DateTime]::Now.Year
)

$root = [Path]::Combine($PSScriptRoot, $Year, $Day)
$null = [Directory]::CreateDirectory($root)

foreach ($name in 'Part1.ps1', 'Part2.ps1') {
    Set-Content -Path ([Path]::Combine($root, $name)) -Value @(
        'using namespace System.IO'
        ''
        '[CmdletBinding()]'
        
        'param ('
        '    [switch]'
        '    $Sample'
        ')'
        ''
        '$fileName = ''input.txt'''
        'if ($Sample) {'
        '    $fileName = ''sample.txt'''
        '}'
        ''
        '$data = [File]::ReadAllText([Path]::Combine($PSScriptRoot, $fileName))'
    )
}

foreach ($name in 'input.txt', 'sample.txt') {
    New-Item -Path ([Path]::Combine($root, $name)) -ErrorAction Ignore
}
