const CACHE = 'ms5219-v1';
const ASSETS = [
  '/', 'index_ms_5219.html', 'a-propos.html', 'auctoritates.html', 'genealogie.html',
  'transcription_ms_5219_d.html', 'transcription_ms_5219_sd.html',
  'assets/css/style.css',
  // aggiungi immagini essenziali e JS
];

self.addEventListener('install', e=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)));
});
self.addEventListener('fetch', e=>{
  e.respondWith(caches.match(e.request).then(r=> r || fetch(e.request)));
});
