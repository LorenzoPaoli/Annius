// BUMPA QUESTO NOME A OGNI DEPLOY CON CAMBI JS/CSS
const CACHE_NAME = 'site-cache-v5';

// (Opzionale) precache di base: NON mettere search-index.json qui
const PRECACHE_URLS = [
  './',
  './index_ms_5219.html',
  './assets/css/style.css',
  './assets/js/main.js',
  './assets/js/search.js',
];

// File da servire sempre "rete prima" (dati che vuoi aggiornati)
const NETWORK_FIRST = ['assets/search-index.json'];

// Install: precache + attiva subito
self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(c => c.addAll(PRECACHE_URLS).catch(()=>{}))
  );
});

// Activate: elimina cache vecchie e prendi controllo subito
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.map(k => k === CACHE_NAME ? null : caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

const isNetworkFirst = (url) =>
  NETWORK_FIRST.some(p => url.endsWith(p) || url.includes(p));

self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // limita allo stesso origin (GH Pages del repo)
  if (url.origin !== location.origin) return;

  // rete-prima per l'indice di ricerca (sempre fresco)
  if (isNetworkFirst(url.pathname)) {
    event.respondWith(
      fetch(request).then(res => {
        caches.open(CACHE_NAME).then(c => c.put(request, res.clone()));
        return res;
      }).catch(() => caches.match(request))
    );
    return;
  }

  // stale-while-revalidate per il resto (JS/CSS/HTML/immagini)
  event.respondWith(
    caches.match(request).then(cached => {
      const fetchPromise = fetch(request).then(res => {
        caches.open(CACHE_NAME).then(c => c.put(request, res.clone()));
        return res;
      }).catch(() => cached || Promise.reject('offline'));
      return cached || fetchPromise;
    })
  );
});
