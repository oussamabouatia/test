-- ============================================================
--  auth_users.sql — Table utilisateurs (étudiants)
--  Importer dans phpMyAdmin → geocollege → Import
-- ============================================================

USE geocollege;

-- ============================================================
--  TABLE: users
--  Stocke les comptes étudiants
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  email       VARCHAR(150) NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,             -- bcrypt hash
  role        ENUM('student','admin') NOT NULL DEFAULT 'student',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index pour recherche rapide par email
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role  ON users(role);

-- ============================================================
--  FIN — Table users prête !
-- ============================================================
