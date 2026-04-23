/* ============================================================
   geo-animations.js
   Logique d'animation des figures géométriques — GéoCollège
   À ajouter dans index.html et formes.html (avant </body>)
   ============================================================ */

(function () {
  'use strict';

  // ── 1. INTERSECTION OBSERVER ──────────────────────────────
  // Déclenche l'animation quand une figure entre dans le viewport

  const figureObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const container = entry.target;
        // Petit délai pour que l'animation soit visible
        setTimeout(() => {
          container.classList.add('fig-animate');
          animateEtapes(container);
        }, 80);
        figureObserver.unobserve(container);
      }
    });
  }, {
    threshold: 0.2,
    rootMargin: '0px 0px -40px 0px'
  });

  // ── 2. OBSERVER toutes les figures présentes ──────────────

  function observeFigures() {
    const selectors = [
      '.fd-figure',
      '.rp-fig',
      '.forme-figure',
      '.results-figure',
      '.theo-figure'
    ];
    selectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(fig => {
        if (!fig.classList.contains('fig-observed')) {
          fig.classList.add('fig-observed');
          figureObserver.observe(fig);
        }
      });
    });
  }

  // ── 3. ANIMATION ÉTAPES CALCULATEUR ──────────────────────
  // Chaque bloc d'étapes apparaît avec un délai progressif

  function animateEtapes(container) {
    const blocs = container.querySelectorAll?.('.etapes-bloc') ?? [];
    blocs.forEach((bloc, i) => {
      setTimeout(() => {
        bloc.classList.add('visible');
      }, i * 120);
    });
  }

  // Observer aussi les étapes dans le document entier
  function observeEtapes() {
    document.querySelectorAll('.etapes-bloc:not(.visible)').forEach((bloc, i) => {
      setTimeout(() => bloc.classList.add('visible'), i * 100);
    });
  }

  // ── 4. MUTATION OBSERVER ──────────────────────────────────
  // Détecte les nouveaux éléments ajoutés dynamiquement par JS
  // (cartes générées par renderCards, accordéons ouverts, etc.)

  const mutationObserver = new MutationObserver((mutations) => {
    let hasNewContent = false;
    mutations.forEach(m => {
      if (m.addedNodes.length > 0) hasNewContent = true;
    });
    if (hasNewContent) {
      setTimeout(() => {
        observeFigures();
        observeEtapes();
        attachHoverEffects();
      }, 50);
    }
  });

  mutationObserver.observe(document.body, {
    childList: true,
    subtree: true
  });

  // ── 5. LOADER GÉO ─────────────────────────────────────────
  // Remplace "Chargement…" par un loader animé

  function injectGeoLoader() {
    const targets = ['#cards-grid', '#formes-list'];
    targets.forEach(sel => {
      const el = document.querySelector(sel);
      if (!el) return;
      const txt = el.textContent.trim().toLowerCase();
      if (txt.includes('chargement') || txt.includes('loading')) {
        el.innerHTML = `
          <div class="geo-loader" style="grid-column:1/-1;">
            <svg viewBox="0 0 60 60" width="48" height="48">
              <polygon points="30,4 56,52 4,52"
                stroke="#16a34a" stroke-width="2.5"
                fill="#dcfce7" stroke-linejoin="round"/>
            </svg>
            <p>Chargement des formes…</p>
          </div>`;
      }
    });
  }

  // ── 6. HOVER INTERACTIF sur les SVG ──────────────────────
  // Ajoute des effets au survol des éléments SVG individuels

  function attachHoverEffects() {
    // Survol des polygons/rects/circles → highlight du côté
    document.querySelectorAll('.fd-figure svg, .rp-fig svg').forEach(svg => {
      if (svg.dataset.hoverAttached) return;
      svg.dataset.hoverAttached = 'true';

      const shapes = svg.querySelectorAll('polygon, rect:not([width="14"]):not([width="10"]), circle:not([r="3"])');
      shapes.forEach(shape => {
        shape.style.cursor = 'pointer';
        shape.style.transition = 'fill 0.2s, stroke-width 0.2s';

        shape.addEventListener('mouseenter', () => {
          shape.style.fill = '#bbf7d0';
          shape.style.strokeWidth = '3';
        });
        shape.addEventListener('mouseleave', () => {
          shape.style.fill = '';
          shape.style.strokeWidth = '';
        });
      });

      // Survol des lignes pointillées (hauteurs, diagonales)
      const lines = svg.querySelectorAll('line');
      lines.forEach(line => {
        line.addEventListener('mouseenter', () => {
          line.style.strokeWidth = '2';
          line.style.stroke = '#16a34a';
          line.style.opacity = '1';
        });
        line.addEventListener('mouseleave', () => {
          line.style.strokeWidth = '';
          line.style.stroke = '';
          line.style.opacity = '';
        });
      });
    });
  }

  // ── 7. ANIMATION PANEL RÉSULTATS ─────────────────────────
  // Relance l'animation quand le panneau s'ouvre

  function watchResultsPanel() {
    const panel = document.getElementById('results-panel');
    if (!panel) return;

    const panelObserver = new MutationObserver(() => {
      if (panel.classList.contains('open')) {
        // Reset + relance animation figure
        const fig = panel.querySelector('.rp-fig, .results-figure');
        if (fig) {
          fig.classList.remove('fig-animate', 'fig-observed');
          void fig.offsetWidth; // force reflow
          setTimeout(() => {
            fig.classList.add('fig-animate');
          }, 150);
        }
        // Animate étapes si présentes
        setTimeout(observeEtapes, 300);
      }
    });

    panelObserver.observe(panel, { attributes: true, attributeFilter: ['class'] });
  }

  // ── 8. ANIMATION ACCORDÉON ───────────────────────────────
  // Relance l'animation quand un accordéon s'ouvre dans formes.html

  function watchAccordions() {
    document.addEventListener('click', (e) => {
      const header = e.target.closest('.fd-header');
      if (!header) return;

      const card = header.closest('.forme-detail');
      if (!card) return;

      // Attendre que l'accordéon soit ouvert
      setTimeout(() => {
        if (card.classList.contains('open')) {
          const fig = card.querySelector('.fd-figure');
          if (fig) {
            fig.classList.remove('fig-animate');
            void fig.offsetWidth;
            setTimeout(() => fig.classList.add('fig-animate'), 50);
          }
          // Remettre à zéro les étapes
          card.querySelectorAll('.etapes-bloc').forEach(b => b.classList.remove('visible'));
        }
      }, 50);
    });
  }

  // ── 9. ANIMATION NOMBRE STATS ────────────────────────────
  // Les compteurs (11 formes, 30+ formules) s'incrémentent

  function animateCounters() {
    const counters = document.querySelectorAll(
      '#sn-formes, #sn-formules, .stat-num, #stat-formes, #stat-formules'
    );

    counters.forEach(el => {
      const raw = el.textContent.replace(/\D/g, '');
      const target = parseInt(raw, 10);
      if (!target || isNaN(target)) return;

      const suffix = el.textContent.replace(/[0-9]/g, '');
      let current = 0;
      const step = Math.ceil(target / 30);
      const interval = setInterval(() => {
        current = Math.min(current + step, target);
        el.textContent = current + suffix;
        if (current >= target) clearInterval(interval);
      }, 40);
    });
  }

  // ── 10. INIT ──────────────────────────────────────────────

  function init() {
    injectGeoLoader();
    observeFigures();
    attachHoverEffects();
    watchResultsPanel();
    watchAccordions();

    // Lancer les compteurs après un court délai
    // (le temps que les données soient chargées)
    setTimeout(animateCounters, 800);

    // Re-observer après chaque chargement fetch
    // (les cartes sont générées dynamiquement)
    setTimeout(() => {
      observeFigures();
      attachHoverEffects();
    }, 1200);
  }

  // Lancer quand le DOM est prêt
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
