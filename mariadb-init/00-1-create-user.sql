-- Step 1: Create starloco user (runs first)
-- This creates the user but doesn't grant database access yet
CREATE USER IF NOT EXISTS 'starloco'@'%' IDENTIFIED BY 'Yk6x5Y7qE2t3vntS';
CREATE USER IF NOT EXISTS 'starloco'@'localhost' IDENTIFIED BY 'Yk6x5Y7qE2t3vntS';