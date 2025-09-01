# BnF Arsenal MS-5219 réserve — Digital edition (ff. 1r–8r)

This repository contains the source and outputs for a static website that publishes a **digital edition of folios 1r–8r** from *BnF, Bibliothèque de l’Arsenal, MS-5219 réserve*: a French **translation with commentary** of portions of Annius of Viterbo’s *Antiquitates*, prepared by **Robert Frescher** (ca. 1510–1511).  
The site’s content is **in French**; this README is in English for wider accessibility.

- **Scientific editor:** Lorenzo Paoli (FNS Scientific Collaborator), Institute for Reformation History, University of Geneva  
- **Edition date:** 26 May 2025  
- **License:** CC BY 4.0  
- **Manuscript (full digitization):** available on Gallica (BnF)  
- **Scope:** graphematic and semi-diplomatic transcriptions (HTML and PDF), contextual pages (*À propos*, *Auctoritates*, *Généalogie*), images, OCR outputs, and a lightweight client-side search.


## Folder structure (current)

```

/
├─ index_ms_5219.html
├─ a-propos.html
├─ auctoritates.html
├─ genealogie.html
├─ search.html
│
├─ transcription_ms_5219_d.html
├─ transcription_ms_5219_sd.html
│
├─ assets/
│  ├─ css/style.css
│  ├─ js/main.js
│  ├─ js/search.js
│  ├─ js/service-worker.js
│  ├─ img/
│  ├─ facs/
│  ├─ pdf/
│  └─ search-index.json
│
├─ DATA_OCR/
│  ├─ *.png
│  └─ *.xml
│
├─ xml/
│  ├─ ms_5219_d.xml
│  └─ ms_5219_sd.xml
│
├─ xsl/
│  ├─ tei2html.xsl
│  └─ tei2tex_crit.xsl
│
├─ latex/
│  ├─ ms_5219_d.tex
│  └─ ms_5219_sd.tex
│
├─ data/
│  └─ list_person.csv
│
├─ schema/
│  └─ ms5219.odd
│
├─ scripts/
│  ├─ transform_tei2html.ps1
│  ├─ transform_tei2html_sd.ps1
│  ├─ transform-tei2tex.ps1
│  └─ Build-SearchIndex.ps1
│
├─ notes/
│  └─ prompt_powershell.txt
│
├─ assets/citation.cff
└─ README.md

```

## What’s on the site

- **Transcriptions (HTML)** — graphematic and semi-diplomatic variants, with UI tools (switcher, themes, font size, highlights, lightbox).  
- **Context pages** — `a-propos.html`, `auctoritates.html`, `genealogie.html`.  
- **PDF outputs** — generated with XeLaTeX, available in `assets/pdf/`.  
- **Facsimiles** — high-resolution manuscript images (`assets/facs/`).  
- **OCR data** — raw outputs in `DATA_OCR/` (uncorrected).  

---

## License

Content is released under **Creative Commons Attribution 4.0 International (CC BY 4.0)**.  
👉 https://creativecommons.org/licenses/by/4.0/

---

## Citation

> Lorenzo Paoli (ed.), *Édition numérique du MS-5219 réserve (ff. 1r–8r)*, Université de Genève, 2025. CC BY 4.0.  
> Available at: https://lorenzopaoli.github.io/Annius/BnF_Arsenal_ms-5219/

---

## Acknowledgments

This edition was developed within the University of Geneva (Institute for Reformation History, ARCHEOPOL project) in 2025.  
It draws on the TEI guidelines and the digitization provided by the Bibliothèque nationale de France (Gallica).
