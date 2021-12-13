$secretKey = 'iwrupvqb'

$md5 = [System.Security.Cryptography.MD5]::Create()
for ($i = 0;;$i++) {
    $hash = $md5.ComputeHash([byte[]][char[]]"$secretKey$i")

    if ($hash[0] -eq 0 -and $hash[1] -eq 0 -and $hash[2] -lt 16) {
        $i
        break
    }
}
