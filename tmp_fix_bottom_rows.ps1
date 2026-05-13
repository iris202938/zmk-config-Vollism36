$path = 'c:\Users\iris2\github\zmk-config-Vollism36\boards\shields\Vollism36\Vollism36.keymap'
$lines = Get-Content -LiteralPath $path -Encoding UTF8
$changed = @()

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if (-not $line.Trim()) { continue }
    if ($line.TrimStart().StartsWith('//')) { continue }
    $comment = ''
    $content = $line
    if ($line -match '^(.*?)(\s*//.*)$') {
        $content = $Matches[1]
        $comment = $Matches[2]
    }
    $leading = ($content -replace '^(\s*).*$', '$1')
    $contentPart = $content.TrimEnd()
    $cells = ($contentPart.Trim() -split '\s{2,}')
    $cells = $cells | Where-Object { $_ -ne '' }
    if ($cells.Count -ne 6) { continue }
    if (($cells | ForEach-Object { $_.Trim().StartsWith('&') }) -contains $false) { continue }
    $permuted = @($cells[1], $cells[2], $cells[0], $cells[5], $cells[3], $cells[4])
    if ($cells -join '|' -eq $permuted -join '|') { continue }
    if ($comment -ne '') { $newLine = $leading + ($permuted -join '   ') + ' ' + $comment } else { $newLine = $leading + ($permuted -join '   ') }
    $lines[$i] = $newLine
    $changed += [PSCustomObject]@{ Line = $i + 1; Old = $contentPart.Trim(); New = $permuted -join '   ' }
}

if ($changed.Count -gt 0) {
    $lines | Set-Content -LiteralPath $path -Encoding UTF8
    Write-Host "Updated $($changed.Count) lines."
    foreach ($c in $changed) {
        Write-Host "$($c.Line): $($c.Old) => $($c.New)"
    }
} else {
    Write-Host 'No changes needed.'
}
