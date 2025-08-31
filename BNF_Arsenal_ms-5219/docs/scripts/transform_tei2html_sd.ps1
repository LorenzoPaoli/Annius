param(
  [string]$XmlPath = "C:\humanites_numeriques\memoire\projet_hn_lorenzo_paoli\xml\ms_5219_sd.xml",
  [string]$XslPath = "C:\humanites_numeriques\memoire\projet_hn_lorenzo_paoli\xsl\tei2html.xsl",
  [string]$OutPath = "C:\humanites_numeriques\memoire\projet_hn_lorenzo_paoli\transcription_ms_5219_sd.html"
)

Write-Host "XSL: $XslPath"
Write-Host "XML: $XmlPath"
Write-Host "OUT: $OutPath"

$xslt = New-Object System.Xml.Xsl.XslCompiledTransform($true)
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
    $args = New-Object System.Xml.Xsl.XsltArgumentList
    $args.AddParam("variant", "", "sd")

    $reader = [System.Xml.XmlReader]::Create($XmlPath)
    $writer = New-Object System.IO.StreamWriter($OutPath, $false, [System.Text.Encoding]::UTF8)

    $xslt.Transform($reader, $args, $writer)
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
