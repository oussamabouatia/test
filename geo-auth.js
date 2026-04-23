// ============================================================
//  geo-auth.js — Gestion authentification côté client
//  Inclure dans chaque page pour afficher le bon état de connexion
// ============================================================

(function () {
  'use strict';

  const AUTH_KEY = 'geo_user';

  // ── Utilitaires ──
  function getUser() {
    try {
      const raw = localStorage.getItem(AUTH_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch { return null; }
  }

  function setUser(user) {
    localStorage.setItem(AUTH_KEY, JSON.stringify(user));
  }

  function clearUser() {
    localStorage.removeItem(AUTH_KEY);
  }

  // ── Injecter le bouton auth dans la nav ──
  function renderAuthUI() {
    const nav = document.querySelector('nav');
    if (!nav) return;

    // Supprimer un ancien auth-area s'il existe
    const old = document.getElementById('geo-auth-area');
    if (old) old.remove();

    const user = getUser();
    const area = document.createElement('div');
    area.id = 'geo-auth-area';
    area.style.cssText = 'display:flex;align-items:center;gap:8px;margin-left:8px;';

    if (user) {
      // ── État connecté ──
      area.innerHTML = `
        <div style="display:flex;align-items:center;gap:8px;">
          <div style="width:32px;height:32px;background:#dcfce7;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;color:#14532d;flex-shrink:0;" title="${user.name}">
            ${user.name.charAt(0).toUpperCase()}
          </div>
          <span style="font-size:13px;font-weight:600;color:#0f172a;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" class="auth-name-desktop">${user.name}</span>
          <button id="geo-logout-btn" style="font-family:'Plus Jakarta Sans',sans-serif;font-size:12px;font-weight:600;padding:5px 14px;background:none;color:#64748b;border:1.5px solid #e2e8f0;border-radius:99px;cursor:pointer;transition:all .18s;" onmouseover="this.style.borderColor='#dc2626';this.style.color='#dc2626';" onmouseout="this.style.borderColor='#e2e8f0';this.style.color='#64748b';">
            Déconnexion
          </button>
        </div>
      `;
    } else {
      // ── État déconnecté ──
      area.innerHTML = `
        <a href="login.html" style="font-family:'Plus Jakarta Sans',sans-serif;font-size:12px;font-weight:600;padding:6px 16px;background:#16a34a;color:#fff;border-radius:99px;text-decoration:none;transition:background .18s;display:inline-flex;align-items:center;gap:5px;" onmouseover="this.style.background='#14532d'" onmouseout="this.style.background='#16a34a'">
          <span style="font-size:14px;">👤</span> Connexion
        </a>
      `;
    }

    // Insérer avant le burger (nav-toggle) ou à la fin
    const toggle = nav.querySelector('.nav-toggle');
    if (toggle) {
      nav.insertBefore(area, toggle);
    } else {
      nav.appendChild(area);
    }

    // Événement déconnexion
    const logoutBtn = document.getElementById('geo-logout-btn');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', handleLogout);
    }
  }

  // ── Déconnexion ──
  async function handleLogout() {
    const btn = document.getElementById('geo-logout-btn');
    if (btn) {
      btn.textContent = '…';
      btn.disabled = true;
    }

    try {
      await fetch('api/auth/logout.php', { method: 'POST' });
    } catch (e) {
      // Même si le serveur est injoignable, on déconnecte côté client
    }

    clearUser();
    renderAuthUI();
  }

  // ── Vérifier la session côté serveur au chargement ──
  async function syncSession() {
    try {
      const res = await fetch('api/auth/me.php');
      const data = await res.json();

      if (data.logged_in && data.user) {
        setUser(data.user);
      } else {
        clearUser();
      }
    } catch (e) {
      // Pas de serveur = garder l'état localStorage tel quel
    }
    renderAuthUI();
  }

  // ── Init ──
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      renderAuthUI();
      // Sync avec le serveur en arrière-plan (non bloquant)
      syncSession();
    });
  } else {
    renderAuthUI();
    syncSession();
  }

  // Exposer globalement
  window.GeoAuth = { getUser, setUser, clearUser, renderAuthUI };

})();
