// --- Loader indice (robusto a formati diversi) ---
let docs = [];
const indexPromise = fetch('assets/search-index.json', { cache: 'no-store' })
  .then(r => {
    if (!r.ok) throw new Error('Index HTTP ' + r.status);
    return r.json();
  })
  .then(j => {
    // Accettiamo sia {docs:[...]} sia [...] direttamente
    const arr = Array.isArray(j) ? j : (Array.isArray(j.docs) ? j.docs : []);
    // Normalizziamo i campi che useremo
    docs = arr.map(d => ({
      url:   d.url || d.href || d.path || '#',
      title: d.title || d.t || '',
      content: d.content || d.text || d.body || ''
    }));
  })
  .catch(err => {
    console.error('Search index load failed:', err);
    docs = [];
  });

// --- Normalizzazione per confronto case/diacritics-insensitive ---
const norm = s => (s || '')
  .toLowerCase()
  .normalize('NFD')
  .replace(/[\u0300-\u036f]/g, '');

// --- Suggerimenti nella barra ---
document.addEventListener('DOMContentLoaded', () => {
  const input = document.querySelector('#site-search input[name="q"]');
  const box   = document.getElementById('search-suggest');
  if (!input || !box) return;

  let lastQ = '';
  function renderSuggest(list) {
    box.innerHTML = '';
    if (!list.length) { box.setAttribute('aria-hidden', 'true'); box.hidden = true; return; }
    list.slice(0, 8).forEach(d => {
      const a = document.createElement('a');
      a.href = d.url;
      a.role = 'option';
      a.textContent = d.title || d.url;
      box.appendChild(a);
    });
    box.hidden = false;
    box.setAttribute('aria-hidden', 'false');
  }

  input.addEventListener('input', () => {
    const q = input.value.trim();
    if (q === lastQ) return;
    lastQ = q;
    if (!q) return renderSuggest([]);

    indexPromise.then(() => {
      const qn = norm(q);
      const hits = docs.filter(d =>
        norm(d.title).includes(qn) || norm(d.content).includes(qn)
      );
      renderSuggest(hits);
    });
  });

  document.addEventListener('click', (e) => {
    if (!box.contains(e.target) && e.target !== input) {
      box.hidden = true;
      box.setAttribute('aria-hidden', 'true');
    }
  });
});

// --- Rendering risultati su search.html ---
function renderResults() {
  const list    = document.getElementById('results');
  const summary = document.getElementById('search-summary');
  if (!list || !summary) return; // non siamo in search.html

  const params = new URLSearchParams(location.search);
  const q = (params.get('q') || '').trim();
  if (!q) { summary.textContent = 'Nessun termine di ricerca.'; return; }

  const qn = norm(q);
  const hits = docs.filter(d =>
    norm(d.title).includes(qn) || norm(d.content).includes(qn)
  ).map(d => {
    const text = d.content || '';
    const pos  = norm(text).indexOf(qn);
    let snippet = '';
    if (pos >= 0) {
      const start = Math.max(0, pos - 80);
      const end   = Math.min(text.length, pos + q.length + 80);
      snippet = text.slice(start, end).replace(/\s+/g, ' ').trim();
    }
    return { ...d, snippet };
  });

  summary.textContent = `${hits.length} risultato${hits.length !== 1 ? 'i' : ''} per « ${q} »`;
  list.innerHTML = '';
  hits.forEach(d => {
    const li = document.createElement('li');
    li.innerHTML = `<a href="${d.url}">${d.title || d.url}</a>${d.snippet ? `<p>${d.snippet}…</p>` : ''}`;
    list.appendChild(li);
  });
}

indexPromise.then(renderResults);
