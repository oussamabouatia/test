-- ============================================================
--  tracking_tables.sql — Tables de suivi d'activité étudiants
-- ============================================================

USE geocollege;

-- ============================================================
--  TABLE: exercise_results
--  Stocke chaque tentative d'exercice par un étudiant
-- ============================================================
CREATE TABLE IF NOT EXISTS exercise_results (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NOT NULL,
  exercise_id   INT NOT NULL,
  score         TINYINT NOT NULL DEFAULT 0,          -- 0 = faux, 100 = correct
  attempts      INT NOT NULL DEFAULT 1,
  time_spent    INT NOT NULL DEFAULT 0,              -- en secondes
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  TABLE: interactive_sessions
--  Stocke chaque session interactive (constructeur, etc.)
-- ============================================================
CREATE TABLE IF NOT EXISTS interactive_sessions (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NOT NULL,
  lesson_id     VARCHAR(100) NOT NULL,               -- slug: constructeur, formes, theoremes
  success       TINYINT(1) NOT NULL DEFAULT 0,
  attempts      INT NOT NULL DEFAULT 1,
  duration      INT NOT NULL DEFAULT 0,              -- en secondes
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index performance
CREATE INDEX idx_er_user      ON exercise_results(user_id);
CREATE INDEX idx_er_exercise  ON exercise_results(exercise_id);
CREATE INDEX idx_er_created   ON exercise_results(created_at);
CREATE INDEX idx_is_user      ON interactive_sessions(user_id);
CREATE INDEX idx_is_lesson    ON interactive_sessions(lesson_id);
CREATE INDEX idx_is_created   ON interactive_sessions(created_at);

-- ============================================================
--  Vue stats étudiants pour le dashboard admin
-- ============================================================
CREATE OR REPLACE VIEW vue_student_stats AS
SELECT
  (SELECT COUNT(*) FROM users)                                         AS total_students,
  (SELECT COUNT(*) FROM exercise_results)                              AS total_attempts,
  (SELECT COUNT(DISTINCT user_id) FROM exercise_results)               AS active_students,
  (SELECT ROUND(AVG(score), 1) FROM exercise_results)                  AS avg_score,
  (SELECT COUNT(*) FROM exercise_results WHERE score = 100)            AS total_correct,
  (SELECT COUNT(*) FROM interactive_sessions)                          AS total_sessions;
