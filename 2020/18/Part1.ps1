function eval {
    param (
        [string]$Problem
    )

    $problemRegex = '\d+ [*+] \d+'
    do {
        $match = [Regex]::Match($Problem, $problemRegex)
        $result = Invoke-Expression $match.Value
        $Problem = $Problem.Remove($match.Index, $match.Length).Insert($match.Index, $result)
    } while ($Problem -match $problemRegex)

    $Problem
}

$groupRegex = '\((\d+(?: [*+] \d+)+)\)'

gc $PSScriptRoot\input.txt | %{
    $problem = $_
    do {
        [Regex]::Matches($problem, $groupRegex) | Sort-Object Index -Descending | %{
            $result = eval $_.Groups[1]
            $problem = $problem.Remove(
                $_.Index,
                $_.Length
            ).Insert(
                $_.Index,
                $result
            )
        }
    } while ($problem -match $groupRegex)
    $problem = eval $problem

    $problem
} | Measure-Object -Sum
