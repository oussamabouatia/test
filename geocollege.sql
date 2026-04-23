-- ============================================================
--  GeoCollege V2 — Base de données MySQL
--  Importer dans phpMyAdmin : Import > choisir ce fichier
-- ============================================================

CREATE DATABASE IF NOT EXISTS geocollege
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE geocollege;

-- ============================================================
--  TABLE: admins
--  Stocke les comptes professeurs autorisés
-- ============================================================
CREATE TABLE IF NOT EXISTS admins (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nom         VARCHAR(100) NOT NULL,
  email       VARCHAR(150) NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,   -- mot de passe hashé avec password_hash()
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Compte admin par défaut : email=admin@geocollege.ma / password=Admin1234
-- Le mot de passe est hashé avec PASSWORD_BCRYPT
INSERT INTO admins (nom, email, password) VALUES
(
  'Administrateur',
  'admin@geocollege.ma',
  '$2y$10$EOKQ4ALvn6ZDp1YGkWrgP.YbAg6LMeCHuKVJpctnD9zE8qZONxeBq'
);
-- Note: ce hash correspond au mot de passe "Admin1234"


-- ============================================================
--  TABLE: categories
--  triangle / quadrilatere / cercle
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  id    INT AUTO_INCREMENT PRIMARY KEY,
  nom   VARCHAR(50) NOT NULL UNIQUE,
  label VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categories (nom, label) VALUES
('triangle',     'Triangles'),
('quadrilatere', 'Quadrilatères'),
('cercle',       'Cercles');


-- ============================================================
--  TABLE: formes
--  Toutes les formes géométriques
-- ============================================================
CREATE TABLE IF NOT EXISTS formes (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  slug          VARCHAR(100) NOT NULL UNIQUE,   -- ex: triangle-rectangle
  nom           VARCHAR(150) NOT NULL,           -- ex: Triangle rectangle
  categorie_id  INT NOT NULL,
  niveau        ENUM('1AC','2AC','3AC') NOT NULL,
  description   TEXT NOT NULL,
  proprietes    TEXT,                            -- JSON array de strings
  svg_viewbox   VARCHAR(50) DEFAULT '0 0 120 120',
  svg_elements  TEXT,                            -- code SVG brut
  image_url     VARCHAR(255) DEFAULT NULL,       -- chemin image uploadée
  actif         TINYINT(1) DEFAULT 1,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (categorie_id) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
--  TABLE: formules
--  Les formules liées à chaque forme
-- ============================================================
CREATE TABLE IF NOT EXISTS formules (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  forme_id     INT NOT NULL,
  type_formule VARCHAR(50) NOT NULL,    -- Aire / Périmètre / Diagonale / etc.
  formule      VARCHAR(200) NOT NULL,   -- ex: b × h ÷ 2
  latex        VARCHAR(200),            -- ex: A = \frac{b \times h}{2}
  exemple_vals TEXT,                    -- JSON: {"b":6,"h":4}
  exemple_res  VARCHAR(100),            -- ex: 12 cm²
  exemple_note VARCHAR(255),            -- note si pas de calcul direct
  ordre        INT DEFAULT 0,           -- ordre d'affichage
  FOREIGN KEY (forme_id) REFERENCES formes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
--  TABLE: theoremes
--  Pythagore, Thalès, etc.
-- ============================================================
CREATE TABLE IF NOT EXISTS theoremes (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  slug        VARCHAR(100) NOT NULL UNIQUE,
  nom         VARCHAR(150) NOT NULL,
  niveau      ENUM('1AC','2AC','3AC') NOT NULL,
  categorie   VARCHAR(100),
  enonce      TEXT NOT NULL,
  condition   TEXT,
  formule     VARCHAR(255),
  formes_liees TEXT,   -- JSON array de slugs
  actif       TINYINT(1) DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
--  TABLE: forme_theoreme
--  Liaison many-to-many entre formes et theoremes
-- ============================================================
CREATE TABLE IF NOT EXISTS forme_theoreme (
  forme_id    INT NOT NULL,
  theoreme_id INT NOT NULL,
  PRIMARY KEY (forme_id, theoreme_id),
  FOREIGN KEY (forme_id)    REFERENCES formes(id)    ON DELETE CASCADE,
  FOREIGN KEY (theoreme_id) REFERENCES theoremes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
--  DONNÉES: Insertion des 11 formes
-- ============================================================

-- 1. Triangle rectangle
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('triangle-rectangle', 'Triangle rectangle', 1, '2AC',
 'Triangle possédant un angle droit de 90°. Le côté opposé à l\'angle droit s\'appelle l\'hypoténuse.',
 '["Un angle droit exactement","L\'hypoténuse est le côté le plus long","Lié au théorème de Pythagore"]',
 '0 0 120 110',
 '<polygon points="10,100 110,100 10,10" stroke="#16a34a" stroke-width="2" fill="#dcfce7" stroke-linejoin="round"/><rect x="10" y="90" width="10" height="10" fill="none" stroke="#16a34a" stroke-width="1.5"/><text x="60" y="115" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">b</text><text x="2" y="58" font-size="11" fill="#64748b" font-family="sans-serif">h</text><text x="70" y="52" font-size="11" fill="#64748b" font-family="sans-serif">c</text>'
);

-- 2. Triangle équilatéral
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('triangle-equilateral', 'Triangle équilatéral', 1, '1AC',
 'Triangle avec trois côtés égaux et trois angles égaux de 60° chacun.',
 '["3 côtés égaux","3 angles de 60°","3 axes de symétrie"]',
 '0 0 120 110',
 '<polygon points="60,8 110,100 10,100" stroke="#16a34a" stroke-width="2" fill="#dcfce7" stroke-linejoin="round"/><line x1="60" y1="8" x2="60" y2="100" stroke="#16a34a" stroke-width="1" stroke-dasharray="4 3"/><text x="60" y="115" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">a</text><text x="64" y="55" font-size="11" fill="#64748b" font-family="sans-serif">h</text>'
);

-- 3. Triangle isocèle
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('triangle-isocele', 'Triangle isocèle', 1, '1AC',
 'Triangle avec deux côtés égaux appelés côtés principaux. La base est le côté différent.',
 '["2 côtés égaux","2 angles à la base égaux","1 axe de symétrie"]',
 '0 0 120 110',
 '<polygon points="60,8 108,100 12,100" stroke="#16a34a" stroke-width="2" fill="#dcfce7" stroke-linejoin="round"/><line x1="60" y1="8" x2="60" y2="100" stroke="#16a34a" stroke-width="1" stroke-dasharray="4 3"/><text x="60" y="115" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">b</text><text x="24" y="55" font-size="11" fill="#64748b" font-family="sans-serif">a</text><text x="88" y="55" font-size="11" fill="#64748b" font-family="sans-serif">a</text>'
);

-- 4. Triangle quelconque
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('triangle-quelconque', 'Triangle quelconque', 1, '1AC',
 'Triangle sans contrainte particulière sur ses côtés ni ses angles.',
 '["La somme des angles = 180°","Le côté le plus grand est opposé au plus grand angle","Inégalité triangulaire: a + b > c"]',
 '0 0 120 110',
 '<polygon points="15,100 105,100 75,10" stroke="#16a34a" stroke-width="2" fill="#dcfce7" stroke-linejoin="round"/><line x1="75" y1="10" x2="75" y2="100" stroke="#16a34a" stroke-width="1" stroke-dasharray="4 3"/><rect x="75" y="90" width="10" height="10" fill="none" stroke="#16a34a" stroke-width="1.5"/><text x="60" y="115" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">b</text><text x="80" y="58" font-size="11" fill="#64748b" font-family="sans-serif">h</text>'
);

-- 5. Carré
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('carre', 'Carré', 2, '1AC',
 'Quadrilatère avec 4 côtés égaux et 4 angles droits de 90°.',
 '["4 côtés égaux","4 angles droits de 90°","4 axes de symétrie","Diagonales égales et perpendiculaires"]',
 '0 0 120 120',
 '<rect x="10" y="10" width="100" height="100" stroke="#16a34a" stroke-width="2" fill="#dcfce7"/><rect x="10" y="10" width="14" height="14" fill="none" stroke="#16a34a" stroke-width="1.5"/><text x="60" y="125" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">c</text><text x="2" y="65" font-size="11" fill="#64748b" font-family="sans-serif">c</text>'
);

-- 6. Rectangle
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('rectangle', 'Rectangle', 2, '1AC',
 'Quadrilatère avec 4 angles droits. Les côtés opposés sont égaux et parallèles.',
 '["4 angles droits","Côtés opposés égaux et parallèles","2 axes de symétrie","Diagonales égales"]',
 '0 0 140 100',
 '<rect x="10" y="10" width="120" height="80" stroke="#16a34a" stroke-width="2" fill="#dcfce7"/><rect x="10" y="10" width="14" height="14" fill="none" stroke="#16a34a" stroke-width="1.5"/><text x="70" y="105" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">L</text><text x="2" y="55" font-size="11" fill="#64748b" font-family="sans-serif">l</text>'
);

-- 7. Parallélogramme
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('parallelogramme', 'Parallélogramme', 2, '1AC',
 'Quadrilatère dont les côtés opposés sont parallèles et égaux deux à deux.',
 '["Côtés opposés parallèles et égaux","Angles opposés égaux","Diagonales se coupent en leur milieu","Centre de symétrie"]',
 '0 0 130 100',
 '<polygon points="25,90 115,90 105,14 15,14" stroke="#16a34a" stroke-width="2" fill="#dcfce7" stroke-linejoin="round"/><line x1="25" y1="14" x2="25" y2="90" stroke="#16a34a" stroke-width="1" stroke-dasharray="4 3"/><rect x="25" y="76" width="10" height="10" fill="none" stroke="#16a34a" stroke-width="1.5"/><text x="65" y="105" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">b</text><text x="14" y="55" font-size="11" fill="#64748b" font-family="sans-serif">h</text>'
);

-- 8. Losange
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('losange', 'Losange', 2, '2AC',
 'Quadrilatère avec 4 côtés égaux. Ses diagonales sont perpendiculaires et se coupent en leur milieu.',
 '["4 côtés égaux","Diagonales perpendiculaires","Diagonales se coupent en leur milieu","2 axes de symétrie"]',
 '0 0 120 120',
 '<polygon points="60,6 114,60 60,114 6,60" stroke="#16a34a" stroke-width="2" fill="#dcfce7" stroke-linejoin="round"/><line x1="60" y1="6" x2="60" y2="114" stroke="#16a34a" stroke-width="1" stroke-dasharray="4 3"/><line x1="6" y1="60" x2="114" y2="60" stroke="#16a34a" stroke-width="1" stroke-dasharray="4 3"/><text x="60" y="125" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">d1</text><text x="118" y="64" font-size="11" fill="#64748b" font-family="sans-serif">d2</text>'
);

-- 9. Trapèze
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('trapeze', 'Trapèze', 2, '2AC',
 'Quadrilatère avec exactement une paire de côtés parallèles appelés bases.',
 '["Une paire de côtés parallèles","La grande base est notée B, la petite b","La hauteur h est perpendiculaire aux bases"]',
 '0 0 130 100',
 '<polygon points="20,90 110,90 90,14 40,14" stroke="#16a34a" stroke-width="2" fill="#dcfce7" stroke-linejoin="round"/><line x1="65" y1="14" x2="65" y2="90" stroke="#16a34a" stroke-width="1" stroke-dasharray="4 3"/><text x="65" y="105" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">B</text><text x="65" y="10" font-size="11" fill="#64748b" text-anchor="middle" font-family="sans-serif">b</text><text x="72" y="56" font-size="11" fill="#64748b" font-family="sans-serif">h</text>'
);

-- 10. Cercle
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('cercle', 'Cercle', 3, '2AC',
 'Ensemble des points du plan situés à égale distance d\'un point fixe appelé centre.',
 '["Tous les points sont à égale distance du centre","Le diamètre = 2 × rayon","Infinité d\'axes de symétrie"]',
 '0 0 120 120',
 '<circle cx="60" cy="60" r="50" stroke="#16a34a" stroke-width="2" fill="#dcfce7"/><line x1="60" y1="60" x2="110" y2="60" stroke="#16a34a" stroke-width="1.5" stroke-dasharray="4 2"/><circle cx="60" cy="60" r="3" fill="#16a34a"/><text x="80" y="54" font-size="11" fill="#64748b" font-family="sans-serif">r</text><text x="56" y="72" font-size="10" fill="#16a34a" font-family="sans-serif">O</text>'
);

-- 11. Disque
INSERT INTO formes (slug, nom, categorie_id, niveau, description, proprietes, svg_viewbox, svg_elements) VALUES
('disque', 'Disque', 3, '2AC',
 'Surface délimitée par un cercle. Le disque inclut tous les points à l\'intérieur du cercle.',
 '["Surface intérieure du cercle","Délimité par la circonférence","Rayon r depuis le centre"]',
 '0 0 120 120',
 '<circle cx="60" cy="60" r="50" stroke="#16a34a" stroke-width="2" fill="#4ade80"/><line x1="60" y1="60" x2="110" y2="60" stroke="#14532d" stroke-width="1.5" stroke-dasharray="4 2"/><circle cx="60" cy="60" r="3" fill="#14532d"/><text x="80" y="54" font-size="11" fill="#14532d" font-family="sans-serif">r</text>'
);


-- ============================================================
--  DONNÉES: Formules pour chaque forme
-- ============================================================

-- Triangle rectangle
SET @f = (SELECT id FROM formes WHERE slug='triangle-rectangle');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      'b × h ÷ 2',    'A = \\frac{b \\times h}{2}', '{"b":6,"h":4}', '12 cm²', 1),
(@f, 'Périmètre', 'a + b + c',    'P = a + b + c',               NULL, NULL, 2),
(@f, 'Pythagore', 'a² + b² = c²', 'a^2 + b^2 = c^2',            '{"a":3,"b":4}', 'c = 5 cm', 3);

-- Triangle équilatéral
SET @f = (SELECT id FROM formes WHERE slug='triangle-equilateral');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      '(a × h) ÷ 2',  'A = \\frac{a \\times h}{2}',    '{"a":6,"h":5.2}', '15.6 cm²', 1),
(@f, 'Périmètre', '3 × a',        'P = 3a',                         '{"a":6}', '18 cm', 2),
(@f, 'Hauteur',   'a × √3 ÷ 2',  'h = \\frac{a\\sqrt{3}}{2}',     '{"a":6}', 'h ≈ 5.2 cm', 3);

-- Triangle isocèle
SET @f = (SELECT id FROM formes WHERE slug='triangle-isocele');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      '(b × h) ÷ 2', 'A = \\frac{b \\times h}{2}', '{"b":8,"h":5}', '20 cm²', 1),
(@f, 'Périmètre', '2 × a + b',   'P = 2a + b',                  '{"a":6,"b":8}', '20 cm', 2);

-- Triangle quelconque
SET @f = (SELECT id FROM formes WHERE slug='triangle-quelconque');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      '(b × h) ÷ 2',  'A = \\frac{b \\times h}{2}', '{"b":10,"h":6}', '30 cm²', 1),
(@f, 'Périmètre', 'a + b + c',    'P = a + b + c',               '{"a":5,"b":7,"c":6}', '18 cm', 2),
(@f, 'Angles',    'A + B + C = 180°', 'A + B + C = 180°',        NULL, NULL, 3);

-- Carré
SET @f = (SELECT id FROM formes WHERE slug='carre');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      'c²',      'A = c^2',            '{"c":5}', '25 cm²', 1),
(@f, 'Périmètre', '4 × c',   'P = 4c',             '{"c":5}', '20 cm', 2),
(@f, 'Diagonale', 'c × √2',  'd = c\\sqrt{2}',     '{"c":5}', 'd ≈ 7.07 cm', 3);

-- Rectangle
SET @f = (SELECT id FROM formes WHERE slug='rectangle');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      'L × l',        'A = L \\times l',             '{"L":8,"l":5}', '40 cm²', 1),
(@f, 'Périmètre', '2 × (L + l)',  'P = 2(L + l)',                '{"L":8,"l":5}', '26 cm', 2),
(@f, 'Diagonale', '√(L² + l²)',   'd = \\sqrt{L^2 + l^2}',      '{"L":3,"l":4}', 'd = 5 cm', 3);

-- Parallélogramme
SET @f = (SELECT id FROM formes WHERE slug='parallelogramme');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      'b × h',       'A = b \\times h',  '{"b":8,"h":5}', '40 cm²', 1),
(@f, 'Périmètre', '2 × (a + b)', 'P = 2(a + b)',     '{"a":6,"b":8}', '28 cm', 2);

-- Losange
SET @f = (SELECT id FROM formes WHERE slug='losange');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      '(d1 × d2) ÷ 2', 'A = \\frac{d_1 \\times d_2}{2}', '{"d1":10,"d2":6}', '30 cm²', 1),
(@f, 'Périmètre', '4 × c',          'P = 4c',                          '{"c":5}', '20 cm', 2);

-- Trapèze
SET @f = (SELECT id FROM formes WHERE slug='trapeze');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      '(B + b) × h ÷ 2', 'A = \\frac{(B+b) \\times h}{2}', '{"B":10,"b":6,"h":4}', '32 cm²', 1),
(@f, 'Périmètre', 'B + b + c1 + c2', 'P = B + b + c_1 + c_2',          NULL, NULL, 2);

-- Cercle
SET @f = (SELECT id FROM formes WHERE slug='cercle');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',      'π × r²',    'A = \\pi r^2',  '{"r":5}', '≈ 78.54 cm²', 1),
(@f, 'Périmètre', '2 × π × r', 'P = 2\\pi r',   '{"r":5}', '≈ 31.42 cm', 2),
(@f, 'Diamètre',  '2 × r',     'd = 2r',         '{"r":5}', '10 cm', 3);

-- Disque
SET @f = (SELECT id FROM formes WHERE slug='disque');
INSERT INTO formules (forme_id, type_formule, formule, latex, exemple_vals, exemple_res, ordre) VALUES
(@f, 'Aire',          'π × r²',    'A = \\pi r^2', '{"r":4}', '≈ 50.27 cm²', 1),
(@f, 'Circonférence', '2 × π × r', 'C = 2\\pi r',  '{"r":4}', '≈ 25.13 cm', 2);


-- ============================================================
--  DONNÉES: Théorèmes
-- ============================================================
INSERT INTO theoremes (slug, nom, niveau, categorie, enonce, condition, formule, formes_liees) VALUES
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

-- Liaisons forme_theoreme
SET @pyth  = (SELECT id FROM theoremes WHERE slug='pythagore');
SET @thale = (SELECT id FROM theoremes WHERE slug='thales');

INSERT INTO forme_theoreme (forme_id, theoreme_id) VALUES
((SELECT id FROM formes WHERE slug='triangle-rectangle'),  @pyth),
((SELECT id FROM formes WHERE slug='carre'),               @pyth),
((SELECT id FROM formes WHERE slug='rectangle'),           @pyth),
((SELECT id FROM formes WHERE slug='losange'),             @pyth),
((SELECT id FROM formes WHERE slug='triangle-quelconque'), @thale),
((SELECT id FROM formes WHERE slug='trapeze'),             @thale),
((SELECT id FROM formes WHERE slug='parallelogramme'),     @thale);


-- ============================================================
--  VUES utiles pour les requêtes fréquentes
-- ============================================================

-- Vue: formes avec leur catégorie en texte
CREATE OR REPLACE VIEW vue_formes AS
SELECT
  f.id,
  f.slug,
  f.nom,
  c.nom       AS categorie,
  c.label     AS categorie_label,
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

-- Vue: stats pour le dashboard admin
CREATE OR REPLACE VIEW vue_stats AS
SELECT
  (SELECT COUNT(*) FROM formes    WHERE actif = 1)  AS total_formes,
  (SELECT COUNT(*) FROM formules)                    AS total_formules,
  (SELECT COUNT(*) FROM theoremes WHERE actif = 1)  AS total_theoremes,
  (SELECT COUNT(*) FROM admins)                      AS total_admins;


-- ============================================================
--  INDEX pour meilleures performances
-- ============================================================
CREATE INDEX idx_formes_niveau    ON formes(niveau);
CREATE INDEX idx_formes_categorie ON formes(categorie_id);
CREATE INDEX idx_formes_actif     ON formes(actif);
CREATE INDEX idx_formules_forme   ON formules(forme_id);

-- ============================================================
--  FIN — BDD prête !
--  Compte admin : admin@geocollege.ma / Admin1234
-- ============================================================
