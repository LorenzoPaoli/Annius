param(
  [string]$Root = "C:\BnF_Arsenal_ms-5219"
)

function Get-TextContent {
  param([string]$html)
  $t = [regex]::Replace($html, "<script[\s\S]*?</script>", "", "IgnoreCase")
  $t = [regex]::Replace($t, "<style[\s\S]*?</style>", "", "IgnoreCase")
  $t = [regex]::Replace($t, "<[^>]+>", " ")
  $t = [regex]::Replace($t, "\s+", " ").Trim()
  return $t
}

function Load-Html {
  param([string]$path)
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

$docs = New-Object System.Collections.Generic.List[Object]

# 1) Pagine statiche
$staticPages = @(
  "index_ms_5219.html",
  "a-propos.html",
  "auctoritates.html",
  "genealogie.html"
)

foreach($file in $staticPages){
  $p = Join-Path $Root $file
  if (Test-Path $p){
    $html = Load-Html $p
    $title = ([regex]::Match($html, "<title>(.*?)</title>", "IgnoreCase")).Groups[1].Value.Trim()
    if (-not $title) { $title = $file }
    $main = ([regex]::Match($html, "<main[^>]*>([\s\S]*?)</main>", "IgnoreCase")).Groups[1].Value
    if (-not $main) { $main = $html }
    $content = Get-TextContent $main
    $docs.Add([pscustomobject]@{
      url     = $file
      title   = $title
      content = $content
    })
  }
}

# 2) Edizioni: un record per ogni paragrafo <p id="...">
$editions = @(
  "transcription_ms_5219_d.html",
  "transcription_ms_5219_sd.html"
)

foreach($file in $editions){
  $p = Join-Path $Root $file
  if (-not (Test-Path $p)) { continue }

  $html = Load-Html $p
  $title = ([regex]::Match($html, "<title>(.*?)</title>", "IgnoreCase")).Groups[1].Value.Trim()
  if (-not $title) { $title = $file }

  $article = ([regex]::Match($html, "<article[^>]*>([\s\S]*?)</article>", "IgnoreCase")).Groups[1].Value
  if (-not $article) { $article = $html }

  $rx = New-Object System.Text.RegularExpressions.Regex("<p\s+[^>]*id\s*=\s*[""']([^""']+)[""'][^>]*>([\s\S]*?)</p>", "IgnoreCase")
  $mc = $rx.Matches($article)

  foreach($m in $mc){
    $paraId = $m.Groups[1].Value
    $txt = Get-TextContent $m.Groups[2].Value
    if (![string]::IsNullOrWhiteSpace($txt)){
      $fragUrl = "$file#$paraId"
      $docs.Add([pscustomobject]@{
        url     = $fragUrl
        title   = "$title - [$paraId]"
        content = $txt
      })
    }
  }
}

# Output JSON (in root, dove il fetch punta a 'search-index.json')
$payload = [pscustomobject]@{ docs = $docs }
$outPath = Join-Path $Root "search-index.json"

[System.IO.File]::WriteAllText(
  $outPath,
  ($payload | ConvertTo-Json -Depth 5 -Compress).Replace("\u003c","<").Replace("\u003e",">").Replace("\u0026","&"),
  [System.Text.Encoding]::UTF8
)

Write-Host ("OK -> {0}" -f $outPath)
Write-Host ("Totale documenti indicizzati: {0}" -f $docs.Count)
