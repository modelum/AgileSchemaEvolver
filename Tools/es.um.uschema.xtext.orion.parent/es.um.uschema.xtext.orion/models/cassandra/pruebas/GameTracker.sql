CREATE DATABASE IF NOT EXISTS gametracker;

USE gametracker;

/* ADD RELATIONSHIP RelationshipAdded1: { tiempo: Timestamp }

 */
CREATE TABLE IF NOT EXISTS RelationshipAdded1
(
   tiempo TIMESTAMP
);

/* ADD REF RelationshipAdded1::ref1: String? TO Player
 */

-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE RELATIONSHIPADDED1 
ADD COLUMN player_id VARCHAR(255);

-- (2) Add foreign key
ALTER TABLE RELATIONSHIPADDED1
ADD CONSTRAINT relationshipadded1_ref1_fk FOREIGN KEY (player_id)
REFERENCES PLAYER(player_id);



ALTER TABLE RELATIONSHIPADDED1 ADD PRIMARY KEY (player_id);


ALTER TABLE RELATIONSHIPADDED1 
ADD CONSTRAINT relationshipadded1_player_fk FOREIGN KEY (player_id) 
REFERENCES PLAYER (player_id);

/* ADD REF RelationshipAdded1::ref2: String? TO Game

 */

-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE RELATIONSHIPADDED1 
ADD COLUMN game_id VARCHAR(255);

-- (2) Add foreign key
ALTER TABLE RELATIONSHIPADDED1
ADD CONSTRAINT relationshipadded1_ref2_fk FOREIGN KEY (game_id)
REFERENCES GAME(game_id);


CALL dropFKsFromTable("RELATIONSHIPADDED1");
ALTER TABLE RELATIONSHIPADDED1 DROP PRIMARY KEY;

ALTER TABLE RELATIONSHIPADDED1 ADD PRIMARY KEY (game_id, player_id);

ALTER TABLE RELATIONSHIPADDED1 
ADD CONSTRAINT relationshipadded1_player_fk FOREIGN KEY (player_id) 
REFERENCES PLAYER (player_id);

ALTER TABLE RELATIONSHIPADDED1 
ADD CONSTRAINT relationshipadded1_game_fk FOREIGN KEY (game_id) 
REFERENCES GAME (game_id);

/* RENAME RELATIONSHIP RelationshipAdded1 TO RelationshipRenamed

 */
RENAME TABLE RELATIONSHIPADDED1 TO RELATIONSHIPRENAMED;

/* DELETE RELATIONSHIP RelationshipRenamed
 */
DROP TABLE RELATIONSHIPRENAMED;

-- Delete helper procedures
DROP PROCEDURE IF EXISTS dropWeakEntities;
DROP PROCEDURE IF EXISTS dropFKsFromTable;
DROP PROCEDURE IF EXISTS executeCommand;
DROP PROCEDURE IF EXISTS dropConstraintsForColumn;
DROP PROCEDURE IF EXISTS dropCheckConstraintsForColumn;
DROP PROCEDURE IF EXISTS update_fk_schema;
DROP PROCEDURE IF EXISTS update_fk_data;
DROP PROCEDURE IF EXISTS castColumnFKs;
