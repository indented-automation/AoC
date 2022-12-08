class Tree {
    [int] $x
    [int] $y
    [int] $Size
    [bool] $IsVisible
    [int] $Score

    [int] $HighestN
    [int] $HighestS
    [int] $HighestE
    [int] $HighestW

    [bool] $VisibleN
    [bool] $VisibleS
    [bool] $VisibleE
    [bool] $VisibleW

    static [int] $Max

    Tree([int]$x, [int]$y, [char]$size) {
        $this.x = $x
        $this.y = $y
        $this.Size = [int]::Parse($size)
        $this.IsVisible = $x -in 0, [Tree]::Max -or $y -in 0, [Tree]::Max
    }
}

function Move-Cursor {
    param (
        $x,
        $y
    )

    if (-not $Script:Show) {
        return
    }

    [Console]::SetCursorPosition(
        ($x + 2),
        ($y + 2)
    )
}

function Update-Tree {
    param (
        [Tree]$Tree
    )

    if (-not $Script:Show) {
        return
    }

    Move-Cursor -x $Tree.x -y $Tree.y

    $colour = $PSStyle.Foreground.White
    if ($Tree.IsVisible) {
        $colour = $PSStyle.Foreground.Green
    }
    [Console]::Write("$colour$($Tree.Size)")
}

$data = [System.IO.File]::ReadAllLines("$PSScriptRoot\input.txt")
$grid = [Tree[,]]::new($data.Count, $data.Count)

[Tree]::Max = $max = $data.Count - 1

$visibleCount = 0

for ($y = 0; $y -le $max; $y++) {
    for ($x = 0; $x -le $max; $x++) {
        $grid[$x,$y] = $tree = [Tree]::new($x, $y, $data[$y][$x])
        # Update-Tree $tree
        if ($tree.IsVisible) {
            $visibleCount++
        }
    }
}

# North

for ($y = 1; $y -le $max - 1; $y++) {
    for ($x = 1; $x -lt $max; $x++) {
        $tree = $grid[$x,$y]
        $neighbour = $grid[$x,($y - 1)]

        $tree.HighestN = [Math]::Max(
            $neighbour.Size,
            $neighbour.HighestN
        )

        if ($tree.Size -gt $tree.HighestN) {
            $tree.IsVisible = $tree.VisibleN = $true
            # Update-Tree -Tree $tree
            $visibleCount++
        } else {
            $tree.VisibleN = $false
        }
    }
}

# South

for ($y = $max - 1; $y -ge 1; $y--) {
    for ($x = 1; $x -lt $max; $x++) {
        $tree = $grid[$x,$y]
        $neighbour = $grid[$x,($y + 1)]

        $tree.HighestS = [Math]::Max(
            $neighbour.Size,
            $neighbour.HighestS
        )

        if ($tree.IsVisible) {
            continue
        }
        if ($tree.Size -gt $tree.HighestS) {
            $tree.IsVisible = $tree.VisibleS = $true
            # Update-Tree -Tree $tree
            $visibleCount++
        } else {
            $tree.VisibleS = $false
        }
    }
}

# East

for ($y = 1; $y -le $max - 1; $y++) {
    for ($x = $max - 1; $x -ge 1; $x--) {
        $tree = $grid[$x,$y]
        $neighbour = $grid[($x + 1),$y]

        $tree.HighestE = [Math]::Max(
            $neighbour.Size,
            $neighbour.HighestE
        )

        if ($tree.IsVisible) {
            continue
        }
        if ($tree.Size -gt $tree.HighestE) {
            $tree.IsVisible = $tree.VisibleE = $true
            # Update-Tree -Tree $tree
            $visibleCount++
        } else {
            $tree.VisibleE = $false
        }
    }
}

# West

for ($y = 1; $y -le $max - 1; $y++) {
    for ($x = 1; $x -lt $max; $x++) {
        $tree = $grid[$x,$y]
        $neighbour = $grid[($x - 1),$y]

        $tree.HighestW = [Math]::Max(
            $neighbour.Size,
            $neighbour.HighestW
        )

        if ($tree.IsVisible) {
            continue
        }
        if ($tree.Size -gt $tree.HighestW) {
            $tree.IsVisible = $tree.VisibleW = $true
            # Update-Tree -Tree $tree
            $visibleCount++
        } else {
            $tree.VisibleW = $false
        }
    }
}

# Move-Cursor -y ($max + 5)
# Write-Host "Visible trees: $VisibleCount" -ForegroundColor White
$VisibleCount
