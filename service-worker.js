// ============================================
// GéoCollège — Service Worker (PWA)
// Cache name: geocollege-v1
// Stratégie : Cache First (statique) + Network First (API)
// ============================================

const CACHE_NAME = 'geocollege-v2';

// Ressources statiques à pré-cacher lors de l'installation
const STATIC_ASSETS = [
  './index.html',
  './formes.html',
  './theoremes.html',
  './exercices.html',
  './geo-animations.css',
  './geo-animations.js',
  './pwa.js',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './manifest.json',
  // Données offline (JSON statique)
  './data/formes.json',
  './data/exercices.json',
  './data/theoremes.json'
];

// ── INSTALL ──────────────────────────────────
self.addEventListener('install', (event) => {
  console.log('[SW] Install — mise en cache des ressources statiques');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(STATIC_ASSETS))
      .then(() => self.skipWaiting())
      .catch((err) => console.error('[SW] Erreur cache install:', err))
  );
});

// ── ACTIVATE ─────────────────────────────────
self.addEventListener('activate', (event) => {
  console.log('[SW] Activate — nettoyage des anciens caches');
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => {
            console.log('[SW] Suppression ancien cache:', key);
            return caches.delete(key);
          })
      ))
      .then(() => self.clients.claim())
  );
});

// ── FETCH ────────────────────────────────────
self.addEventListener('fetch', (event) => {
  // Ignorer les requêtes non-GET
  if (event.request.method !== 'GET') return;

  // Tout en Cache First (plus d'API serveur)
  event.respondWith(cacheFirst(event.request));
});

// ── Stratégie : Cache First (ressources statiques) ──
async function cacheFirst(request) {
  try {
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }

    const networkResponse = await fetch(request);
    // Mettre en cache dynamiquement les nouvelles ressources statiques
    if (networkResponse.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch (error) {
    // Fallback hors-ligne
    return offlineFallback(request);
  }
}

// ── Stratégie : Network First (API) ──
async function networkFirst(request) {
  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      // Mettre à jour le cache avec la réponse réseau
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch (error) {
    // Pas de réseau → essayer le cache
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }
    // Aucun cache disponible → fallback
    return offlineFallback(request);
  }
}

// ── Fallback hors-ligne ──
function offlineFallback(request) {
  // Si c'est une requête de page HTML, renvoyer une page d'erreur propre
  if (request.headers.get('accept')?.includes('text/html')) {
    return new Response(`
      <!DOCTYPE html>
      <html lang="fr">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hors-ligne — GéoCollège</title>
        <style>
          *{box-sizing:border-box;margin:0;padding:0;}
          body{font-family:'Segoe UI',sans-serif;background:#f8fafc;display:flex;align-items:center;justify-content:center;min-height:100vh;padding:24px;text-align:center;}
          .box{max-width:400px;}
          .icon{font-size:64px;margin-bottom:20px;}
          h1{font-size:22px;color:#14532d;margin-bottom:12px;}
          p{color:#64748b;font-size:15px;line-height:1.6;margin-bottom:24px;}
          .btn{display:inline-block;padding:12px 28px;background:#16a34a;color:#fff;border:none;border-radius:16px;font-size:14px;font-weight:600;cursor:pointer;text-decoration:none;transition:background .2s;}
          .btn:hover{background:#14532d;}
        </style>
      </head>
      <body>
        <div class="box">
          <div class="icon">📡</div>
          <h1>Vous êtes hors-ligne</h1>
          <p>Cette page n'est pas disponible en cache. Vérifiez votre connexion Internet et réessayez.</p>
          <button class="btn" onclick="location.reload()">Réessayer</button>
        </div>
      </body>
      </html>
    `, {
      status: 503,
      statusText: 'Service Unavailable',
      headers: { 'Content-Type': 'text/html; charset=utf-8' }
    });
  }

  // Pour les requêtes JSON (API), renvoyer une erreur JSON
  if (request.headers.get('accept')?.includes('application/json')) {
    return new Response(
      JSON.stringify({ error: 'Hors-ligne', message: 'Données non disponibles en cache.' }),
      { status: 503, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // Fallback générique
  return new Response('Hors-ligne', { status: 503 });
}
