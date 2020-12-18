function eval {
    param (
        [string]$Problem
    )

    $problemRegex = '\d+ \+ \d+'
    while ($Problem -match $problemRegex) {
        $match = [Regex]::Match($Problem, $problemRegex)
        $result = Invoke-Expression $match.Value
        $Problem = $Problem.Remove($match.Index, $match.Length).Insert($match.Index, $result)

        # Write-Host "Add: $Problem"
    }


    $problemRegex = '\d+ \* \d+'
    while ($Problem -match $problemRegex) {
        $match = [Regex]::Match($Problem, $problemRegex)
        $result = Invoke-Expression $match.Value
        $Problem = $Problem.Remove($match.Index, $match.Length).Insert($match.Index, $result)

        # Write-Host "Multiply: $Problem"
    }

    $Problem
}

$groupRegex = '\((\d+(?: [*+] \d+)+)\)'

gc $PSScriptRoot\input.txt | %{
    $problem = $_

    # Write-Host $problem

    do {
        [Regex]::Matches($problem, $groupRegex) | Sort-Object Index -Descending | %{
            $result = eval $_.Groups[1]

            # Write-Host "Removing $($_.Groups[1]) and Inserting $result"
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
