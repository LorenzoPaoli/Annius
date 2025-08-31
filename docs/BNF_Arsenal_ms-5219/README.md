# BnF Arsenal MS-5219 réserve — Digital edition (ff. 1r–8r)

This repository contains the source and outputs for a small static website that publishes a **digital edition of folios 1r–8r** from *BnF, Bibliothèque de l’Arsenal, MS-5219 réserve*: a French **translation with commentary** of portions of Annius of Viterbo’s *Antiquitates*, prepared by **Robert Frescher** (ca. 1510–1511).  
The site’s content is **in French**; this README is in English for wider accessibility.

- **Scientific editor:** Lorenzo Paoli (FNS Scientific Collaborator), Institute for Reformation History, University of Geneva  
- **Edition date:** 26 May 2025  
- **License:** CC BY 4.0  
- **Manuscript (full digitization):** available on Gallica (BnF)  
- **Scope:** graphematic and semi-diplomatic transcriptions (HTML and PDF), contextual pages (*À propos*, *Auctoritates*, *Généalogie*), images, OCR outputs, and a lightweight client-side search.

> For a human-readable overview in French, see **`a-propos.html`** (À propos / Méthode éditoriale).

---

## Folder structure (current)

/
├─ index_ms_5219.html # Home / index of the edition
├─ a-propos.html # About & editorial method (FR)
├─ auctoritates.html # Authorities cited (FR)
├─ genealogie.html # Genealogical table (FR)
├─ search.html # Search results page
│
├─ transcription_ms_5219_d.html # Graphematic transcription (HTML)
├─ transcription_ms_5219_sd.html # Semi-diplomatic transcription (HTML)
│
├─ assets/
│ ├─ css/style.css # Base styles + themes
│ ├─ js/main.js # Theme toggle, font size A±, in-page highlight, lightbox
│ ├─ js/search.js # Client-side suggestions + results renderer
│ ├─ js/service-worker.js # (Optional) offline cache/PWA (see notes below)
│ ├─ img/ # UI / illustration images (cover, logos)
│ ├─ facs/ # Facsimile images of the manuscript folios
│ ├─ pdf/ # Generated PDFs (XeLaTeX outputs)
│ └─ search-index.json # Prebuilt search index (see “Search”)
│
├─ DATA_OCR/ # Raw OCR outputs linked to this edition
│ ├─ *.txt / *.xml # uncorrected OCR files
│ └─ ...
│
├─ xml/
│ ├─ ms_5219_d.xml # TEI-XML — graphematic variant
│ └─ ms_5219_sd.xml # TEI-XML — semi-diplomatic variant
│
├─ xsl/
│ ├─ tei2html.xsl # XSLT → HTML
│ └─ tei2tex_crit.xsl # XSLT → XeLaTeX
│
├─ latex/
│ ├─ ms_5219_d.tex # XeLaTeX source (graphematic)
│ └─ ms_5219_sd.tex # XeLaTeX source (semi-diplomatic)
│
├─ data/
│ └─ list_person.csv # People table for the genealogical page
│
├─ schema/
│ └─ ms5219.odd # TEI ODD schema (project profile)
│
├─ scripts/ # Build utilities (Windows PowerShell)
│ ├─ transform_tei2html.ps1 # TEI → HTML (graphematic)
│ ├─ transform_tei2html_sd.ps1 # TEI → HTML (semi-diplomatic)
│ ├─ transform-tei2tex.ps1 # TEI → XeLaTeX (+ optional compile to PDF)
│ └─ Build-SearchIndex.ps1 # Produce client search index JSON
│
├─ notes/prompt_powershell.txt # Internal notes
├─ assets/citation.cff # Citation metadata (CFF)
└─ README.md # You are here


---

## What’s on the site

- **Transcriptions (HTML)**  
  Two synchronized variants generated from TEI:
  - **Graphematic** → `transcription_ms_5219_d.html`  
  - **Semi-diplomatic** → `transcription_ms_5219_sd.html`  
  The UI includes a **variant switcher**, **theme toggle** (light/dark), **font size** controls (A±), **in-page highlight** box, and an **image lightbox**.

- **Context pages**  
  - `a-propos.html`: editorial method, metadata (editor, date, license, access to TEI XML, link to Gallica).  
  - `auctoritates.html`: list/description of cited *auctoritates*.  
  - `genealogie.html`: tabular genealogy built from `data/list_person.csv`.

- **PDF outputs**  
  Generated via XeLaTeX and published under `assets/pdf/`:
  - `BnF_ms_5219_graphematique_Lorenzo_Paoli.pdf`  
  - `BnF_ms_5219_semi-diplomatique_Lorenzo_Paoli.pdf`

- **Facsimiles**  
  High-resolution page images under `assets/facs/` and thumbnails under `assets/img/`.

- **OCR data**  
  The folder `DATA_OCR/` contains raw OCR outputs extracted from the manuscript images.  
  These files are provided **for reference and reuse**, but are **not corrected**: they may include recognition errors and are not intended as the final scholarly transcription.

---

## Build & reproducibility

> All scripts below are plain **Windows PowerShell** and rely on .NET’s `XslCompiledTransform`.  
> Paths in the scripts may be **absolute** in the sample parameters — override them on the command line.

### 1) TEI → HTML

```powershell
# Graphematic
pwsh -File .\scripts\transform_tei2html.ps1 `
  -XmlPath .\xml\ms_5219_d.xml `
  -XslPath .\xsl\tei2html.xsl `
  -OutPath .\transcription_ms_5219_d.html

# Semi-diplomatic
pwsh -File .\scripts\transform_tei2html_sd.ps1 `
  -XmlPath .\xml\ms_5219_sd.xml `
  -XslPath .\xsl\tei2html.xsl `
  -OutPath .\transcription_ms_5219_sd.html

# Build .tex for both variants (and compile with XeLaTeX)
pwsh -File .\scripts\transform-tei2tex.ps1 -Variant both -Compile
# Outputs: .\latex\ms_5219_[d|sd].tex and PDF copies in .\assets\pdf\

# Generate search-index.json from HTML pages and paragraph-level content
pwsh -File .\scripts\Build-SearchIndex.ps1 -Root .
# This writes .\search-index.json (see “Search” notes below)

# Python 3
python -m http.server 8000
# Then open http://localhost:8000/index_ms_5219.html

Search (how it works)

A prebuilt JSON index (search-index.json) is loaded by assets/js/search.js to power:

the type-ahead suggestions in the top menu box, and

the results renderer on search.html (query string parameter ?q=).

Current layout (what’s inside this repo):

The index file lives at assets/search-index.json.

Important: the JS currently fetches '/assets/js/search-index.json'.
Either move the JSON to assets/js/search-index.json or change the fetch to '/assets/search-index.json'.
If you run Build-SearchIndex.ps1 as-is, it writes ./search-index.json; either move that file into assets/ or adjust the script’s $outPath.

Service Worker (optional offline cache)

The registration in the pages points to '/service-worker.js', but the file is stored at assets/js/service-worker.js.
To enable caching:

Option A: move service-worker.js to the repo root and keep the existing registration; or

Option B: change the registration to navigator.serviceWorker.register('/assets/js/service-worker.js').

Also review the ASSETS array in the SW file and add any pages/assets you want cached.

Accessing sources & license

TEI-XML sources: xml/ms_5219_d.xml, xml/ms_5219_sd.xml

Stylesheets: xsl/tei2html.xsl, xsl/tei2tex_crit.xsl

License: Content is released under CC BY 4.0.

Manuscript access: The original manuscript is viewable on Gallica (BnF).

Citation

You can cite this edition as:

Lorenzo Paoli (ed.), Édition numérique du MS-5219 réserve (ff. 1r–8r), Université de Genève, 2025. CC BY 4.0.

A machine-readable citation file is available at assets/citation.cff.

Acknowledgments

This project was developed within the University of Geneva (Institute for Reformation History) in 2025, by Lorenzo Paoli.
It draws on the TEI guidelines and publicly available digitizations provided by the Bibliothèque nationale de France (Gallica).
