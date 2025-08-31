<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <!-- 1) Rimuovo text-node fatti solo di whitespace -->
  <xsl:strip-space elements="*"/>

  <!-- 2) Parametro per la variante d / sd -->
  <xsl:param name="variant" select="'d'"/>

  <!-- 3) Output puro testo (UTF-8) -->
  <xsl:output method="text" encoding="UTF-8"/>

  <!-- 4) TEMPLATE PRINCIPALE: preambolo + pagina titolo + \newpage + \linenumbers + corpo  -->
  <xsl:template match="/tei:TEI">
    <xsl:text>
\documentclass[12pt]{article}
\usepackage{fontspec}
\usepackage[french]{babel}
\setmainfont{Junicode}

% Pacchetto per numerare le righe (deve stare nel preambolo)
\usepackage{lineno}

\begin{document}

% --- PAGINA DEL TITOLO ---
\begin{center}
  {\LARGE BnF. Bibliothèque de l'Arsenal, MS-5219 réserve}\\[2ex]
</xsl:text>
    <xsl:choose>
      <xsl:when test="$variant = 'd'">
        <xsl:text>  {\Large Édition graphématique}\\[2ex]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>  {\Large Édition semi-diplomatique}\\[2ex]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>  {\large Lorenzo Paoli}
\end{center}

% Salto pagina per iniziare il testo vero
\newpage

% Inizio numerazione di riga
\modulolinenumbers[5]   % stampa un numero ogni 5 righe
\firstlinenumber{0}     % la prima riga stampata è 1 (poi 5, 10, 15, …)
\linenumbers


    </xsl:text>
    <!-- Applichiamo i template a tutti i <div> nel corpo -->
    <xsl:apply-templates select="//tei:body//tei:div"/>
    <xsl:text>

\end{document}
    </xsl:text>
  </xsl:template>


  <!-- 5) TEMPLATE PER <div>: spazio vuoto + processa figli + altro spazio vuoto -->
  <xsl:template match="tei:div">
    <xsl:text>

</xsl:text>
    <xsl:apply-templates select="node()"/>
    <xsl:text>

</xsl:text>
  </xsl:template>


<!-- 6) TEMPLATE PER <head>: usa solo i text-node (non <lb/>) dentro \subsection* --> 

<!-- HEAD: include tutto (testo + elementi) -->
<xsl:template match="tei:head">
  <xsl:text>\subsection*{</xsl:text>
  <xsl:apply-templates select="node()"/>
  <xsl:text>}</xsl:text>
  <xsl:text>
</xsl:text>
</xsl:template>

<!-- HEAD: ignora il primo <lb/> se è davvero all’inizio (niente testo o elementi significativi prima) -->
<xsl:template match="tei:head/tei:lb[
  not(preceding-sibling::text()[normalize-space()])
  and not(preceding-sibling::*[normalize-space()])
]" priority="4">
  <!-- non emettere nulla -->
</xsl:template>

<!-- HEAD: per tutti gli altri <lb/> dentro <head>, usa \protect\\ (oppure \protect\\*) -->
<xsl:template match="tei:head/tei:lb" priority="3">
  <xsl:text>\protect\\ </xsl:text>
</xsl:template>

<!-- (facoltativo) Normalizza piccoli artefatti di spaziatura: se capita ' \\ ' senza spazio prima -->
<xsl:template match="tei:head/text()">
  <!-- di default va bene così; se servisse, puoi fare una normalizzazione fine qui -->
  <xsl:value-of select="."/>
</xsl:template>





  <!-- 7) TEMPLATE PER <p> e <ab>: paragrafo normale con riga vuota sopra e sotto -->
  <xsl:template match="tei:p | tei:ab">
    <xsl:text>

</xsl:text>
    <xsl:apply-templates select="node()"/>
    <xsl:text>

</xsl:text>
  </xsl:template>


   <!--  
    8.a) Ignoro il <lb/> se è  
         • “all’inizio” di <p> o <ab> (cioè preceduto solo da <pb/> o da testo vuoto),  
         • o se è immediatamente dopo un <head/>.  
  -->
  <xsl:template match="
    tei:lb[
      not(
        preceding-sibling::*[not(self::tei:pb or self::tei:head)]
        or
        preceding-sibling::text()[normalize-space()]
      )
    ]" priority="2">
    <!-- In questo caso non faccio uscire nulla -->
  </xsl:template>

  <!--  
    8.b) In tutti gli altri casi, emetto \\ + invio => forzo il ritorno a capo in LaTeX  
  -->
  <xsl:template match="tei:lb">
    <xsl:text>\\
</xsl:text>
  </xsl:template>





  <!-- 9) TEMPLATE PER <pb/>: emette \newpage -->
  <xsl:template match="tei:pb">
    <xsl:text>\newpage
</xsl:text>
  </xsl:template>


  <!-- 10) TEMPLATE PER text(): riprende testo puro “as is” -->
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>


  <!-- 11) ESEMPIO PER <hi>, <supplied>, <unclear> (come prima) -->
  <xsl:template match="tei:hi">
    <xsl:choose>
      <xsl:when test="@rend='italic' or @rend='italics'">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates select="node()"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:supplied">
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates select="node()"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="tei:unclear">
    <xsl:text>\mbox{[illeggibile]}</xsl:text>
  </xsl:template>

  <!-- Aggiungi qui altri template per gap, note, etc., se servono -->

</xsl:stylesheet>
