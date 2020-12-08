using module .\IntCode.psm1

$intCode = [IntCode]::Init((gc $pwd\input.txt | Select -first 1))
$intCode.AddInputValue(1)
$intCode.Start()
$intCode.Output
