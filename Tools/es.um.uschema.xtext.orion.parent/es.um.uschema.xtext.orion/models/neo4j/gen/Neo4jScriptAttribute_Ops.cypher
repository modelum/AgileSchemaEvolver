CREATE DATABASE Neo4jScriptAttribute_Ops IF NOT EXISTS ;
:USE Neo4jScriptAttribute_Ops

// ADD ENTITY Entity1: { id: String }
MERGE (x: Entity1);
MATCH (x: Entity1)
SET x.id = ""
;

// ADD ENTITY Entity2: { id: String }

MERGE (x: Entity2);
MATCH (x: Entity2)
SET x.id = ""
;

// ADD ATTR *::addAttrStr: String
MATCH (x)
SET x.addAttrStr = ""
;
MATCH ()-[x]->()
SET x.addAttrStr = ""
;

// ADD ATTR *::addAttrNum: Number
MATCH (x)
SET x.addAttrNum = 0
;
MATCH ()-[x]->()
SET x.addAttrNum = 0
;

// ADD ATTR *::addAttrDouble: Double
MATCH (x)
SET x.addAttrDouble = 0.0
;
MATCH ()-[x]->()
SET x.addAttrDouble = 0.0
;

// ADD ATTR *::addAttrBool: Boolean
MATCH (x)
SET x.addAttrBool = false
;
MATCH ()-[x]->()
SET x.addAttrBool = false
;

// ADD ATTR *::addAttrList: List
MATCH (x)
SET x.addAttrList = []
;
MATCH ()-[x]->()
SET x.addAttrList = []
;

// ADD ATTR Entity1::addAttrStrVal: String ("initValue")
MATCH (x: Entity1)
SET x.addAttrStrVal = "initValue"
;

// ADD ATTR Entity1::addAttrNumVal: Number (33)
MATCH (x: Entity1)
SET x.addAttrNumVal = 33
;

// ADD ATTR Entity1::addAttrDoubleVal: Double (33.1)
MATCH (x: Entity1)
SET x.addAttrDoubleVal = 33.1
;

// ADD ATTR Entity1::addAttrBoolVal: Boolean (false)

MATCH (x: Entity1)
SET x.addAttrBoolVal = false
;

// ADD ENTITY EntityToCast: { attrToCastStr: String, attrToCastNum: Number, attrToCastDouble: Double, attrToCastBool: Boolean }

MERGE (x: EntityToCast);
MATCH (x: EntityToCast)
SET x.attrToCastStr = "", x.attrToCastNum = 0, x.attrToCastDouble = 0.0, x.attrToCastBool = false
;

// CAST ATTR EntityToCast::attrToCastStr, attrToCastNum TO Bool
MATCH (x: EntityToCast)
SET x.attrToCastStr = toBoolean(x.attrToCastStr), x.attrToCastNum = toBoolean(x.attrToCastNum)
;

// CAST ATTR EntityToCast::attrToCastDouble TO Number
MATCH (x: EntityToCast)
SET x.attrToCastDouble = toInteger(x.attrToCastDouble)
;

// CAST ATTR EntityToCast::attrToCastNum, attrToCastBool TO String

MATCH (x: EntityToCast)
SET x.attrToCastNum = toString(x.attrToCastNum), x.attrToCastBool = toString(x.attrToCastBool)
;

// ADD ENTITY EntityToPromote: { attr1: String, attr2: String }

MERGE (x: EntityToPromote);
MATCH (x: EntityToPromote)
SET x.attr1 = "", x.attr2 = ""
;

// PROMOTE ATTR EntityToPromote::attr1, attr2

CREATE CONSTRAINT EntityToPromote_attr1_IS_UNIQUE IF NOT EXISTS
ON (x: EntityToPromote)
ASSERT x.attr1 IS UNIQUE
;
CREATE CONSTRAINT EntityToPromote_attr2_IS_UNIQUE IF NOT EXISTS
ON (x: EntityToPromote)
ASSERT x.attr2 IS UNIQUE
;

// ADD ENTITY EntityToDemote: { key1: String, key2: String }

MERGE (x: EntityToDemote);
MATCH (x: EntityToDemote)
SET x.key1 = "", x.key2 = ""
;

// DEMOTE ATTR EntityToDemote::key1, key2
DROP CONSTRAINT EntityToDemote_key1_IS_UNIQUE IF EXISTS
;
DROP CONSTRAINT EntityToDemote_key2_IS_UNIQUE IF EXISTS
;
