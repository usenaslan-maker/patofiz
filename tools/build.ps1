# Prepares the site after library.json or a page changed:
# puts the viewer bridge into every page and rewrites sw.js with the current file list and a content version.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$utf8 = New-Object Text.UTF8Encoding $false
$read = { param($p) [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }

$data = (& $read "$root\library.json") | ConvertFrom-Json
$bridge = & $read "$PSScriptRoot\bridge.html"

# pages = "<tab key>/<id>.html", e.g. t/22.html (scheme), k/01.html (notes), c/01.html (practice task)
$pages = @()
foreach ($tab in $data.tabs) { foreach ($s in $tab.sections) { foreach ($it in $s.items) { $pages += "$($tab.key)/$($it.id).html" } } }
$dup = $pages | Group-Object | Where-Object Count -gt 1
if ($dup) { throw "Duplicate page: $($dup.Name -join ', ')" }

foreach ($pg in $pages) {
  $p = Join-Path $root $pg
  if (-not (Test-Path $p)) { throw "Missing file $pg" }
  $t = & $read $p
  if (-not $t.Contains('/* viewer bridge')) {
    $i = $t.LastIndexOf('</body>', [StringComparison]::OrdinalIgnoreCase)
    if ($i -ge 0) { $t = $t.Insert($i, $bridge) } else { $t += $bridge }
    [IO.File]::WriteAllText($p, $t, $utf8)
    "bridge added: $pg"
  }
}

$files = @('index.html', 'library.json', 'manifest.webmanifest', 'icon-180.png', 'icon-192.png', 'icon-512.png') + $pages
$sha = [Security.Cryptography.SHA256]::Create()
$all = New-Object IO.MemoryStream
foreach ($f in $files) { $b = [IO.File]::ReadAllBytes("$root\$f"); $all.Write($b, 0, $b.Length) }
$version = 'pf-' + (($sha.ComputeHash($all.ToArray()) | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 12)

$list = (@('./') + ($files | ForEach-Object { "./$_" }) | ForEach-Object { "'$_'" }) -join ",`n  "
$sw = (& $read "$PSScriptRoot\sw.template.js").Replace('__VERSION__', $version).Replace('__FILES__', $list)
[IO.File]::WriteAllText("$root\sw.js", $sw, $utf8)
"OK: " + (($data.tabs | ForEach-Object { $k = $_.key; "$k=" + @($pages | Where-Object { $_.StartsWith("$k/") }).Count }) -join ' ') + ", $version"
