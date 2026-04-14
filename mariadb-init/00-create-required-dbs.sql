-- Create game database and grant access to the starloco user
-- This runs during MariaDB image initialization and does not require calling
-- the mysql client binary (safer than shell scripts in the init phase).

CREATE DATABASE IF NOT EXISTS starloco_game CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON starloco_game.* TO 'starloco'@'%';
FLUSH PRIVILEGES;
