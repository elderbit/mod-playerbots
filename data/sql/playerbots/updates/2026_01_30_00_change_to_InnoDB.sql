-- Target database
SET @db := 'acore_playerbots';

-- Check if the database exists
SELECT SCHEMA_NAME INTO @db_exists
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = @db;

IF @db_exists IS NOT NULL THEN

    -- List of tables (clean and elegant using VALUES)
    CREATE TEMPORARY TABLE tmp_tables (name VARCHAR(255));

    INSERT INTO tmp_tables (name)
    VALUES 
        ('playerbots_dungeon_suggestion_abbrevation'),
        ('playerbots_dungeon_suggestion_definition'),
        ('playerbots_dungeon_suggestion_strategy'),
        ('playerbots_equip_cache'),
        ('playerbots_item_info_cache'),
        ('playerbots_rarity_cache'),
        ('playerbots_rnditem_cache'),
        ('playerbots_tele_cache'),
        ('playerbots_travelnode'),
        ('playerbots_travelnode_link'),
        ('playerbots_travelnode_path');

    -- Build ALTER TABLE statements only for tables that actually exist
    SELECT GROUP_CONCAT(
        CONCAT('ALTER TABLE ', @db, '.', name, ' ENGINE=InnoDB')
        SEPARATOR '; '
    ) INTO @sql
    FROM tmp_tables
    WHERE EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = @db AND TABLE_NAME = name
    );

    DROP TEMPORARY TABLE tmp_tables;

    -- Only run ALTER TABLE if there is something to run
    IF @sql IS NOT NULL THEN
        -- Disable strict mode only when needed
        SET SESSION innodb_strict_mode = 0;

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET SESSION innodb_strict_mode = 1;
    END IF;

END IF;
