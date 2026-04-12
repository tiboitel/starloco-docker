-- Create starloco user with privileges on all databases
-- This must run AFTER databases are created (02-login, 04-game)

-- Create user if not exists
CREATE USER IF NOT EXISTS 'starloco'@'%' IDENTIFIED BY 'Yk6x5Y7qE2t3vntS';
CREATE USER IF NOT EXISTS 'starloco'@'localhost' IDENTIFIED BY 'Yk6x5Y7qE2t3vntS';

-- Grant privileges on all databases
GRANT ALL PRIVILEGES ON starloco_login.* TO 'starloco'@'%';
GRANT ALL PRIVILEGES ON starloco_login.* TO 'starloco'@'localhost';
GRANT ALL PRIVILEGES ON starloco_game.* TO 'starloco'@'%';
GRANT ALL PRIVILEGES ON starloco_game.* TO 'starloco'@'localhost';
GRANT ALL PRIVILEGES ON starloco_web.* TO 'starloco'@'%';
GRANT ALL PRIVILEGES ON starloco_web.* TO 'starloco'@'localhost';

FLUSH PRIVILEGES;