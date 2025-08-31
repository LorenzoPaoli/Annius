// assets/js/main.js
window.addEventListener('DOMContentLoaded', () => {
  const root = document.documentElement;

  // ================= THÈME (clair/sombre) =================
  const savedTheme = localStorage.getItem('theme');
  if (savedTheme) root.dataset.theme = savedTheme;

  document.getElementById('theme-toggle')?.addEventListener('click', () => {
    const next = root.dataset.theme === 'dark' ? 'light' : 'dark';
    root.dataset.theme = next;
    localStorage.setItem('theme', next);
  });

  // ================= TAILLE DE POLICE (A±) =================
  const getScale = () =>
    parseFloat(getComputedStyle(root).getPropertyValue('--scale')) || 1;
  const savedScale = localStorage.getItem('scale');
  if (savedScale) root.style.setProperty('--scale', savedScale);

  document.getElementById('font-plus')?.addEventListener('click', () => {
    const s = Math.min(1.5, getScale() + 0.1);
    root.style.setProperty('--scale', s);
    localStorage.setItem('scale', s);
  });
  document.getElementById('font-minus')?.addEventListener('click', () => {
    const s = Math.max(0.85, getScale() - 0.1);
    root.style.setProperty('--scale', s);
    localStorage.setItem('scale', s);
  });

  // ================= COPIER CITATION =================
  document.getElementById('cite-btn')?.addEventListener('click', () => {
    const cite = document.querySelector('#citation p')?.innerText || '';
    if (cite) {
      navigator.clipboard.writeText(cite);
      alert('Citation copiée !');
    }
  });

    // ================= RECHERCHE INTERNE (highlight) =================
  // attivalo solo se l'input ha data-highlight="1"
  const box = document.querySelector('#search[data-highlight="1"]');
  if (box) {
    const area = document.querySelector('main') || document.body;
    const nodes = [
      ...area.querySelectorAll('h1,h2,h3,p,li,td,th,span,.has-note'),
    ];
    box.addEventListener('input', () => {
      const q = box.value.trim().toLowerCase();
      nodes.forEach((n) => n.classList.remove('hit'));
      if (!q) return;
      nodes.forEach((n) => {
        const t = (n.textContent || '').toLowerCase();
        if (t.includes(q)) n.classList.add('hit');
      });
    });
  }

  // ================= LIGHTBOX (images) =================
  document.querySelectorAll('img').forEach((img) => {
    img.addEventListener('click', () => {
      const lb = document.querySelector('.lb');
      if (!lb) return;
      const lbImg = lb.querySelector('img');
      if (lbImg) {
        lbImg.src = img.src;
        lb.classList.add('on');
      }
    });
  });
  document.querySelector('.lb .x')?.addEventListener('click', () => {
    document.querySelector('.lb').classList.remove('on');
  });
});
