MongoDBScriptAttribute_Ops = db.getSiblingDB("MongoDBScriptAttribute_Ops")


// ADD ENTITY EntityToAdd: { +_id: String }

MongoDBScriptAttribute_Ops.createCollection("EntityToAdd")
MongoDBScriptAttribute_Ops.EntityToAdd.updateMany({}, [{$addFields: { "_id": ""}}], {upsert: true})

MongoDBScriptAttribute_Ops.getCollectionNames().forEach(function(collName)
{
  MongoDBScriptAttribute_Ops[collName].bulkWrite([
// ADD ATTR *::addAttrSinTipo
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrSinTipo": null}}], "upsert": true}},
// ADD ATTR *::addAttrStr: String
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrStr": ""}}], "upsert": true}},
// ADD ATTR *::addAttrNum: Number
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrNum": NumberInt(0)}}], "upsert": true}},
// ADD ATTR *::addAttrDouble: Double
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrDouble": 0.0}}], "upsert": true}},
// ADD ATTR *::addAttrBool: Boolean
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrBool": false}}], "upsert": true}},
// ADD ATTR *::addAttrSet: Set
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrSet": []}}], "upsert": true}},
// ADD ATTR *::addAttrList: List
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrList": []}}], "upsert": true}},
// ADD ATTR *::addAttrTuple: Tuple
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrTuple": []}}], "upsert": true}},
// ADD ATTR *::addAttrMap: Map
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrMap": {$literal: {}}}}], "upsert": true}},
// ADD ATTR *::addAttrNull: Null
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrNull": null}}], "upsert": true}},
// ADD ATTR *::addAttrStrVal: String ("initValue")
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrStrVal": "initValue"}}], "upsert": true}},
// ADD ATTR *::addAttrNumVal: Number (33)
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrNumVal": NumberInt(33)}}], "upsert": true}},
// ADD ATTR *::addAttrDoubleVal: Double (33.1)
  {updateMany: {filter: {}, update: [{$addFields: { "addAttrDoubleVal": 33.1}}], "upsert": true}},
// ADD ATTR *::addAttrBoolVal: Boolean (false)

  {updateMany: {filter: {}, update: [{$addFields: { "addAttrBoolVal": false}}], "upsert": true}}
  ])
})

// ADD ENTITY EntityToCast: { +_id: Identifier, +attrToCast, attrToCastNull: Null, attrToCastStr: String, attrToCastNum: Number, attrToCastDouble: Double, attrToCastBool: Boolean }

MongoDBScriptAttribute_Ops.createCollection("EntityToCast")
MongoDBScriptAttribute_Ops.EntityToCast.updateMany({}, [{$addFields: { "_id": ObjectId(), "attrToCast": null, "attrToCastNull": null, "attrToCastStr": "", "attrToCastNum": NumberInt(0), "attrToCastDouble": 0.0, "attrToCastBool": false}}], {upsert: true})

MongoDBScriptAttribute_Ops.EntityToCast.bulkWrite([
// CAST ATTR EntityToCast::attrToCast, attrToCastStr, attrToCastDouble TO Bool
  {updateMany: {filter: {}, update: [{$set: { "attrToCast": { $convert: { input: "$attrToCast", to: 8 }} , "attrToCastStr": { $convert: { input: "$attrToCastStr", to: 8 }} , "attrToCastDouble": { $convert: { input: "$attrToCastDouble", to: 8 }}  }}]}},
// CAST ATTR EntityToCast::attrToCastNull TO Number
  {updateMany: {filter: {}, update: [{$set: { "attrToCastNull": { $convert: { input: "$attrToCastNull", to: 16 }}  }}]}},
// CAST ATTR EntityToCast::attrToCastNum, attrToCastBool TO String
  {updateMany: {filter: {}, update: [{$set: { "attrToCastNum": { $convert: { input: "$attrToCastNum", to: 2 }} , "attrToCastBool": { $convert: { input: "$attrToCastBool", to: 2 }}  }}]}}
])

