CREATE DATABASE Neo4jScriptReference_Ops IF NOT EXISTS ;
:USE Neo4jScriptReference_Ops

// ADD ENTITY EntityReferenced: { attr: String }
MERGE (x: EntityReferenced);
MATCH (x: EntityReferenced)
SET x.attr = ""
;

// ADD ENTITY EntityReferences: { attr: String }

MERGE (x: EntityReferences);
MATCH (x: EntityReferences)
SET x.attr = ""
;

// ADD RELATIONSHIP Relationship1

// ADD RELATIONSHIP Relationship2: { attr: String }


// ADD REF EntityReferences::REF1: feat by Relationship2 & TO EntityReferenced
MATCH (y: EntityReferenced) WITH y LIMIT 1
MATCH (x: EntityReferences)
CREATE
  (x)-[:REF1 { attr: "" }]->(y)
;

// ADD REF EntityReferences::REF2: { attr1: String, attr2: String } & TO EntityReferenced
MATCH (y: EntityReferenced) WITH y LIMIT 1
MATCH (x: EntityReferences)
CREATE
  (x)-[:REF2 { attr1: "", attr2: "" }]->(y)
;

// ADD REF EntityReferences::REF3: feat by Relationship2 + TO EntityReferenced
MATCH (y: EntityReferenced) WITH y
MATCH (x: EntityReferences)
CREATE
  (x)-[:REF3 { attr: "" }]->(y)
;

// ADD REF EntityReferences::REF4: { attr1: String, attr2: String } + TO EntityReferenced
MATCH (y: EntityReferenced) WITH y
MATCH (x: EntityReferences)
CREATE
  (x)-[:REF4 { attr1: "", attr2: "" }]->(y)
;
