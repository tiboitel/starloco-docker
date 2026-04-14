-- Consolidated initialization: database creation, user creation, and privileges
-- This runs during MariaDB image initialization.
-- Executes first (00-) before schema/data files (02-, 04-, etc.)

-- Create game database if not exists
CREATE DATABASE IF NOT EXISTS starloco_game CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create starloco user if not exists (using ALTER to ensure password is set correctly)
-- The user is created by MARIADB_USER/MARIADB_PASSWORD env vars, but we grant explicit privileges here
GRANT ALL PRIVILEGES ON starloco_game.* TO 'starloco'@'%';
GRANT ALL PRIVILEGES ON starloco_game.* TO 'starloco'@'localhost';

FLUSH PRIVILEGES;
