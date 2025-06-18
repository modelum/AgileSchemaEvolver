MongoDBScriptEntity_Ops = db.getSiblingDB("MongoDBScriptEntity_Ops")


// ADD ENTITY EntityAdded1: { +_id: Identifier }
MongoDBScriptEntity_Ops.createCollection("EntityAdded1")
MongoDBScriptEntity_Ops.EntityAdded1.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

// ADD ENTITY EntityAdded2: { +_id: Identifier }
MongoDBScriptEntity_Ops.createCollection("EntityAdded2")
MongoDBScriptEntity_Ops.EntityAdded2.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

// ADD ENTITY EntityAdded3: { +_id: Identifier }

MongoDBScriptEntity_Ops.createCollection("EntityAdded3")
MongoDBScriptEntity_Ops.EntityAdded3.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

// DELETE ENTITY EntityAdded2

MongoDBScriptEntity_Ops.EntityAdded2.drop()

// RENAME ENTITY EntityAdded3 TO EntityRenamed

MongoDBScriptEntity_Ops.EntityAdded3.renameCollection("EntityRenamed")

// ADD ENTITY EntityToExtract: { +_id: Identifier, feat1, feat2, feat3, feat4 }

MongoDBScriptEntity_Ops.createCollection("EntityToExtract")
MongoDBScriptEntity_Ops.EntityToExtract.updateMany({}, [{$addFields: { "_id": ObjectId(), "feat1": null, "feat2": null, "feat3": null, "feat4": null}}], {upsert: true})

// EXTRACT ENTITY EntityToExtract INTO EntityExtracted ( _id, feat2, feat4 )

MongoDBScriptEntity_Ops.EntityToExtract.aggregate([
  { $project: { "_id": 1, "feat2": 1, "feat4": 1 }},
  { $out: "EntityExtracted" }
])

// ADD ENTITY EntityToSplit: { +_id: Identifier, attr1: String, attr2: String, attr3: String, attr4: String, attr5: String, attr6: String }

MongoDBScriptEntity_Ops.createCollection("EntityToSplit")
MongoDBScriptEntity_Ops.EntityToSplit.updateMany({}, [{$addFields: { "_id": ObjectId(), "attr1": "", "attr2": "", "attr3": "", "attr4": "", "attr5": "", "attr6": ""}}], {upsert: true})

// SPLIT ENTITY EntityToSplit INTO EntitySplit1 ( _id, attr1, attr2, attr3 ), EntitySplit2 ( _id, attr1, attr5, attr6 )

MongoDBScriptEntity_Ops.EntityToSplit.aggregate([
  { $project: { "_id": 1, "attr1": 1, "attr2": 1, "attr3": 1 }},
  { $out: "EntitySplit1" }
])
MongoDBScriptEntity_Ops.EntityToSplit.aggregate([
  { $project: { "_id": 1, "attr1": 1, "attr5": 1, "attr6": 1 }},
  { $out: "EntitySplit2" }
])
MongoDBScriptEntity_Ops.EntityToSplit.drop()

// ADD ENTITY EntityToMerge1: { +_id: String ( "id" ), a: String, b: Number }
MongoDBScriptEntity_Ops.createCollection("EntityToMerge1")
MongoDBScriptEntity_Ops.EntityToMerge1.updateMany({}, [{$addFields: { "_id": "id", "a": "", "b": NumberInt(0)}}], {upsert: true})

// ADD ENTITY EntityToMerge2: { +_id: String ( "id" ), c: List, b }

MongoDBScriptEntity_Ops.createCollection("EntityToMerge2")
MongoDBScriptEntity_Ops.EntityToMerge2.updateMany({}, [{$addFields: { "_id": "id", "c": [], "b": null}}], {upsert: true})

// MERGE ENTITY EntityToMerge1, EntityToMerge2 INTO EntityMerged WHERE EntityToMerge1._id = EntityToMerge2._id
MongoDBScriptEntity_Ops.EntityToMerge2.aggregate([{ $merge: { into: "EntityMerged", on: "_id", whenMatched: "merge", whenNotMatched: "insert" }}])
MongoDBScriptEntity_Ops.EntityToMerge1.aggregate([{ $merge: { into: "EntityMerged", on: "_id", whenMatched: "merge", whenNotMatched: "insert" }}])
MongoDBScriptEntity_Ops.EntityToMerge2.drop()
MongoDBScriptEntity_Ops.EntityToMerge1.drop()

