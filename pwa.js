// ============================================
// GéoCollège — PWA Script (iOS + Android)
// Gère : Service Worker, bannière install, badge offline
// ============================================

(function() {
  // ── Détection plateforme ──
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) || 
    (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
  const isStandalone = window.matchMedia('(display-mode: standalone)').matches || 
    window.navigator.standalone === true;

  // ── Enregistrement du Service Worker ──
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('service-worker.js')
        .then(reg => console.log('[PWA] SW enregistré, scope:', reg.scope))
        .catch(err => console.warn('[PWA] SW erreur:', err));
    });
  }

  // ── Bannière d'installation ──
  let deferredPrompt = null;
  const banner = document.getElementById('install-banner');
  const installBtn = document.getElementById('install-btn');
  const closeBtn = document.getElementById('install-close');
  const bannerText = document.getElementById('install-text');

  // Ne pas afficher si déjà installé ou déjà refusé
  if (isStandalone || localStorage.getItem('geocollege-install-dismissed') === 'true') {
    if (banner) banner.style.display = 'none';
  }

  // ── iOS : afficher bannière avec instructions manuelles ──
  if (isIOS && !isStandalone) {
    if (localStorage.getItem('geocollege-install-dismissed') === 'true') return;
    if (banner && bannerText) {
      bannerText.innerHTML = 'Pour installer <strong>GéoCollège</strong> : appuyez sur <span style="font-size:18px;">⬆️</span> (Partager) puis <strong>"Sur l\'écran d\'accueil"</strong>';
      if (installBtn) installBtn.style.display = 'none'; // pas de bouton auto sur iOS
      banner.style.display = 'flex';
    }
  }

  // ── Android/Chrome : beforeinstallprompt ──
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    if (localStorage.getItem('geocollege-install-dismissed') === 'true') return;
    if (banner) {
      if (bannerText) bannerText.innerHTML = '📲 Installer <strong>GéoCollège</strong> sur votre appareil';
      if (installBtn) installBtn.style.display = 'inline-block';
      banner.style.display = 'flex';
    }
  });

  if (installBtn) {
    installBtn.addEventListener('click', async () => {
      if (!deferredPrompt) return;
      deferredPrompt.prompt();
      const result = await deferredPrompt.userChoice;
      console.log('[PWA] Install:', result.outcome);
      deferredPrompt = null;
      if (banner) banner.style.display = 'none';
    });
  }

  if (closeBtn) {
    closeBtn.addEventListener('click', () => {
      if (banner) banner.style.display = 'none';
      localStorage.setItem('geocollege-install-dismissed', 'true');
    });
  }

  // Cacher si installé
  window.addEventListener('appinstalled', () => {
    if (banner) banner.style.display = 'none';
    console.log('[PWA] App installée');
  });

  // ── Badge Hors-ligne ──
  const offlineBadge = document.getElementById('offline-badge');
  function updateOnlineStatus() {
    if (offlineBadge) {
      offlineBadge.style.display = navigator.onLine ? 'none' : 'inline-flex';
    }
  }
  window.addEventListener('online', updateOnlineStatus);
  window.addEventListener('offline', updateOnlineStatus);
  updateOnlineStatus();
})();
