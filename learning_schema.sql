-- ============================================================
--  learning_schema.sql — Nouvelles tables pour le parcours
--  NE MODIFIE PAS les tables existantes (formes, formules, etc.)
-- ============================================================

USE geocollege;

-- ============================================================
--  TABLE: chapitres
-- ============================================================
CREATE TABLE IF NOT EXISTS chapitres (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  slug        VARCHAR(100) NOT NULL UNIQUE,
  titre       VARCHAR(200) NOT NULL,
  niveau      ENUM('1AC','2AC','3AC') NOT NULL,
  ordre       INT NOT NULL DEFAULT 1,
  icone       VARCHAR(10) DEFAULT '📐',
  couleur     VARCHAR(20) DEFAULT '#16a34a',
  description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: lecons
-- ============================================================
CREATE TABLE IF NOT EXISTS lecons (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  chapitre_id     INT NOT NULL,
  slug            VARCHAR(100) NOT NULL UNIQUE,
  titre           VARCHAR(200) NOT NULL,
  contenu         LONGTEXT,
  ordre           INT NOT NULL DEFAULT 1,
  duree_min       INT DEFAULT 15,
  difficulte      TINYINT DEFAULT 1,
  prerequis       JSON,
  has_interactive  BOOLEAN DEFAULT FALSE,
  forme_id        INT DEFAULT NULL,
  FOREIGN KEY (chapitre_id) REFERENCES chapitres(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: exercices_v2 (new system, separate from old exercices)
-- ============================================================
CREATE TABLE IF NOT EXISTS exercices_v2 (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  lecon_id    INT NOT NULL,
  type        ENUM('qcm','calcul','vrai_faux') NOT NULL,
  ordre       INT NOT NULL DEFAULT 1,
  enonce      TEXT NOT NULL,
  options     JSON,
  reponse     VARCHAR(255) NOT NULL,
  tolerance   DECIMAL(5,2) DEFAULT 0.10,
  indice      TEXT,
  explication TEXT,
  points      INT DEFAULT 10,
  FOREIGN KEY (lecon_id) REFERENCES lecons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: eleves
-- ============================================================
CREATE TABLE IF NOT EXISTS eleves (
  id                  VARCHAR(36) PRIMARY KEY,
  nom                 VARCHAR(100) NOT NULL,
  prenom              VARCHAR(100) NOT NULL,
  classe              VARCHAR(20),
  niveau              ENUM('1AC','2AC','3AC') NOT NULL DEFAULT '1AC',
  code_recuperation   CHAR(6) NOT NULL,
  points_total        INT DEFAULT 0,
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: progression
-- ============================================================
CREATE TABLE IF NOT EXISTS progression (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  eleve_id        VARCHAR(36) NOT NULL,
  lecon_id        INT NOT NULL,
  statut          ENUM('non_vu','en_cours','complete') DEFAULT 'non_vu',
  score           TINYINT DEFAULT 0,
  attempts        INT DEFAULT 0,
  needs_review    BOOLEAN DEFAULT FALSE,
  completed_at    TIMESTAMP NULL,
  UNIQUE KEY uq_eleve_lecon (eleve_id, lecon_id),
  FOREIGN KEY (eleve_id) REFERENCES eleves(id) ON DELETE CASCADE,
  FOREIGN KEY (lecon_id) REFERENCES lecons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: exercice_attempts
-- ============================================================
CREATE TABLE IF NOT EXISTS exercice_attempts (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  eleve_id        VARCHAR(36) NOT NULL,
  exercice_id     INT NOT NULL,
  reponse_donnee  VARCHAR(255),
  est_correcte    BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (eleve_id) REFERENCES eleves(id) ON DELETE CASCADE,
  FOREIGN KEY (exercice_id) REFERENCES exercices_v2(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: badges
-- ============================================================
CREATE TABLE IF NOT EXISTS badges (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  slug            VARCHAR(100) NOT NULL UNIQUE,
  nom             VARCHAR(150) NOT NULL,
  icone           VARCHAR(10) DEFAULT '',
  condition_type  VARCHAR(50) NOT NULL,
  condition_valeur VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: eleve_badges
-- ============================================================
CREATE TABLE IF NOT EXISTS eleve_badges (
  eleve_id    VARCHAR(36) NOT NULL,
  badge_id    INT NOT NULL,
  obtained_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (eleve_id, badge_id),
  FOREIGN KEY (eleve_id) REFERENCES eleves(id) ON DELETE CASCADE,
  FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  INDEX
-- ============================================================
CREATE INDEX idx_lecons_chapitre ON lecons(chapitre_id);
CREATE INDEX idx_exercices_v2_lecon ON exercices_v2(lecon_id);
CREATE INDEX idx_progression_eleve ON progression(eleve_id);
CREATE INDEX idx_attempts_eleve ON exercice_attempts(eleve_id);
CREATE INDEX idx_attempts_exercice ON exercice_attempts(exercice_id);

-- ============================================================
--  BADGES DATA
-- ============================================================
INSERT INTO badges (slug, nom, icone, condition_type, condition_valeur) VALUES
('first_step',        'Premier Pas',         '🌱', 'lessons_complete', '1'),
('triangle_explorer', 'Explorateur Triangles','📐', 'chapter_complete', 'triangles-1ac'),
('pythagore_master',  'Maitre Pythagore',     '🏛', 'lesson_perfect',  'pythagore'),
('speed_learner',     'Apprenti Rapide',      '⚡', 'lessons_per_day', '3'),
('perfect_score',     'Score Parfait',        '💯', 'any_perfect',     '1'),
('half_way',          'A Mi-chemin',          '🏔', 'program_percent', '50'),
('dictionary_fan',    'Fan du Dictionnaire',  '📖', 'terms_looked_up', '20');
