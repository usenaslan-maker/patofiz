# Prepares the site after schemes.json or t/*.html changed:
# puts the viewer bridge into every scheme and rewrites sw.js with the current file list and a content version.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$utf8 = New-Object Text.UTF8Encoding $false
$read = { param($p) [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }

$data = (& $read "$root\schemes.json") | ConvertFrom-Json
$bridge = & $read "$PSScriptRoot\bridge.html"

$ids = @()
foreach ($s in $data) { foreach ($it in $s.items) { $ids += [string]$it.id } }
$dup = $ids | Group-Object | Where-Object Count -gt 1
if ($dup) { throw "Duplicate scheme id: $($dup.Name -join ', ')" }

foreach ($id in $ids) {
  $p = "$root\t\$id.html"
  if (-not (Test-Path $p)) { throw "Missing file t\$id.html" }
  $t = & $read $p
  if (-not $t.Contains('/* viewer bridge')) {
    $i = $t.LastIndexOf('</body>', [StringComparison]::OrdinalIgnoreCase)
    if ($i -ge 0) { $t = $t.Insert($i, $bridge) } else { $t += $bridge }
    [IO.File]::WriteAllText($p, $t, $utf8)
    "bridge added: t/$id.html"
  }
}

$files = @('index.html', 'schemes.json', 'manifest.webmanifest', 'icon-180.png', 'icon-192.png', 'icon-512.png') + ($ids | ForEach-Object { "t/$_.html" })
$sha = [Security.Cryptography.SHA256]::Create()
$all = New-Object IO.MemoryStream
foreach ($f in $files) { $b = [IO.File]::ReadAllBytes("$root\$f"); $all.Write($b, 0, $b.Length) }
$version = 'pf-' + (($sha.ComputeHash($all.ToArray()) | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 12)

$list = (@('./') + ($files | ForEach-Object { "./$_" }) | ForEach-Object { "'$_'" }) -join ",`n  "
$sw = (& $read "$PSScriptRoot\sw.template.js").Replace('__VERSION__', $version).Replace('__FILES__', $list)
[IO.File]::WriteAllText("$root\sw.js", $sw, $utf8)
"OK: $($ids.Count) schemes, $($data.Count) sections, $version"
