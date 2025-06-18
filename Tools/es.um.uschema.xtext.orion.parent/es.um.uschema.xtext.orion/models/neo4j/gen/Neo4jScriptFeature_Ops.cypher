CREATE DATABASE Neo4jScriptFeature_Ops IF NOT EXISTS ;
:USE Neo4jScriptFeature_Ops

// ADD ENTITY EntityToRemove: { id: String, attrToDel: String, attrToDelStr: String, attrToDelNum: Number, attrToDelDouble: Double, attrToDelBool: Boolean, attrToRenStr: String, attrToRenNum: Number, attrToRenDouble: Double, attrToRenBool: Boolean }

MERGE (x: EntityToRemove);
MATCH (x: EntityToRemove)
SET x.id = "", x.attrToDel = "", x.attrToDelStr = "", x.attrToDelNum = 0, x.attrToDelDouble = 0.0, x.attrToDelBool = false, x.attrToRenStr = "", x.attrToRenNum = 0, x.attrToRenDouble = 0.0, x.attrToRenBool = false
;

// DELETE EntityToRemove::attrToDel, attrToDelStr, attrToDelNum, attrToDelDouble, attrToDelBool

MATCH (x: EntityToRemove)
REMOVE x.attrToDel, x.attrToDelStr, x.attrToDelNum, x.attrToDelDouble, x.attrToDelBool
;

// RENAME EntityToRemove::attrToRenStr TO attrTrue1
MATCH (x: EntityToRemove)
SET x.attrTrue1 = x.attrToRenStr
REMOVE x.attrToRenStr
;

// RENAME EntityToRemove::attrToRenNum TO attrTrue2
MATCH (x: EntityToRemove)
SET x.attrTrue2 = x.attrToRenNum
REMOVE x.attrToRenNum
;

// RENAME EntityToRemove::attrToRenDouble TO attrTrue3
MATCH (x: EntityToRemove)
SET x.attrTrue3 = x.attrToRenDouble
REMOVE x.attrToRenDouble
;

// RENAME EntityToRemove::attrToRenBool TO attrTrue4

MATCH (x: EntityToRemove)
SET x.attrTrue4 = x.attrToRenBool
REMOVE x.attrToRenBool
;

// ADD ENTITY EntityToCopySource1: { id: String ( "id1" ), valueToCopy1: String ( "COPY_THIS" ), valueToCopy2: List }
MERGE (x: EntityToCopySource1);
MATCH (x: EntityToCopySource1)
SET x.id = "id1", x.valueToCopy1 = "COPY_THIS", x.valueToCopy2 = []
;

// ADD ENTITY EntityToCopySource2: { id: String ( "id2" ), valueToCopy3: String ( "COPY_THAT" ) }
MERGE (x: EntityToCopySource2);
MATCH (x: EntityToCopySource2)
SET x.id = "id2", x.valueToCopy3 = "COPY_THAT"
;

// ADD ENTITY EntityToCopyTarget: { id: String, thisRef: String ( "id1" ), thatRef: String ( "id2" ) }

MERGE (x: EntityToCopyTarget);
MATCH (x: EntityToCopyTarget)
SET x.id = "", x.thisRef = "id1", x.thatRef = "id2"
;

// COPY EntityToCopySource1::valueToCopy1 TO EntityToCopyTarget::copy1 WHERE id = thisRef
MATCH (x1: EntityToCopySource1), (x2: EntityToCopyTarget)
WHERE x1.id = x2.thisRef
SET x2.copy1 = x1.valueToCopy1
;

// COPY EntityToCopySource1::valueToCopy2 TO EntityToCopyTarget::copy2 WHERE id = thisRef
MATCH (x1: EntityToCopySource1), (x2: EntityToCopyTarget)
WHERE x1.id = x2.thisRef
SET x2.copy2 = x1.valueToCopy2
;

// COPY EntityToCopySource2::valueToCopy3 TO EntityToCopyTarget::valueToCopy3 WHERE id = thatRef

MATCH (x1: EntityToCopySource2), (x2: EntityToCopyTarget)
WHERE x1.id = x2.thatRef
SET x2.valueToCopy3 = x1.valueToCopy3
;

// ADD ENTITY EntityToMoveSource1: { id: String ( "id1" ), valueToMove1: String ( "MOVE_THIS" ), valueToMove2: List }
MERGE (x: EntityToMoveSource1);
MATCH (x: EntityToMoveSource1)
SET x.id = "id1", x.valueToMove1 = "MOVE_THIS", x.valueToMove2 = []
;

// ADD ENTITY EntityToMoveSource2: { id: String ( "id2" ), valueToMove3: String ( "MOVE_THAT" ) }
MERGE (x: EntityToMoveSource2);
MATCH (x: EntityToMoveSource2)
SET x.id = "id2", x.valueToMove3 = "MOVE_THAT"
;

// ADD ENTITY EntityToMoveTarget: { id: String, thisRef: String ( "id1" ), thatRef: String ( "id2" ) }

MERGE (x: EntityToMoveTarget);
MATCH (x: EntityToMoveTarget)
SET x.id = "", x.thisRef = "id1", x.thatRef = "id2"
;

// MOVE EntityToMoveSource1::valueToMove1 TO EntityToMoveTarget::move1 WHERE id = thisRef
MATCH (x1: EntityToMoveSource1), (x2: EntityToMoveTarget)
WHERE x1.id = x2.thisRef
SET x2.move1 = x1.valueToMove1
REMOVE x.valueToMove1
;

// MOVE EntityToMoveSource1::valueToMove2 TO EntityToMoveTarget::move2 WHERE id = thisRef
MATCH (x1: EntityToMoveSource1), (x2: EntityToMoveTarget)
WHERE x1.id = x2.thisRef
SET x2.move2 = x1.valueToMove2
REMOVE x.valueToMove2
;

// MOVE EntityToMoveSource2::valueToMove3 TO EntityToMoveTarget::move3 WHERE id = thisRef
MATCH (x1: EntityToMoveSource2), (x2: EntityToMoveTarget)
WHERE x1.id = x2.thisRef
SET x2.move3 = x1.valueToMove3
REMOVE x.valueToMove3
;
