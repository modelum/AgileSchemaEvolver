CREATE DATABASE Neo4jScriptEntity_Ops IF NOT EXISTS ;
:USE Neo4jScriptEntity_Ops

// ADD ENTITY EntityAdded1: { attr: String }
MERGE (x: EntityAdded1);
MATCH (x: EntityAdded1)
SET x.attr = ""
;

// ADD ENTITY EntityAdded2: { attr1: Number, attr2: Boolean }
MERGE (x: EntityAdded2);
MATCH (x: EntityAdded2)
SET x.attr1 = 0, x.attr2 = false
;

// ADD ENTITY EntityAdded3: { attr1: Double, attr2: List, attr3: Boolean }

MERGE (x: EntityAdded3);
MATCH (x: EntityAdded3)
SET x.attr1 = 0.0, x.attr2 = [], x.attr3 = false
;

// DELETE ENTITY EntityAdded2

MATCH (x: EntityAdded2)
DETACH DELETE x
;

// RENAME ENTITY EntityAdded3 TO EntityRenamed
MATCH (x: EntityAdded3)
REMOVE x: EntityAdded3
SET x: EntityRenamed
;
