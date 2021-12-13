$secretKey = 'iwrupvqb'

$md5 = [System.Security.Cryptography.MD5]::Create()
for ($i = 0;;$i++) {
    $hash = $md5.ComputeHash([byte[]][char[]]"$secretKey$i")

    if (-not ($hash[0..2] -gt 0)) {
        $i
        break
    }
}
