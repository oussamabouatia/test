-- ============================================================
--  hints_system.sql — Système d'indices progressifs
-- ============================================================

USE geocollege;

-- ============================================================
--  TABLE: hints — Indices par exercice (step-by-step)
-- ============================================================
CREATE TABLE IF NOT EXISTS hints (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  exercise_id   INT NOT NULL,
  step_order    INT NOT NULL DEFAULT 1,
  content       TEXT NOT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_exercise_step (exercise_id, step_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_hints_exercise ON hints(exercise_id);

-- ============================================================
--  Ajouter hints_used à exercise_results
-- ============================================================
ALTER TABLE exercise_results
  ADD COLUMN hints_used INT NOT NULL DEFAULT 0 AFTER time_spent;

-- ============================================================
--  Ajouter type d'exercice à la table exercices (si existe)
-- ============================================================
-- Note: les exercices sont dans la DB via vue_exercices
-- On ajoute le support de type dans les données JSON

-- ============================================================
--  DONNÉES: Hints pour les exercices existants
-- ============================================================

-- Ex 4: Aire d'un carré
INSERT INTO hints (exercise_id, step_order, content) VALUES
(4, 1, '💡 Quelle est la formule de l''aire d''un carré ?'),
(4, 2, '📐 L''aire d''un carré = côté × côté = c²'),
(4, 3, '🔢 Remplace c par la valeur donnée : c = 7');

-- Ex 6: Aire d'un rectangle
INSERT INTO hints (exercise_id, step_order, content) VALUES
(6, 1, '💡 Pour un rectangle, quelles dimensions utilise-t-on ?'),
(6, 2, '📐 Aire = Longueur × largeur = L × l'),
(6, 3, '🔢 Substitue : A = 8 × 5');

-- Ex 12: Périmètre triangle équilatéral
INSERT INTO hints (exercise_id, step_order, content) VALUES
(12, 1, '💡 Un triangle équilatéral a combien de côtés égaux ?'),
(12, 2, '📐 Le périmètre = 3 × côté'),
(12, 3, '🔢 P = 3 × 9');

-- Ex 5: Périmètre d'un carré
INSERT INTO hints (exercise_id, step_order, content) VALUES
(5, 1, '💡 Combien de côtés a un carré ?'),
(5, 2, '📐 Périmètre = 4 × côté'),
(5, 3, '🔢 P = 4 × 12');

-- Ex 7: Périmètre rectangle
INSERT INTO hints (exercise_id, step_order, content) VALUES
(7, 1, '💡 Le périmètre est la somme de tous les côtés'),
(7, 2, '📐 P = 2 × (L + l)'),
(7, 3, '🔢 P = 2 × (10 + 3) = 2 × 13');

-- Ex 13: Aire parallélogramme
INSERT INTO hints (exercise_id, step_order, content) VALUES
(13, 1, '💡 L''aire d''un parallélogramme ressemble à celle d''un rectangle'),
(13, 2, '📐 Aire = base × hauteur (attention : la hauteur est perpendiculaire)'),
(13, 3, '🔢 A = 8 × 5');

-- Ex 1: Aire triangle rectangle
INSERT INTO hints (exercise_id, step_order, content) VALUES
(1, 1, '💡 L''aire d''un triangle est la moitié de celle d''un rectangle'),
(1, 2, '📐 Formule : A = (base × hauteur) ÷ 2'),
(1, 3, '🔢 A = (6 × 4) ÷ 2 = 24 ÷ 2'),
(1, 4, '✅ Pense à bien diviser par 2 à la fin !');

-- Ex 2: Pythagore — hypoténuse
INSERT INTO hints (exercise_id, step_order, content) VALUES
(2, 1, '💡 Vérifie d''abord : est-ce un triangle rectangle ?'),
(2, 2, '📐 Rappelle-toi la relation : a² + b² = c²'),
(2, 3, '🔢 c² = 3² + 4² = 9 + 16 = 25'),
(2, 4, '✅ Pour trouver c, calcule la racine carrée : c = √25');

-- Ex 8: Périmètre cercle
INSERT INTO hints (exercise_id, step_order, content) VALUES
(8, 1, '💡 Le périmètre d''un cercle s''appelle aussi la « circonférence »'),
(8, 2, '📐 Formule : P = 2 × π × r'),
(8, 3, '🔢 P = 2 × 3.14 × 5 = 6.28 × 5'),
(8, 4, '✅ Utilise π ≈ 3.14 pour le calcul');

-- Ex 10: Aire losange
INSERT INTO hints (exercise_id, step_order, content) VALUES
(10, 1, '💡 L''aire d''un losange utilise les diagonales'),
(10, 2, '📐 A = (d1 × d2) ÷ 2'),
(10, 3, '🔢 A = (10 × 6) ÷ 2 = 60 ÷ 2');

-- Ex 3: Pythagore difficile
INSERT INTO hints (exercise_id, step_order, content) VALUES
(3, 1, '💡 On cherche un côté (pas l''hypoténuse) — la formule change !'),
(3, 2, '📐 Si on cherche a : a² = c² - b²'),
(3, 3, '🔢 a² = 13² - 5² = 169 - 25 = 144'),
(3, 4, '✅ a = √144 — quel nombre au carré donne 144 ?');

-- Ex 9: Aire cercle
INSERT INTO hints (exercise_id, step_order, content) VALUES
(9, 1, '💡 L''aire d''un cercle (ou disque) utilise le rayon'),
(9, 2, '📐 A = π × r²'),
(9, 3, '🔢 A = 3.14 × 4² = 3.14 × 16'),
(9, 4, '✅ Multiplie 3.14 × 16 pour obtenir le résultat');

-- Ex 11: Aire trapèze
INSERT INTO hints (exercise_id, step_order, content) VALUES
(11, 1, '💡 Le trapèze a deux bases différentes — il faut les additionner'),
(11, 2, '📐 A = (Grande base + petite base) × hauteur ÷ 2'),
(11, 3, '🔢 A = (10 + 6) × 4 ÷ 2 = 16 × 4 ÷ 2'),
(11, 4, '✅ N''oublie pas de diviser par 2 à la fin !');

-- ============================================================
--  FIN
-- ============================================================
