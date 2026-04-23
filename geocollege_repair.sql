-- ============================================================
--  geocollege_repair.sql
--  Crée uniquement les tables/vues manquantes
--  Importer dans phpMyAdmin → base geocollege → Import
-- ============================================================

USE geocollege;

-- ── Table theoremes ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS theoremes (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  slug        VARCHAR(100) NOT NULL UNIQUE,
  nom         VARCHAR(150) NOT NULL,
  niveau      ENUM('1AC','2AC','3AC') NOT NULL,
  categorie   VARCHAR(100),
  enonce      TEXT NOT NULL,
  `condition` TEXT,
  formule     VARCHAR(255),
  formes_liees TEXT,
  actif       TINYINT(1) DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── Table forme_theoreme ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS forme_theoreme (
  forme_id    INT NOT NULL,
  theoreme_id INT NOT NULL,
  PRIMARY KEY (forme_id, theoreme_id),
  FOREIGN KEY (forme_id)    REFERENCES formes(id)    ON DELETE CASCADE,
  FOREIGN KEY (theoreme_id) REFERENCES theoremes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── Données théorèmes ────────────────────────────────────────
INSERT IGNORE INTO theoremes (slug, nom, niveau, categorie, enonce, `condition`, formule, formes_liees) VALUES
(
  'pythagore',
  'Théorème de Pythagore',
  '2AC',
  'Triangle rectangle',
  'Dans un triangle rectangle, le carré de l\'hypoténuse est égal à la somme des carrés des deux autres côtés.',
  'Le triangle doit avoir un angle droit de 90°. Le côté opposé à l\'angle droit est l\'hypoténuse.',
  'a² + b² = c²',
  '["triangle-rectangle","carre","rectangle","losange"]'
),
(
  'thales',
  'Théorème de Thalès',
  '3AC',
  'Droites parallèles',
  'Si une droite est parallèle à un côté d\'un triangle et coupe les deux autres côtés, alors elle les coupe en segments proportionnels.',
  'Les droites (DE) et (BC) doivent être parallèles. Vérifier que (DE) ∥ (BC) avant d\'appliquer.',
  'AD/AB = AE/AC = DE/BC',
  '["triangle-quelconque","trapeze","parallelogramme"]'
);

-- ── Liaisons forme_theoreme ──────────────────────────────────
INSERT IGNORE INTO forme_theoreme (forme_id, theoreme_id)
SELECT f.id, t.id FROM formes f, theoremes t
WHERE f.slug = 'triangle-rectangle'  AND t.slug = 'pythagore';

INSERT IGNORE INTO forme_theoreme (forme_id, theoreme_id)
SELECT f.id, t.id FROM formes f, theoremes t
WHERE f.slug = 'carre'               AND t.slug = 'pythagore';

INSERT IGNORE INTO forme_theoreme (forme_id, theoreme_id)
SELECT f.id, t.id FROM formes f, theoremes t
WHERE f.slug = 'rectangle'           AND t.slug = 'pythagore';

INSERT IGNORE INTO forme_theoreme (forme_id, theoreme_id)
SELECT f.id, t.id FROM formes f, theoremes t
WHERE f.slug = 'losange'             AND t.slug = 'pythagore';

INSERT IGNORE INTO forme_theoreme (forme_id, theoreme_id)
SELECT f.id, t.id FROM formes f, theoremes t
WHERE f.slug = 'triangle-quelconque' AND t.slug = 'thales';

INSERT IGNORE INTO forme_theoreme (forme_id, theoreme_id)
SELECT f.id, t.id FROM formes f, theoremes t
WHERE f.slug = 'trapeze'             AND t.slug = 'thales';

INSERT IGNORE INTO forme_theoreme (forme_id, theoreme_id)
SELECT f.id, t.id FROM formes f, theoremes t
WHERE f.slug = 'parallelogramme'     AND t.slug = 'thales';

-- ── Vue formes (recrée si manquante) ─────────────────────────
CREATE OR REPLACE VIEW vue_formes AS
SELECT
  f.id,
  f.slug,
  f.nom,
  c.nom        AS categorie,
  c.label      AS categorie_label,
  f.niveau,
  f.description,
  f.proprietes,
  f.svg_viewbox,
  f.svg_elements,
  f.image_url,
  f.actif,
  f.created_at,
  f.updated_at
FROM formes f
JOIN categories c ON f.categorie_id = c.id;

-- ── Vue stats (recrée si manquante) ──────────────────────────
CREATE OR REPLACE VIEW vue_stats AS
SELECT
  (SELECT COUNT(*) FROM formes     WHERE actif = 1) AS total_formes,
  (SELECT COUNT(*) FROM formules)                   AS total_formules,
  (SELECT COUNT(*) FROM theoremes  WHERE actif = 1) AS total_theoremes,
  (SELECT COUNT(*) FROM admins)                     AS total_admins;

-- ── Vérification finale ───────────────────────────────────────
SELECT 'Tables creees:' AS '';
SHOW TABLES;

SELECT CONCAT('theoremes: ', COUNT(*), ' lignes') AS verification FROM theoremes;
SELECT CONCAT('forme_theoreme: ', COUNT(*), ' lignes') AS verification FROM forme_theoreme;
SELECT CONCAT('vue_formes: ', COUNT(*), ' lignes') AS verification FROM vue_formes;
