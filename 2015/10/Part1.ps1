$data = '1321131112'

$maxIterations = 40
for ($i = 1; $i -le $maxIterations; $i++) {
    $newData = foreach ($match in [Regex]::Matches($data, '(.)(\1)*')) {
        $match.Length
        $match.Value[0]
    }
    $data = -join $newData

    "${i}: $($data.Length)"
}
$data.Length

# $data = '1321131112'

# for ($i = 1; $i -le $maxIterations; $i++) {
#     $key = @{
#         last = ''
#         name = 0
#     }
#     $groups = [System.Linq.Enumerable]::GroupBy(
#         [char[]]$data,
#         [Func[char,int]]{
#             if ($args[0] -ne $key.last) {
#                 $key['name']++
#             }
#             $key['last'] = $args[0]
#             $key['name']
#         }
#     )
#     $newData = foreach ($group in $groups) {
#         $group.Count
#         $group[0]
#     }

#     $data = -join $newData

#     "${i}: $($data.Length)"
# }
# $data.Length
