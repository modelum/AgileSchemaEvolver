MongoDBScriptReference_Ops = db.getSiblingDB("MongoDBScriptReference_Ops")


// ADD ENTITY EntityDummy: { +_id: Identifier }
MongoDBScriptReference_Ops.createCollection("EntityDummy")
MongoDBScriptReference_Ops.EntityDummy.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

// ADD ENTITY EntityRefs: { +_id: Identifier }

MongoDBScriptReference_Ops.createCollection("EntityRefs")
MongoDBScriptReference_Ops.EntityRefs.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

MongoDBScriptReference_Ops.EntityRefs.bulkWrite([
// ADD REF EntityRefs::ref1: String& TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref1": ""}}], "upsert": true}},
// ADD REF EntityRefs::ref2: Integer+ TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref2": [NumberInt(0)]}}], "upsert": true}},
// ADD REF EntityRefs::ref3: String& TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref3": ""}}], "upsert": true}},
// ADD REF EntityRefs::ref4: String+ TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref4": [""]}}], "upsert": true}},
// ADD REF EntityRefs::ref5: Number& TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref5": NumberInt(0)}}], "upsert": true}},
// ADD REF EntityRefs::ref6: Number+ TO EntityDummy

  {updateMany: {filter: {}, update: [{$addFields: { "ref6": [NumberInt(0)]}}], "upsert": true}},
// CAST REF EntityRefs::ref1, ref2 TO Double
  {updateMany: {filter: {}, update: [{$set: { "ref1": { $convert: { input: "$ref1", to: 1 }} , "ref2": { $convert: { input: "$ref2", to: 1 }}  }}]}},
// CAST REF EntityRefs::ref3, ref4 TO Number
  {updateMany: {filter: {}, update: [{$set: { "ref3": { $convert: { input: "$ref3", to: 16 }} , "ref4": { $convert: { input: "$ref4", to: 16 }}  }}]}},
// CAST REF EntityRefs::ref5, ref6 TO String

  {updateMany: {filter: {}, update: [{$set: { "ref5": { $convert: { input: "$ref5", to: 2 }} , "ref6": { $convert: { input: "$ref6", to: 2 }}  }}]}},
// ADD REF EntityRefs::ref7: String& TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref7": ""}}], "upsert": true}},
// ADD REF EntityRefs::ref8: String+ TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref8": [""]}}], "upsert": true}},
// ADD REF EntityRefs::ref9: Number& TO EntityDummy
  {updateMany: {filter: {}, update: [{$addFields: { "ref9": NumberInt(0)}}], "upsert": true}},
// ADD REF EntityRefs::ref10: Number+ TO EntityDummy

  {updateMany: {filter: {}, update: [{$addFields: { "ref10": [NumberInt(0)]}}], "upsert": true}},
// MULT REF EntityRefs::ref7, ref9 TO +
  {updateMany: {filter: {}, update: [{$set: { "ref7": [ "$ref7" ], "ref9": [ "$ref9" ] }}]}},
// MULT REF EntityRefs::ref8, ref10 TO &

  {updateMany: {filter: {}, update: [{$set: { "ref8": { $arrayElemAt: [ "$ref8", 0] }, "ref10": { $arrayElemAt: [ "$ref10", 0] } }}]}}
])

// ADD ENTITY EntityRef1: { +_id: String ( "refId1" ), value1: String ( "value1" ), value2: String ( "value2" ) }
MongoDBScriptReference_Ops.createCollection("EntityRef1")
MongoDBScriptReference_Ops.EntityRef1.updateMany({}, [{$addFields: { "_id": "refId1", "value1": "value1", "value2": "value2"}}], {upsert: true})

// ADD ENTITY EntityRef2: { +_id: String ( "refId2" ), value3: String ( "value3" ), value4: String ( "value4" ) }
MongoDBScriptReference_Ops.createCollection("EntityRef2")
MongoDBScriptReference_Ops.EntityRef2.updateMany({}, [{$addFields: { "_id": "refId2", "value3": "value3", "value4": "value4"}}], {upsert: true})

// ADD ENTITY EntityRef3: { +_id: String ( "refId3" ), value5: String ( "value6" ), value6: String ( "value6" ) }
MongoDBScriptReference_Ops.createCollection("EntityRef3")
MongoDBScriptReference_Ops.EntityRef3.updateMany({}, [{$addFields: { "_id": "refId3", "value5": "value6", "value6": "value6"}}], {upsert: true})

// ADD ENTITY EntityRef4: { +_id: String ( "refId4" ), value7: String ( "value7" ), value8: String ( "value8" ) }
MongoDBScriptReference_Ops.createCollection("EntityRef4")
MongoDBScriptReference_Ops.EntityRef4.updateMany({}, [{$addFields: { "_id": "refId4", "value7": "value7", "value8": "value8"}}], {upsert: true})

// ADD ENTITY EntityRef5: { +_id: String ( "refId5" ), value9: String ( "value9" ), value10: String ( "value10" ) }
MongoDBScriptReference_Ops.createCollection("EntityRef5")
MongoDBScriptReference_Ops.EntityRef5.updateMany({}, [{$addFields: { "_id": "refId5", "value9": "value9", "value10": "value10"}}], {upsert: true})

// ADD ENTITY EntityMorphRef: { +_id }

MongoDBScriptReference_Ops.createCollection("EntityMorphRef")
MongoDBScriptReference_Ops.EntityMorphRef.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

MongoDBScriptReference_Ops.EntityMorphRef.bulkWrite([
// ADD REF EntityMorphRef::refToEntity1: String ("refId1")& TO EntityRef1
  {updateMany: {filter: {}, update: [{$addFields: { "refToEntity1": "refId1"}}], "upsert": true}},
// ADD REF EntityMorphRef::refToEntity2: String ("refId2")& TO EntityRef2
  {updateMany: {filter: {}, update: [{$addFields: { "refToEntity2": "refId2"}}], "upsert": true}},
// ADD REF EntityMorphRef::refToEntity3: String ("refId3")& TO EntityRef3
  {updateMany: {filter: {}, update: [{$addFields: { "refToEntity3": "refId3"}}], "upsert": true}},
// ADD REF EntityMorphRef::refToEntity4: String ("refId4")+ TO EntityRef4
  {updateMany: {filter: {}, update: [{$addFields: { "refToEntity4": ["refId4"]}}], "upsert": true}},
// ADD REF EntityMorphRef::refToEntity5: String ("refId5")+ TO EntityRef5

  {updateMany: {filter: {}, update: [{$addFields: { "refToEntity5": ["refId5"]}}], "upsert": true}}
])

// MORPH REF EntityMorphRef::refToEntity1 TO aggrEntity1
MongoDBScriptReference_Ops.EntityMorphRef.aggregate([
  { $lookup: { from: "EntityRef1", localField: "refToEntity1", foreignField: "_id", as: "aggrEntity1" }},
  { $addFields: { "aggrEntity1": { $arrayElemAt: [ "$aggrEntity1", 0] }}},
  { $out: "EntityMorphRef" }
])

// MORPH REF EntityMorphRef::refToEntity2 ( rmId ) TO aggrEntity2
MongoDBScriptReference_Ops.EntityMorphRef.aggregate([
  { $lookup: { from: "EntityRef2", localField: "refToEntity2", foreignField: "_id", as: "aggrEntity2" }},
  { $addFields: { "aggrEntity2": { $arrayElemAt: [ "$aggrEntity2", 0] }}},
  { $out: "EntityMorphRef" }
])
MongoDBScriptReference_Ops.EntityMorphRef.updateMany({}, { $unset: {"aggrEntity2._id": 1}})

// MORPH REF EntityMorphRef::refToEntity3 ( rmEntity ) TO aggrEntity3
MongoDBScriptReference_Ops.EntityMorphRef.aggregate([
  { $lookup: { from: "EntityRef3", localField: "refToEntity3", foreignField: "_id", as: "aggrEntity3" }},
  { $addFields: { "aggrEntity3": { $arrayElemAt: [ "$aggrEntity3", 0] }}},
  { $out: "EntityMorphRef" }
])
MongoDBScriptReference_Ops.EntityRef3.drop()

// MORPH REF EntityMorphRef::refToEntity4 TO aggrEntity4
MongoDBScriptReference_Ops.EntityMorphRef.aggregate([
  { $lookup: { from: "EntityRef4", localField: "refToEntity4", foreignField: "_id", as: "aggrEntity4" }},
  { $out: "EntityMorphRef" }
])

// MORPH REF EntityMorphRef::refToEntity5 ( rmId rmEntity ) TO aggrEntity5
MongoDBScriptReference_Ops.EntityMorphRef.aggregate([
  { $lookup: { from: "EntityRef5", localField: "refToEntity5", foreignField: "_id", as: "aggrEntity5" }},
  { $out: "EntityMorphRef" }
])
MongoDBScriptReference_Ops.EntityMorphRef.updateMany({}, { $unset: {"aggrEntity5.$[]._id": 1}})
MongoDBScriptReference_Ops.EntityRef5.drop()

