CREATE DATABASE Neo4jScriptRelationship_Ops IF NOT EXISTS ;
:USE Neo4jScriptRelationship_Ops

// ADD RELATIONSHIP RelationshipAdded1: { attr1: String }

// ADD RELATIONSHIP RelationshipAdded2: { attr2: String }

// ADD RELATIONSHIP RelationshipAdded3: { attr3: String }


// DELETE RELATIONSHIP RelationshipAdded2

MATCH ()-[x: RelationshipAdded2]->()
DELETE x
;

// RENAME RELATIONSHIP RelationshipAdded3 TO RelationshipRenamed

MATCH ()-[x: RelationshipAdded3]->()
CALL apoc.refactor.setType(x, 'RelationshipRenamed')
YIELD input, output RETURN *
;

// ADD RELATIONSHIP RelationshipToExtract: { feat1, feat2, feat3, feat4 }


// EXTRACT RELATIONSHIP RelationshipToExtract INTO RelationshipExtracted ( feat2, feat4 )

MATCH (y)-[x: RelationshipToExtract]->(z)
CREATE
  (y)-[x1: RelationshipExtracted { feat2: x.feat2, feat4: x.feat4 }]->(z)
;

// ADD RELATIONSHIP RelationshipToSplit: { attr1: String, attr2: String, attr3: String, attr4: String, attr5: String, attr6: String }


// SPLIT RELATIONSHIP RelationshipToSplit INTO RelationshipSplit1 ( attr1, attr2, attr3 ), RelationshipSplit2 ( attr1, attr5, attr6 )

MATCH (y)-[x: RelationshipToSplit]->(z)
CREATE
  (y)-[x1: RelationshipSplit1 { attr1: x.attr1, attr2: x.attr2, attr3: x.attr3 }]->(z),
  (y)-[x2: RelationshipSplit2 { attr1: x.attr1, attr5: x.attr5, attr6: x.attr6 }]->(z)
DELETE x
;

// ADD RELATIONSHIP RelationshipToMerge1: { +id: String ( "id" ), a: String, b: Number }

// ADD RELATIONSHIP RelationshipToMerge2: { +id: String ( "id" ), c: List, b }


// MERGE RELATIONSHIP RelationshipToMerge1, RelationshipToMerge2 INTO RelationshipMerged WHERE RelationshipToMerge1.id = RelationshipToMerge2.id
MATCH (y)-[x1: RelationshipToMerge1]->(z)
MATCH ()-[x2: RelationshipToMerge2]->()
WHERE x1.id = x2.id
CREATE
  (y)-[x: RelationshipMerged { id: x1.id, a: x1.a, b: x1.b, c: x2.c }]->(z)
DELETE x1, x2
;
