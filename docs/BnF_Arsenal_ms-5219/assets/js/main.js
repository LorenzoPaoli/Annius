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

document.addEventListener('DOMContentLoaded', () => {
  // CSS minimo per il popover (niente file CSS da toccare)
  const style = document.createElement('style');
  style.textContent = `
    .__tooltip {
      position: absolute;
      max-width: 28rem;
      padding: .5rem .6rem;
      border: 1px solid rgba(0,0,0,.15);
      border-radius: .375rem;
      background: #fff;
      box-shadow: 0 6px 24px rgba(0,0,0,.12);
      font-size: .925rem;
      line-height: 1.35;
      z-index: 9999;
    }
  `;
  document.head.appendChild(style);

  // Trasferisce title -> data-tooltip e disattiva il tooltip nativo
  const triggers = document.querySelectorAll('[title]');
  triggers.forEach(el => {
    const t = el.getAttribute('title');
    if (!t) return;
    el.dataset.tooltip = t;
    el.removeAttribute('title');
    if (el.tabIndex < 0) el.tabIndex = 0; // focus per tastiera
    el.setAttribute('aria-haspopup', 'dialog');
    el.setAttribute('aria-expanded', 'false');
  });

  let open = null; // { trigger, node }

  function closeTip() {
    if (!open) return;
    open.trigger.setAttribute('aria-expanded', 'false');
    open.node.remove();
    open = null;
  }

  function openTipFor(trigger) {
    closeTip();
    const text = trigger.dataset.tooltip;
    if (!text) return;

    const tip = document.createElement('div');
    tip.className = '__tooltip';
    tip.textContent = text;
    document.body.appendChild(tip);

    // Posizionamento semplice sotto al trigger
    const r = trigger.getBoundingClientRect();
    const top = window.scrollY + r.bottom + 8;
    let left = window.scrollX + r.left;

    // Evita overflow a destra
    const maxLeft = window.scrollX + document.documentElement.clientWidth - tip.offsetWidth - 8;
    if (left > maxLeft) left = Math.max(8, maxLeft);

    tip.style.top = `${top}px`;
    tip.style.left = `${left}px`;

    trigger.setAttribute('aria-expanded', 'true');
    open = { trigger, node: tip };
  }

  // Click: toggle sui trigger, click fuori chiude
  document.addEventListener('click', (e) => {
    const trigger = e.target.closest('[data-tooltip]');
    if (trigger) {
      if (open && open.trigger === trigger) closeTip();
      else openTipFor(trigger);
      return;
    }
    if (open && !e.target.closest('.__tooltip')) closeTip();
  });

  // Tastiera: Enter/Space apre/chiude; Esc chiude
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeTip();
    const el = document.activeElement;
    if ((e.key === 'Enter' || e.key === ' ') && el && el.dataset && el.dataset.tooltip) {
      e.preventDefault();
      if (open && open.trigger === el) closeTip();
      else openTipFor(el);
    }
  });

  // Mantiene il posizionamento su scroll/resize
  const reflow = () => { if (open) openTipFor(open.trigger); };
  window.addEventListener('scroll', reflow, { passive: true });
  window.addEventListener('resize', reflow);
});

