-- Procedures to help in the sql operations

-- Procedure for dropping weak entities, used in EntityDeleteOp operations
	
DELIMITER $$

CREATE PROCEDURE dropWeakEntities(IN parent_table VARCHAR(255))
BEGIN
  -- (1) Create temporary table if it does not exist
  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_fks (cmd VARCHAR(1024));

  -- (2) Insert statements to drop weak entities
  INSERT INTO tmp_fks (cmd)
    SELECT DISTINCT CONCAT('DROP TABLE IF EXISTS ', TABLE_NAME, ';')
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE REFERENCED_TABLE_NAME = parent_table
      AND TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME IN (
          SELECT TABLE_NAME
          FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
          WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
          AND TABLE_SCHEMA = DATABASE()
      );

  -- (3) Call the helper procedure to execute the commands and clean up the temporary table
  CALL executeCommand();

END$$

DELIMITER ;

-- Procedure for dropping all foreign keys declared in a given table
DELIMITER $$

CREATE PROCEDURE dropFKsInTable(IN tabla_objetivo VARCHAR(255))
BEGIN
  -- (1) Create temporary table if it does not exist
  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_fks (cmd VARCHAR(1024));
  
  -- (2) Clear any existing commands in the temporary table
    TRUNCATE TABLE tmp_fks;

  -- (3) Insert commands to drop all foreign keys on the target table
  INSERT INTO tmp_fks (cmd)
    SELECT DISTINCT 
      CONCAT('ALTER TABLE ', TABLE_NAME, ' DROP FOREIGN KEY ', CONSTRAINT_NAME, ';')
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
      AND TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tabla_objetivo;

  -- (3) Execute the generated commands and clean up
  CALL executeCommand();
END$$

DELIMITER ;


-- Procedure for dropping foreign keys from a table, used in EntityDeleteOp operations
	
DELIMITER $$

CREATE PROCEDURE dropFKsFromTable(IN parent_table VARCHAR(255))
BEGIN
  -- (1) Create temporary table if it does not exist
  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_fks (cmd VARCHAR(1024));
  
  -- (2) Clear any existing commands in the temporary table
    TRUNCATE TABLE tmp_fks;

  -- (3) Insert statements to drop foreign keys
  INSERT INTO tmp_fks (cmd)
    SELECT DISTINCT CONCAT('ALTER TABLE ', TABLE_NAME, ' DROP FOREIGN KEY ', CONSTRAINT_NAME, ';')
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE REFERENCED_TABLE_NAME = parent_table
      AND TABLE_SCHEMA = DATABASE();

  -- (3) Call the helper procedure to execute the commands and clean up the temporary table
  CALL executeCommand();

END$$

DELIMITER ;


-- Helper procedure to execute dynamic SQL commands from the temporary table
	
DELIMITER $$

CREATE PROCEDURE executeCommand()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_cmd VARCHAR(1024);
  DECLARE cur CURSOR FOR SELECT cmd FROM tmp_fks;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- (1) Open the cursor and iterate over commands
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_cmd;
    IF done THEN
      LEAVE read_loop;
    END IF;

    SET @sql_exec = v_cmd;
    PREPARE st FROM @sql_exec;
    EXECUTE st;
    DEALLOCATE PREPARE st;
  END LOOP;
  CLOSE cur;

  -- (2) Drop the temporary table after use
  DROP TEMPORARY TABLE IF EXISTS tmp_fks;
  SET done = 0;
  
END$$

DELIMITER ;


-- Procedure for dropping constraints for a column, used in FeatureDeleteOp operations
	
DELIMITER $$

CREATE PROCEDURE dropConstraintsForColumn(
    IN p_table_name VARCHAR(255),
    IN p_column_name VARCHAR(255)
)
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_constraint_name VARCHAR(255);
  DECLARE v_constraint_type VARCHAR(64);
  
  -- (1) Cursor selects ALL CONSTRAINTS names for the given table and column
  DECLARE cur CURSOR FOR
    SELECT kcu.CONSTRAINT_NAME, tc.CONSTRAINT_TYPE
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
      ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME 
     AND tc.TABLE_NAME = kcu.TABLE_NAME
     AND tc.CONSTRAINT_SCHEMA = kcu.CONSTRAINT_SCHEMA
    WHERE kcu.TABLE_NAME = p_table_name
      AND kcu.COLUMN_NAME = p_column_name
      AND kcu.TABLE_SCHEMA = DATABASE();

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

-- (2) Open cursor and loop through each found constraint
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_constraint_name, v_constraint_type;
    IF done THEN
      LEAVE read_loop;
    END IF;

    SET @sql = CONCAT('ALTER TABLE ', p_table_name, ' DROP CONSTRAINT ', v_constraint_name, ';');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END LOOP;
  CLOSE cur;
END$$

DELIMITER ;


-- Procedure for dropping check constraints for a column, used in FeatureRenameOp operations
	
DELIMITER $$

CREATE PROCEDURE dropCheckConstraintsForColumn(
  IN p_table_name VARCHAR(255),
  IN p_column_name VARCHAR(255)
)
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_check_name VARCHAR(255);
  
  -- (1) Cursor selects ALL CHECK constraint names for the given table and column
  DECLARE cur CURSOR FOR
    SELECT tc.CONSTRAINT_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc ON cc.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
    JOIN INFORMATION_SCHEMA.COLUMNS c ON c.TABLE_NAME = tc.TABLE_NAME AND c.TABLE_SCHEMA = tc.CONSTRAINT_SCHEMA
    WHERE tc.CONSTRAINT_TYPE = 'CHECK'
      AND tc.TABLE_NAME = p_table_name
      AND c.COLUMN_NAME = p_column_name
      AND tc.CONSTRAINT_SCHEMA = DATABASE();
  
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
  -- (2) Open cursor and loop through each found constraint
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_check_name;
    IF done THEN
      LEAVE read_loop;
    END IF;
	
	-- Build and execute the DROP CHECK statement for this constraint
    SET @sql = CONCAT('ALTER TABLE ', p_table_name, ' DROP CHECK ', v_check_name, ';');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END LOOP;
  CLOSE cur;
END$$

DELIMITER ;


-- Procedure for updating foreign key schema, used in AttributePromoteOp operations
	
DELIMITER $$

CREATE PROCEDURE update_fk_schema(
    IN p_promoted_table VARCHAR(64),
    IN p_old_pk VARCHAR(255),
    IN p_add_pk VARCHAR(255)
)
BEGIN
    -- Declare all variables at the beginning
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_table_name VARCHAR(64);
    DECLARE v_constraint_name VARCHAR(64);
    DECLARE v_fk_columns VARCHAR(255);
    DECLARE v_num INT;
    DECLARE v_index INT DEFAULT 1;
    DECLARE v_add_col VARCHAR(64);
    DECLARE col_type VARCHAR(255);

    -- Cursor to group the FKs that reference p_promoted_table
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME, CONSTRAINT_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) as fk_cols
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE REFERENCED_TABLE_NAME = p_promoted_table
        GROUP BY TABLE_NAME, CONSTRAINT_NAME;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    fk_loop: LOOP
        FETCH cur INTO v_table_name, v_constraint_name, v_fk_columns;
        IF done THEN
            LEAVE fk_loop;
        END IF;

        -- Calculate the number of additional columns to add
        SET v_num = (LENGTH(p_add_pk) - LENGTH(REPLACE(p_add_pk, ',', '')) + 1);
        SET v_index = 1;

        WHILE v_index <= v_num DO
            SET v_add_col = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_add_pk, ',', v_index), ',', -1));

            -- If the additional column is not found in the current FK, add it to the table
            IF FIND_IN_SET(v_add_col, v_fk_columns) = 0 THEN

                -- (1) Build SELECT ... INTO @col_type to get the column type from the referenced table
                SET @colTypeSql = CONCAT(
                    "SELECT COLUMN_TYPE INTO @col_type ",
                    "FROM INFORMATION_SCHEMA.COLUMNS ",
                    "WHERE TABLE_SCHEMA = DATABASE() ",
                    "  AND TABLE_NAME = '", p_promoted_table, "' ",
                    "  AND COLUMN_NAME = '", v_add_col, "' ",
                    "LIMIT 1"
                );

                -- (2) Execute using PREPARE/EXECUTE
                PREPARE stmt FROM @colTypeSql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;

                -- (3) Assign the value from the user variable @col_type to the local variable col_type
                SET col_type = @col_type;

                -- (4) Use col_type in the ALTER TABLE statement
                SET @sql = CONCAT('ALTER TABLE ', v_table_name,
                                  ' ADD COLUMN ', v_add_col, ' ', col_type);
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END IF;

            SET v_index = v_index + 1;
        END WHILE;

        -- Drop the old FK.
        SET @sql = CONCAT('ALTER TABLE ', v_table_name, ' DROP FOREIGN KEY ', v_constraint_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Create the new FK that uses both the original and additional columns.
        SET @sql = CONCAT(
            'ALTER TABLE ', v_table_name, 
            ' ADD CONSTRAINT fk_', v_table_name, '_', p_promoted_table, '_new FOREIGN KEY (', 
            p_old_pk, ', ', p_add_pk, 
            ') REFERENCES ', p_promoted_table, '_NEW (', 
            p_old_pk, ', ', p_add_pk, ')'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE cur;
END$$

DELIMITER ;


-- Procedure for updating foreign key data, used in AttributePromoteOp operations
	
DELIMITER $$

CREATE PROCEDURE update_fk_data(
    IN p_promoted_table VARCHAR(64),  -- E.g.: 'PLAYER1'
    IN p_old_pk VARCHAR(255),         -- E.g.: 'player_id'
    IN p_add_pk VARCHAR(255)          -- E.g.: 'score,level'
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_table_name VARCHAR(64);
    DECLARE v_constraint_name VARCHAR(64);
    DECLARE v_fk_columns VARCHAR(255);

    DECLARE v_join_condition VARCHAR(1000) DEFAULT '';
    DECLARE v_set_clause VARCHAR(1000) DEFAULT '';

    DECLARE v_num INT;
    DECLARE v_index INT DEFAULT 1;
    DECLARE v_old_col VARCHAR(64);
    DECLARE v_add_col VARCHAR(64);

    -- Cursor: finds all the FKs referencing the new table
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME, CONSTRAINT_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS fk_cols
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE REFERENCED_TABLE_NAME = CONCAT(p_promoted_table, '_NEW')
        GROUP BY TABLE_NAME, CONSTRAINT_NAME;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    fk_loop: LOOP
        FETCH cur INTO v_table_name, v_constraint_name, v_fk_columns;
        IF done THEN
            LEAVE fk_loop;
        END IF;

        -- 1) Build the JOIN condition from the old columns
        SET v_join_condition = '';
        SET v_index = 1;
        SET v_num = (LENGTH(p_old_pk) - LENGTH(REPLACE(p_old_pk, ',', '')) + 1);

        WHILE v_index <= v_num DO
            SET v_old_col = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_old_pk, ',', v_index), ',', -1));
            IF v_index = 1 THEN
                SET v_join_condition = CONCAT('r.', v_old_col, ' = p.', v_old_col);
            ELSE
                SET v_join_condition = CONCAT(v_join_condition, ' AND r.', v_old_col, ' = p.', v_old_col);
            END IF;
            SET v_index = v_index + 1;
        END WHILE;

        -- 2) Build the SET clause with the new columns to copy
        SET v_set_clause = '';
        SET v_index = 1;
        SET v_num = (LENGTH(p_add_pk) - LENGTH(REPLACE(p_add_pk, ',', '')) + 1);

        WHILE v_index <= v_num DO
            SET v_add_col = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_add_pk, ',', v_index), ',', -1));
            IF v_index = 1 THEN
                SET v_set_clause = CONCAT('r.', v_add_col, ' = p.', v_add_col);
            ELSE
                SET v_set_clause = CONCAT(v_set_clause, ', r.', v_add_col, ' = p.', v_add_col);
            END IF;
            SET v_index = v_index + 1;
        END WHILE;

        -- 3) Execute the UPDATE with JOIN, copying the data from the _NEW table
        SET @sql = CONCAT(
            'UPDATE ', v_table_name, ' r ',
            'JOIN ', p_promoted_table, '_NEW p ON ', v_join_condition, ' ',
            'SET ', v_set_clause
        );

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;


-- Procedure for casting columns with foreign keys, used in ReferenceCastOp operations

DELIMITER $$

CREATE PROCEDURE castColumnFKs(
    IN p_table_name   VARCHAR(255),
    IN p_column_name  VARCHAR(255),
    IN p_new_type     VARCHAR(255)
)
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE ref_table   VARCHAR(255);
  DECLARE ref_column  VARCHAR(255);

  -- Cursor to find columns that reference p_table_name.p_column_name
  DECLARE ref_cur CURSOR FOR
    SELECT TABLE_NAME, COLUMN_NAME
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND REFERENCED_TABLE_NAME = p_table_name
      AND REFERENCED_COLUMN_NAME = p_column_name;

  -- Handler for when the cursor reaches the end
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- 1) Disable FK checks for this session
  SET @sql = 'SET FOREIGN_KEY_CHECKS = 0';
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  -- 2) Cast the original column
  SET @sql = CONCAT(
    'ALTER TABLE `', p_table_name,
    '` MODIFY COLUMN `', p_column_name,
    '` ', p_new_type, ';'
  );
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  -- 3) Cast the columns that reference it
  OPEN ref_cur;
  read_loop: LOOP
    FETCH ref_cur INTO ref_table, ref_column;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Cast the referencing column to the same type
    SET @sql = CONCAT(
      'ALTER TABLE `', ref_table,
      '` MODIFY COLUMN `', ref_column,
      '` ', p_new_type, ';'
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END LOOP;
  CLOSE ref_cur;

  -- Reset 'done' in case it is used later
  SET done = 0;

  -- 4) Re-enable FOREIGN_KEY_CHECKS
  SET @sql = 'SET FOREIGN_KEY_CHECKS = 1';
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;

