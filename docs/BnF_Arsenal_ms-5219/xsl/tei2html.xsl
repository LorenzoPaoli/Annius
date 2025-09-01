<?xml version="1.0" encoding="UTF-8"?>
<!-- TEI -> HTML: edizione due colonne + sidebar folios, coerente col sito -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <!-- Parametri -->
  <xsl:param name="variant" select="'d'"/>  <!-- 'd' = graphématique ; 'sd' = semi-diplomatique -->
  <xsl:param name="img-base" select="'assets/facs/'"/>

  <!-- Output -->
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <!-- Keys -->
  <xsl:key name="kPersonByID"   match="tei:person" use="@xml:id"/>
  <xsl:key name="kPersonByName" match="tei:person"
           use="translate(normalize-space(tei:persName),
                          'ABCDEFGHIJKLMNOPQRSTUVWXYZſ',
                          'abcdefghijklmnopqrstuvwxyzs')"/>
  <xsl:key name="kBiblByID"     match="tei:bibl"    use="@xml:id"/>
  <xsl:key name="kSurfaceByID"  match="tei:surface" use="@xml:id"/>

  <!-- = helper: etichetta folio “1r/1v” da @n numerico = -->
  <xsl:template name="folioLabel">
    <xsl:param name="n"/>
    <xsl:variable name="num" select="number($n)"/>
    <xsl:choose>
      <xsl:when test="$num mod 2 = 1">
        <xsl:value-of select="concat(floor(($num + 1) div 2),'r')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($num div 2,'v')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================= ROOT ================= -->
  <xsl:template match="/">
    <html lang="fr">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="//tei:titleStmt/tei:title"/></title>
        <link href="https://fonts.googleapis.com/css2?family=Linden+Hill:ital@0;1&amp;display=swap" rel="stylesheet"/>
        <link rel="stylesheet" href="assets/css/style.css"/>
      </head>
      <body id="top">
        <a class="skip" href="#main">Aller au contenu</a>
        <div class="container">

          <!-- ===== menu principale ===== -->
          <nav class="top-menu" aria-label="Navigation principale">
            <ul>
              <li><a href="index_ms_5219.html">Accueil</a></li>
              <li><a href="a-propos.html">À propos</a></li>

              <!-- Switch variante -->
              <xsl:choose>
                <xsl:when test="$variant='d'">
                  <li><a id="switch-variant" href="transcription_ms_5219_sd.html">Édition semi-diplomatique</a></li>
                </xsl:when>
                <xsl:otherwise>
                  <li><a id="switch-variant" href="transcription_ms_5219_d.html">Édition graphématique</a></li>
                </xsl:otherwise>
              </xsl:choose>

              <li><a href="auctoritates.html">Auctoritates</a></li>
              <li><a href="genealogie.html">Généalogie</a></li>

              <!-- Strumenti (tema / A±) -->
              <li class="nav-tools">
                <button id="theme-toggle" aria-label="Mode sombre/clair">🌓</button>
                <button id="font-minus" aria-label="Réduire la taille du texte">A−</button>
                <button id="font-plus" aria-label="Augmenter la taille du texte">A+</button>
              </li>

              <!-- Ricerca site-wide con suggerimenti -->
              <li class="nav-search">
                <form role="search" action="search.html" method="get" id="site-search">
                  <label for="search" class="sr-only">Rechercher</label>
                  <!-- disattivo l’highlight globale: data-highlight="0" -->
                  <input id="search" name="q" type="search" placeholder="Rechercher…"
                         autocomplete="off"
                         data-highlight="0"
                         aria-controls="search-suggest"
                         aria-expanded="false"
                         aria-haspopup="listbox"/>
                  <!-- il popup dei suggerimenti parte nascosto -->
                  <div id="search-suggest"
                       class="suggest-box"
                       role="listbox"
                       aria-label="Suggestions"
                       hidden="hidden"></div>
                </form>
              </li>
            </ul>
          </nav>

          <main id="main" class="edition">
            <h1><xsl:value-of select="//tei:titleStmt/tei:title"/></h1>

            <!-- Blocco download (PDF + XML-TEI) -->
            <nav class="download-nav" aria-label="Téléchargement">
              <ul>
                <!-- 1) Download PDF -->
                <li>
                  <xsl:choose>
                    <xsl:when test="$variant = 'd'">
                      <a href="assets/pdf/BnF_ms_5219_graphematique_Lorenzo_Paoli.pdf"
                         download="BnF_ms_5219_graphematique_Lorenzo_Paoli.pdf">
                        Télécharger le PDF de l'édition graphématique
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="assets/pdf/BnF_ms_5219_semi-diplomatique_Lorenzo_Paoli.pdf"
                         download="BnF_ms_5219_semi-diplomatique_Lorenzo_Paoli.pdf">
                        Télécharger le PDF de l'édition semi-diplomatique
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </li>

                <!-- 2) Download XML-TEI -->
                <li>
                  <xsl:variable name="xmlFile">
                    <xsl:choose>
                      <xsl:when test="$variant = 'd'">xml/ms_5219_d.xml</xsl:when>
                      <xsl:otherwise>xml/ms_5219_sd.xml</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>

                  <xsl:variable name="xmlDownloadName">
                    <xsl:choose>
                      <xsl:when test="$variant = 'd'">ms_5219_d.xml</xsl:when>
                      <xsl:otherwise>ms_5219_sd.xml</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>

                  <a href="{$xmlFile}" download="{$xmlDownloadName}">
                    Télécharger l’édition XML-TEI
                  </a>
                </li>
              </ul>
            </nav>

            <!-- layout a due colonne: sidebar folios + testo -->
            <div class="edition-layout">
              <aside class="folio-sidebar" aria-label="Navigation des folios">
                <ul>
                  <xsl:for-each select="//tei:pb">
                    <xsl:variable name="lbl">
                      <xsl:call-template name="folioLabel">
                        <xsl:with-param name="n" select="@n"/>
                      </xsl:call-template>
                    </xsl:variable>
                    <li><a href="#f{$lbl}">f. <xsl:value-of select="$lbl"/></a></li>
                  </xsl:for-each>
                </ul>
              </aside>

              <article>
                <xsl:apply-templates select="//tei:body/node()"/>
              </article>
            </div>
          </main>

          <footer class="center">
            <p class="note">© 2025 Université de Genève | Réalisation : Lorenzo Paoli</p>
          </footer>
        </div>

        <!-- Manteniamo i tuoi script inline: switch variante + evidenziazione folio corrente -->
        <script><![CDATA[
document.addEventListener('DOMContentLoaded', () => {
  const here = location.hash || '#f1r';
  const isD = location.pathname.endsWith('_d.html');
  const target = isD ? 'transcription_ms_5219_sd.html' : 'transcription_ms_5219_d.html';
  const a = document.getElementById('switch-variant');
  if (a) a.setAttribute('href', `${target}${here}`);
});
        ]]></script>

        <script><![CDATA[
document.addEventListener('DOMContentLoaded', () => {
  const headings = [...document.querySelectorAll('[id^="f"]')];
  const links = new Map(
    [...document.querySelectorAll('.folio-sidebar a')]
      .map(a => [a.getAttribute('href').slice(1), a])
  );
  const io = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        links.forEach(l => l.classList.remove('active'));
        const link = links.get(e.target.id);
        if (link) link.classList.add('active');
      }
    });
  }, {rootMargin: '-20% 0px -70% 0px', threshold: 0});
  headings.forEach(h => io.observe(h));
});
        ]]></script>

        <!-- Overlay lightbox per ingrandimento immagini -->
        <div class="lb" aria-hidden="true">
          <img alt=""/>
          <button class="x" aria-label="Fermer">×</button>
        </div>

        <!-- Script finali -->
        <script src="assets/js/main.js"></script>
        <script src="assets/js/search.js"></script>
        <script><![CDATA[
  // Registrazione SW robusta per GitHub Pages (project site)
  if ('serviceWorker' in navigator && window.isSecureContext) {
    try {
      const base = location.pathname.replace(/[^/]*$/, ''); // cartella della pagina
      const swUrl = base + 'assets/js/service-worker.js';
      navigator.serviceWorker.register(swUrl);
    } catch(e) { /* no-op */ }
  }
        ]]></script>

      </body>
    </html>
  </xsl:template>

  <!-- =========== page break <pb>: figura fac-simile con id f{lbl} =========== -->
  <xsl:template match="tei:pb">
    <xsl:variable name="lbl">
      <xsl:call-template name="folioLabel">
        <xsl:with-param name="n" select="@n"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="preceding::tei:pb">
      <div class="clear"></div>
      <hr class="folio-sep"/>
    </xsl:if>

    <figure class="facsimile" id="f{$lbl}">
      <!-- risoluzione src dell’immagine (tua logica robusta) -->
      <xsl:variable name="facsRaw" select="normalize-space(@facs)"/>
      <xsl:variable name="surfID"   select="substring-after($facsRaw,'#')"/>
      <xsl:variable name="fromSurf" select="string(key('kSurfaceByID',$surfID)/tei:graphic[1]/@url)"/>

      <xsl:variable name="isExt"
        select="contains($facsRaw,'.jpg') or contains($facsRaw,'.jpeg')
             or contains($facsRaw,'.png') or contains($facsRaw,'.webp')"/>
      <xsl:variable name="hasPath"
        select="contains($facsRaw,'/') or starts-with($facsRaw,'http://')
             or starts-with($facsRaw,'https://')"/>

      <xsl:variable name="src">
        <xsl:choose>
          <xsl:when test="$fromSurf != ''">
            <xsl:value-of select="$fromSurf"/>
          </xsl:when>
          <xsl:when test="$isExt and $hasPath">
            <xsl:value-of select="$facsRaw"/>
          </xsl:when>
          <xsl:when test="$isExt and not($hasPath)">
            <xsl:value-of select="concat($img-base,$facsRaw)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($img-base,$facsRaw)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <img src="{$src}" alt="Fac-similé f. {$lbl}" loading="lazy" decoding="async"/>
      <figcaption>f. <xsl:value-of select="$lbl"/></figcaption>
    </figure>
  </xsl:template>

  <!-- =========== struttura: body/div =========== -->
  <xsl:template match="tei:body|tei:div">
    <div><xsl:apply-templates/></div>
  </xsl:template>

  <!-- =========== paragrafi con ID “f{lbl}-p{n}” =========== -->
  <xsl:template match="tei:p|tei:ab">
    <xsl:variable name="folioN" select="(descendant::tei:pb[1]/@n | preceding::tei:pb[1]/@n)[last()]"/>
    <xsl:variable name="lbl">
      <xsl:call-template name="folioLabel">
        <xsl:with-param name="n" select="$folioN"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pIdx"
      select="count(preceding::tei:p[preceding::tei:pb[1]/@n = $folioN]
                   | preceding::tei:ab[preceding::tei:pb[1]/@n = $folioN]) + 1"/>
    <p id="f{$lbl}-p{$pIdx}"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- =========== line-break con ID “f{lbl}-l{n}” + <br/> =========== -->
  <xsl:template match="tei:lb">
    <xsl:variable name="folioN" select="preceding::tei:pb[1]/@n"/>
    <xsl:variable name="lbl">
      <xsl:call-template name="folioLabel">
        <xsl:with-param name="n" select="$folioN"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lIdx"
      select="count(preceding::tei:lb[preceding::tei:pb[1]/@n = $folioN]) + 1"/>
    <span id="f{$lbl}-l{$lIdx}" class="lb"></span><br/>
  </xsl:template>

  <!-- =========== persName con tooltip (come tua versione) =========== -->
  <xsl:template match="tei:persName">
    <xsl:variable name="id" select="substring-after(@ref,'#')"/>
    <xsl:variable name="canon"
      select="translate(normalize-space(.),
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZſ',
                        'abcdefghijklmnopqrstuvwxyzs')"/>
    <xsl:variable name="person"
      select="key('kPersonByID',$id)[1]
              | key('kPersonByName',$canon)[1]"/>
    <xsl:variable name="note" select="$person/tei:note"/>

    <span>
      <xsl:attribute name="class">
        <xsl:text>persName</xsl:text>
        <xsl:if test="$note">
          <xsl:text> has-note</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:if test="$note">
        <xsl:attribute name="title">
          <xsl:value-of select="$note"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- =========== ref (biblio) con tooltip (come tua versione) =========== -->
  <xsl:template match="tei:ref">
    <xsl:variable name="t"  select="@target"/>
    <xsl:variable name="id" select="substring-after($t,'#')"/>
    <xsl:variable name="bibl" select="key('kBiblByID',$id)[1]"/>
    <xsl:variable name="loc"  select="normalize-space(@n)"/>
    <xsl:variable name="desc">
      <xsl:choose>
        <xsl:when test="$bibl">
          <xsl:variable name="a"  select="normalize-space($bibl/tei:author)"/>
          <xsl:variable name="ti" select="normalize-space($bibl/tei:title)"/>
          <xsl:variable name="core">
            <xsl:choose>
              <xsl:when test="$a and $ti">
                <xsl:value-of select="concat($a, ', ', $ti)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($a,$ti)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$loc!='' and $core!=''">
              <xsl:value-of select="concat($core, ' – ', $loc)"/>
            </xsl:when>
            <xsl:when test="$loc!=''">
              <xsl:value-of select="$loc"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$core"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$loc"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <a href="{$t}">
      <xsl:if test="$desc!=''">
        <xsl:attribute name="title">
          <xsl:value-of select="$desc"/>
        </xsl:attribute>
        <xsl:attribute name="class">
          <xsl:text>biblRef has-note</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

 <!-- TEI headings come testo normale (niente titoloni) -->
<xsl:template match="tei:head">
  <p class="tei-head"><xsl:apply-templates/></p>
</xsl:template>


  <!-- =========== fallback =========== -->
  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

</xsl:stylesheet>
