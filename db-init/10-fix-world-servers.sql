-- Fix world_servers entries for Shogun Gauntlet
-- This must run AFTER 02-login.sql

USE starloco_login;

-- Fix server 601 key and name
UPDATE world_servers SET `key` = 'valem', name = 'Valem' WHERE id = 601;
