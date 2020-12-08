using module .\IntCode.psm1

$intCode = [IntCode]::Init((gc $pwd\input.txt | Select -first 1))
$intCode.AddInputValue(2)
$intCode.Start()
$intCode.Output
