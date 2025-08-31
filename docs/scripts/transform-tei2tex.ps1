param(
  [ValidateSet('d','sd','both')]
  [string]$Variant = 'both',
  [switch]$Compile
)

$Root      = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$XslPath   = Join-Path $Root 'xsl\tei2tex_crit.xsl'
$LatexDir  = Join-Path $Root 'latex'
$PdfDir    = Join-Path $Root 'assets\pdf'

New-Item -ItemType Directory -Force -Path $LatexDir | Out-Null
New-Item -ItemType Directory -Force -Path $PdfDir   | Out-Null

function Invoke-TexTransform {
  param([string]$variant)

  if ($variant -eq 'd') {
    $xml = Join-Path $Root 'xml\ms_5219_d.xml'
    $tex = Join-Path $LatexDir 'ms_5219_d.tex'
    $pdfPublic = Join-Path $PdfDir 'BnF_ms_5219_graphematique_Lorenzo_Paoli.pdf'
  } else {
    $xml = Join-Path $Root 'xml\ms_5219_sd.xml'
    $tex = Join-Path $LatexDir 'ms_5219_sd.tex'
    $pdfPublic = Join-Path $PdfDir 'BnF_ms_5219_semi-diplomatique_Lorenzo_Paoli.pdf'
  }

  Write-Host "XSL: $XslPath"
  Write-Host "XML: $xml"
  Write-Host "TEX: $tex"

  $xslt = New-Object System.Xml.Xsl.XslCompiledTransform
  $settings = New-Object System.Xml.Xsl.XsltSettings($true,$true)
  $resolver = New-Object System.Xml.XmlUrlResolver
  $xslt.Load($XslPath,$settings,$resolver)

  $arg = New-Object System.Xml.Xsl.XsltArgumentList
  $arg.AddParam('variant','', $variant) | Out-Null

  $reader = [System.Xml.XmlReader]::Create($xml)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $writer = New-Object System.IO.StreamWriter($tex,$false,$utf8NoBom)

  $xslt.Transform($reader,$arg,$writer)
  $writer.Close(); $reader.Close()

  Write-Host "OK → $tex"

  if ($Compile) {
    Write-Host "Compilo con XeLaTeX…"
    $args = @(
      '-interaction=nonstopmode',
      '-halt-on-error',
      "-output-directory=$LatexDir",
      $tex
    )
    $p = Start-Process -FilePath 'xelatex' -ArgumentList $args -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -ne 0) {
      throw "Compilazione XeLaTeX fallita (exit $($p.ExitCode)). Controlla i log in $LatexDir."
    }
    # nome PDF generato = basename del .tex
    $builtPdf = [System.IO.Path]::ChangeExtension($tex,'.pdf')
    Copy-Item -Force $builtPdf $pdfPublic
    Write-Host "PDF copiato → $pdfPublic"
  }
}

switch ($Variant) {
  'd'    { Invoke-TexTransform -variant 'd' }
  'sd'   { Invoke-TexTransform -variant 'sd' }
  'both' { Invoke-TexTransform -variant 'd'; Invoke-TexTransform -variant 'sd' }
}
