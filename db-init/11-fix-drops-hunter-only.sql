USE starloco_game;

-- Fix drops to require hunter job (ID 41)
-- Only meats should drop, and only with hunting weapon equipped
-- Based on: https://dofusretro.jeuxonline.info/article/14780/metier-chasseur-boucher

-- Step 1: Disable ALL drops (action = -1 = no drop)
UPDATE drops SET action = '-1';

-- Step 2: Enable only hunter drops (meats) - action = '1' = hunter job drop
UPDATE drops SET action = '1' WHERE objectId IN (
    1896, 1897, 1933,
    1898, 1899, 1900,
    1915, 1916,
    1911, 1912, 1913, 1914, 2041,
    1901, 1902, 1903, 1905,
    1917, 1918, 1919, 1921,
    1922, 1923, 1924, 1926,
    1927, 1929, 1930, 2499,
    8498, 8499, 8500,
    2297
);