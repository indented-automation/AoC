using module .\IntCode.psm1
Invoke-Pester -Output Detailed

$intCode = [IntCode]::Init((gc $pwd\input.txt | Select -first 1))
$intCode.AddInputValue(1)
$intCode.StartDebug()
# $intCode.GetOutput()
