MongoDBScriptFeature_Ops = db.getSiblingDB("MongoDBScriptFeature_Ops")


// ADD ENTITY EntityToRemove: { +_id: Identifier, attrToDel, attrToDelStr: String, attrToDelNum: Number, attrToDelDouble: Double, attrToDelBool: Boolean, +attrToRen, +attrToRenStr: String, +attrToRenNum: Number, +attrToRenDouble: Double, +attrToRenBool: Boolean }

MongoDBScriptFeature_Ops.createCollection("EntityToRemove")
MongoDBScriptFeature_Ops.EntityToRemove.updateMany({}, [{$addFields: { "_id": ObjectId(), "attrToDel": null, "attrToDelStr": "", "attrToDelNum": NumberInt(0), "attrToDelDouble": 0.0, "attrToDelBool": false, "attrToRen": null, "attrToRenStr": "", "attrToRenNum": NumberInt(0), "attrToRenDouble": 0.0, "attrToRenBool": false}}], {upsert: true})

MongoDBScriptFeature_Ops.EntityToRemove.bulkWrite([
// DELETE EntityToRemove::attrToDel, attrToDelStr, attrToDelNum, attrToDelDouble, attrToDelBool

  {updateMany: {filter:{}, update: {$unset: { "attrToDel": 1, "attrToDelStr": 1, "attrToDelNum": 1, "attrToDelDouble": 1, "attrToDelBool": 1 }}}},
// RENAME EntityToRemove::attrToRen TO attrTrue1
  {updateMany: {filter: {}, update: {$rename: {"attrToRen": "attrTrue1" }}}},
// RENAME EntityToRemove::attrToRenStr TO attrTrue2
  {updateMany: {filter: {}, update: {$rename: {"attrToRenStr": "attrTrue2" }}}},
// RENAME EntityToRemove::attrToRenNum TO attrTrue3
  {updateMany: {filter: {}, update: {$rename: {"attrToRenNum": "attrTrue3" }}}},
// RENAME EntityToRemove::attrToRenDouble TO attrTrue4
  {updateMany: {filter: {}, update: {$rename: {"attrToRenDouble": "attrTrue4" }}}},
// RENAME EntityToRemove::attrToRenBool TO attrTrue5

  {updateMany: {filter: {}, update: {$rename: {"attrToRenBool": "attrTrue5" }}}}
])

// ADD ENTITY EntityToCopySource1: { +_id: String ( "id1" ), valueToCopy1: String ( "COPY_THIS" ), valueToCopy2: List, valueToCopy3: Map }
MongoDBScriptFeature_Ops.createCollection("EntityToCopySource1")
MongoDBScriptFeature_Ops.EntityToCopySource1.updateMany({}, [{$addFields: { "_id": "id1", "valueToCopy1": "COPY_THIS", "valueToCopy2": [], "valueToCopy3": {$literal: {}}}}], {upsert: true})

// ADD ENTITY EntityToCopySource2: { +_id: String ( "id2" ), valueToCopy4: String ( "COPY_THAT" ) }
MongoDBScriptFeature_Ops.createCollection("EntityToCopySource2")
MongoDBScriptFeature_Ops.EntityToCopySource2.updateMany({}, [{$addFields: { "_id": "id2", "valueToCopy4": "COPY_THAT"}}], {upsert: true})

// ADD ENTITY EntityToCopyTarget: { +_id: String, thisRef: String ( "id1" ), thatRef: String ( "id2" ) }

MongoDBScriptFeature_Ops.createCollection("EntityToCopyTarget")
MongoDBScriptFeature_Ops.EntityToCopyTarget.updateMany({}, [{$addFields: { "_id": "", "thisRef": "id1", "thatRef": "id2"}}], {upsert: true})

// COPY EntityToCopySource1::valueToCopy1 TO EntityToCopyTarget::copy1 WHERE _id = thisRef
MongoDBScriptFeature_Ops.EntityToCopySource1.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToCopyTarget.updateMany({ "thisRef": sDoc._id }, { $set: { "copy1": sDoc.valueToCopy1} }); })

// COPY EntityToCopySource1::valueToCopy2 TO EntityToCopyTarget::copy2 WHERE _id = thisRef
MongoDBScriptFeature_Ops.EntityToCopySource1.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToCopyTarget.updateMany({ "thisRef": sDoc._id }, { $set: { "copy2": sDoc.valueToCopy2} }); })

// COPY EntityToCopySource1::valueToCopy3 TO EntityToCopyTarget::copy3 WHERE _id = thisRef
MongoDBScriptFeature_Ops.EntityToCopySource1.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToCopyTarget.updateMany({ "thisRef": sDoc._id }, { $set: { "copy3": sDoc.valueToCopy3} }); })

// COPY EntityToCopySource2::valueToCopy4 TO EntityToCopyTarget::valueToCopy4 WHERE _id = thatRef

MongoDBScriptFeature_Ops.EntityToCopySource2.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToCopyTarget.updateMany({ "thatRef": sDoc._id }, { $set: { "valueToCopy4": sDoc.valueToCopy4} }); })

// ADD ENTITY EntityToMoveSource1: { +_id: String ( "id1" ), valueToMove1: String ( "MOVE_THIS" ), valueToMove2: List, valueToMove3: Map }
MongoDBScriptFeature_Ops.createCollection("EntityToMoveSource1")
MongoDBScriptFeature_Ops.EntityToMoveSource1.updateMany({}, [{$addFields: { "_id": "id1", "valueToMove1": "MOVE_THIS", "valueToMove2": [], "valueToMove3": {$literal: {}}}}], {upsert: true})

// ADD ENTITY EntityToMoveSource2: { +_id: String ( "id2" ), valueToMove4: String ( "MOVE_THAT" ) }
MongoDBScriptFeature_Ops.createCollection("EntityToMoveSource2")
MongoDBScriptFeature_Ops.EntityToMoveSource2.updateMany({}, [{$addFields: { "_id": "id2", "valueToMove4": "MOVE_THAT"}}], {upsert: true})

// ADD ENTITY EntityToMoveTarget: { +_id: String, thisRef: String ( "id1" ), thatRef: String ( "id2" ) }

MongoDBScriptFeature_Ops.createCollection("EntityToMoveTarget")
MongoDBScriptFeature_Ops.EntityToMoveTarget.updateMany({}, [{$addFields: { "_id": "", "thisRef": "id1", "thatRef": "id2"}}], {upsert: true})

// MOVE EntityToMoveSource1::valueToMove1 TO EntityToMoveTarget::move1 WHERE _id = thisRef
MongoDBScriptFeature_Ops.EntityToMoveSource1.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToMoveTarget.updateMany({ "thisRef": sDoc._id }, { $set: { "move1": sDoc.valueToMove1} }); })
MongoDBScriptFeature_Ops.EntityToMoveSource1.updateMany({}, {$unset: {"valueToMove1": 1}})

// MOVE EntityToMoveSource1::valueToMove2 TO EntityToMoveTarget::move2 WHERE _id = thisRef
MongoDBScriptFeature_Ops.EntityToMoveSource1.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToMoveTarget.updateMany({ "thisRef": sDoc._id }, { $set: { "move2": sDoc.valueToMove2} }); })
MongoDBScriptFeature_Ops.EntityToMoveSource1.updateMany({}, {$unset: {"valueToMove2": 1}})

// MOVE EntityToMoveSource1::valueToMove3 TO EntityToMoveTarget::move3 WHERE _id = thisRef
MongoDBScriptFeature_Ops.EntityToMoveSource1.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToMoveTarget.updateMany({ "thisRef": sDoc._id }, { $set: { "move3": sDoc.valueToMove3} }); })
MongoDBScriptFeature_Ops.EntityToMoveSource1.updateMany({}, {$unset: {"valueToMove3": 1}})

// MOVE EntityToMoveSource2::valueToMove4 TO EntityToMoveTarget::move4 WHERE _id = thatRef

MongoDBScriptFeature_Ops.EntityToMoveSource2.find().forEach( function(sDoc) { MongoDBScriptFeature_Ops.EntityToMoveTarget.updateMany({ "thatRef": sDoc._id }, { $set: { "move4": sDoc.valueToMove4} }); })
MongoDBScriptFeature_Ops.EntityToMoveSource2.updateMany({}, {$unset: {"valueToMove4": 1}})

// ADD ENTITY EntityToNest: { +_id: String, name, age, street, postalCode, city, aList: List, aMap: Map }

MongoDBScriptFeature_Ops.createCollection("EntityToNest")
MongoDBScriptFeature_Ops.EntityToNest.updateMany({}, [{$addFields: { "_id": "", "name": null, "age": null, "street": null, "postalCode": null, "city": null, "aList": [], "aMap": {$literal: {}}}}], {upsert: true})

MongoDBScriptFeature_Ops.EntityToNest.bulkWrite([
// ADD AGGR EntityToNest::nestAggrNest1: { nest1, nest2, nest3 }&
  {updateMany: {filter: {}, update: [{$addFields: { "nestAggrNest1": {"nest1": null, "nest2": null, "nest3": null}}}], upsert: true}},
// ADD AGGR EntityToNest::nestAggrNest2: { nest4, nest5, nest6 }+

  {updateMany: {filter: {}, update: [{$addFields: { "nestAggrNest2": [{"nest4": null, "nest5": null, "nest6": null}]}}], upsert: true}},
// NEST EntityToNest::street, postalCode, city, nestAggrNest1, nestAggrNest2 TO nestedAggr

  {updateMany: {filter: {}, update: {$rename: { "street": "nestedAggr.street", "postalCode": "nestedAggr.postalCode", "city": "nestedAggr.city", "nestAggrNest1": "nestedAggr.nestAggrNest1", "nestAggrNest2": "nestedAggr.nestAggrNest2" }}}}
])

// ADD ENTITY EntityToUnnest: { +_id: String, name, age }

MongoDBScriptFeature_Ops.createCollection("EntityToUnnest")
MongoDBScriptFeature_Ops.EntityToUnnest.updateMany({}, [{$addFields: { "_id": "", "name": null, "age": null}}], {upsert: true})

MongoDBScriptFeature_Ops.EntityToUnnest.bulkWrite([
// ADD AGGR EntityToUnnest::unnestAggrNest1: { nest1, nest2, nest3, street, postalCode, city, aList: List, aMap: Map }&
  {updateMany: {filter: {}, update: [{$addFields: { "unnestAggrNest1": {"nest1": null, "nest2": null, "nest3": null, "street": null, "postalCode": null, "city": null, "aList": [], "aMap": {$literal: {}}}}}], upsert: true}},
// ADD AGGR EntityToUnnest::unnestAggrNest2: { nest4, nest5, nest6 }&

  {updateMany: {filter: {}, update: [{$addFields: { "unnestAggrNest2": {"nest4": null, "nest5": null, "nest6": null}}}], upsert: true}},
// UNNEST EntityToUnnest::unnestAggrNest1.street, unnestAggrNest1.postalCode, unnestAggrNest1.city, unnestAggrNest1.aList, unnestAggrNest1.aMap, unnestAggrNest2.nest4
  {updateMany: {filter: {}, update: {$rename: { "unnestAggrNest1.street": "street", "unnestAggrNest1.postalCode": "postalCode", "unnestAggrNest1.city": "city", "unnestAggrNest1.aList": "aList", "unnestAggrNest1.aMap": "aMap", "unnestAggrNest2.nest4": "nest4"}}}}
])

