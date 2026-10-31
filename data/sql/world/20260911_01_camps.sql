CREATE TABLE IF NOT EXISTS camps_schema (
    id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
    version INT UNSIGNED NOT NULL
) ENGINE=InnoDB;
INSERT IGNORE INTO camps_schema (id,version) VALUES (1,1);

CREATE TABLE IF NOT EXISTS camps_camp (
    account INT UNSIGNED NOT NULL PRIMARY KEY,
    map INT UNSIGNED NOT NULL,
    x FLOAT NOT NULL, y FLOAT NOT NULL, z FLOAT NOT NULL, o FLOAT NOT NULL,
    public_visit TINYINT UNSIGNED NOT NULL DEFAULT 0,
    radius FLOAT NOT NULL DEFAULT 40
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS camps_prop (
    guid INT UNSIGNED NOT NULL PRIMARY KEY,
    account INT UNSIGNED NOT NULL,
    camp INT UNSIGNED NOT NULL DEFAULT 0,
    entry INT UNSIGNED NOT NULL,
    KEY owner_index (account), KEY camp_index (camp)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS camps_catalog_override (
    entry INT UNSIGNED NOT NULL PRIMARY KEY,
    enabled TINYINT UNSIGNED NOT NULL DEFAULT 1,
    player_allowed TINYINT UNSIGNED NOT NULL DEFAULT 0,
    category VARCHAR(32) NOT NULL DEFAULT '',
    notes VARCHAR(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

-- Curated Camp Buildings, Structures, Companions and Essentials
INSERT IGNORE INTO camps_catalog_override (entry, enabled, player_allowed, category, notes) VALUES
-- Custom & Standard Buildings / Shelters
(1000001, 1, 1, 'Shelter', 'Human Camp Tent'),
(1000236, 1, 1, 'Shelter', 'Orc Camp Tent'),
(1000235, 1, 1, 'Shelter', 'Horde Field Tent'),
(1000456, 1, 1, 'Shelter', 'Night Elf Pavilion Tent'),
(1000457, 1, 1, 'Shelter', 'Dwarven Expedition Tent'),
(2000480, 1, 1, 'Shelter', 'Tauren Druid Tent'),
(2000481, 1, 1, 'Shelter', 'Night Elf Camp Tent Large'),
(2000482, 1, 1, 'Shelter', 'Night Elf Camp Tent Small'),
(1000008, 1, 1, 'Buildings', 'Players House (Custom WMO)'),
(1000009, 1, 1, 'Buildings', 'Alliance Tower (Custom WMO)'),
(1000011, 1, 1, 'Buildings', 'Horde Tower (Custom WMO)'),
(90000, 1, 1, 'Buildings', 'Big House'),
(2000188, 1, 1, 'Buildings', 'Redridge Stable'),
(2000189, 1, 1, 'Buildings', 'Redridge Lumbermill'),
(2000190, 1, 1, 'Buildings', 'Redridge Barn'),
(2000191, 1, 1, 'Buildings', 'Duskwood Barn'),
(2000193, 1, 1, 'Buildings', 'Duskwood Stable'),
(2007428, 1, 1, 'Buildings', 'Gnome Hut'),
(2007429, 1, 1, 'Buildings', 'Gnome Hut Two Story'),
(2007434, 1, 1, 'Buildings', 'Guard Tower'),
(300510, 1, 1, 'Buildings', 'Ogre Guard Tower'),
(300511, 1, 1, 'Buildings', 'Ogre Hut'),
(300512, 1, 1, 'Buildings', 'Ogre Hut Huge'),
(300513, 1, 1, 'Buildings', 'Ogre Hut Two Story'),
(300514, 1, 1, 'Buildings', 'Ogre Hut Big'),
(1000032, 1, 1, 'Nature', 'Stone Moonwell'),
(2000035, 1, 1, 'Buildings', 'Redridge Small Dock'),
-- Furniture & Camp Equipment
(1557, 1, 1, 'Furniture', 'Dinner Table'),
(2413, 1, 1, 'Furniture', 'Wooden Chair'),
(2489, 1, 1, 'Furniture', 'Camp Chair'),
(10192, 1, 1, 'Furniture', 'Rustic Wooden Chair'),
(1798, 1, 1, 'Fire & Light', 'Cozy Campfire (Cooking Focus)'),
(1801, 1, 1, 'Fire & Light', 'Warm Campfire'),
(3643, 1, 1, 'Storage', 'Footlocker'),
(177002, 1, 1, 'Crafting', 'Camp Anvil & Forge'),
-- Camp Companions, Mounts & Pets
(284, 1, 1, 'Beast', 'Brown Riding Horse'),
(385, 1, 1, 'Critter', 'Camp Horse'),
(6368, 1, 1, 'Critter', 'Camp Cat'),
(2620, 1, 1, 'Critter', 'Prairie Dog Companion'),
(299, 1, 1, 'Beast', 'Young Wolf Guard'),
(356, 1, 1, 'Beast', 'Black Riding Wolf'),
(358, 1, 1, 'Beast', 'Brown Riding Wolf'),
(50045, 1, 1, 'Beast', 'Frostwolf Ghostpup (Pet)'),
(36505, 1, 1, 'Critter', 'Crimson Sabercat Cub (Pet)'),
-- Camp Staff & Guards
(68, 1, 1, 'Humanoid', 'Stormwind Camp Guard'),
(261, 1, 1, 'Humanoid', 'Camp Guard Thomas'),
(272, 1, 1, 'Humanoid', 'Chef Grual (Camp Cook)'),
(343, 1, 1, 'Humanoid', 'Chef Breanna (Camp Cook)'),
(295, 1, 1, 'Humanoid', 'Innkeeper Farley (Camp Host)'),
(351, 1, 1, 'Humanoid', 'Camp Peasant');
