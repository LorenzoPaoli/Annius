param(
  [string]$XmlPath = "C:\BnF_Arsenal_ms-5219\xml\ms_5219_d.xml",
  [string]$XslPath = "C:\BnF_Arsenal_ms-5219xsl\tei2html.xsl",
  [string]$OutPath = "C:\BnF_Arsenal_ms-5219\transcription_ms_5219_d.html"
)

Write-Host "XSL: $XslPath"
Write-Host "XML: $XmlPath"
Write-Host "OUT: $OutPath"

# Abilita info di riga/colonna nei messaggi
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform($true)   # $true => debug line info
# Non usiamo script() né document(), quindi sicurezza al massimo:
$settings = New-Object System.Xml.Xsl.XsltSettings($false, $false)
$resolver = New-Object System.Xml.XmlUrlResolver

try {
    $xslt.Load($XslPath, $settings, $resolver)
}
catch {
    $ex = $_.Exception
    if ($ex -is [System.Xml.Xsl.XsltException]) {
        Write-Error ("❌ Errore compilazione XSLT: " + $ex.Message)
        Write-Error ("    File: " + $ex.SourceUri)
        Write-Error ("    Linea: {0}  Colonna: {1}" -f $ex.LineNumber, $ex.LinePosition)
       } else {
        Write-Error ("❌ Errore load XSLT: " + $ex.Message)
        if ($ex.InnerException) { Write-Error ("    Inner: " + $ex.InnerException.Message) }
    }
    # Stampa tutte le proprietà dell’errore
    $_ | Format-List * -Force
    exit 1
}

try {
    $reader = [System.Xml.XmlReader]::Create($XmlPath)
    $writer = New-Object System.IO.StreamWriter($OutPath, $false, [System.Text.Encoding]::UTF8)

    $xslt.Transform($reader, $null, $writer)
    $writer.Close()
    Write-Host "✅ Transform OK → $OutPath"
}
catch {
    $ex = $_.Exception
    if ($ex -is [System.Xml.Xsl.XsltException]) {
        Write-Error ("❌ Errore trasformazione: " + $ex.Message)
        Write-Error ("    File: " + $ex.SourceUri)
        Write-Error ("    Linea: {0}  Colonna: {1}" -f $ex.LineNumber, $ex.LinePosition)
        } else {
        Write-Error ("❌ Errore trasformazione: " + $ex.Message)
        if ($ex.InnerException) { Write-Error ("    Inner: " + $ex.InnerException.Message) }
    }
    # Stampa tutte le proprietà dell’errore
    $_ | Format-List * -Force
    exit 1

}
