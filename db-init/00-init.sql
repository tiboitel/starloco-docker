-- Consolidated initialization: database creation, user creation, and privileges
-- This runs during MariaDB image initialization.
-- Executes first (00-) before schema/data files (02-, 04-, etc.)

-- Create game database if not exists
CREATE DATABASE IF NOT EXISTS starloco_game CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges to the starloco user (created by MARIADB_USER/MARIADB_PASSWORD env vars)
GRANT ALL PRIVILEGES ON starloco_game.* TO 'starloco'@'%';

FLUSH PRIVILEGES;
