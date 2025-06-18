MongoDBEntityVariationSchema = db.getSiblingDB("MongoDBEntityVariationSchema")


// DELVAR ENTITY EntityToDelVar::2

MongoDBEntityVariationSchema.EntityToDelVar.remove({"attr3": {$exists: true}, "attr4": {$exists: true}})

// ADAPT ENTITY EntityToAdapt::2 TO 3

MongoDBEntityVariationSchema.EntityToAdapt.updateMany({"attr3": {$exists: true}, "attr4": {$exists: true}}, [
  {$unset: ["attr3", "attr4"]},
  {$addFields: {"attr5": [""], "attr6": ""}}
])

// UNION ENTITY EntityToUnion_1
MongoDBEntityVariationSchema.EntityToUnion_1.updateMany({},[{$addFields: {
  "attr1": {$ifNull: [ "$attr1", NumberInt(0)]}
}}])

// UNION ENTITY EntityToUnion_2
MongoDBEntityVariationSchema.EntityToUnion_2.updateMany({},[{$addFields: {
  "attr": {$ifNull: [ "$attr", NumberInt(0)]},
  "attr1": {$ifNull: [ "$attr1", ""]},
  "attr2": {$ifNull: [ "$attr2", 0.0]},
  "attr3": {$ifNull: [ "$attr3", false]},
  "attr4": {$ifNull: [ "$attr4", [""]]},
  "attr5": {$ifNull: [ "$attr5", [""]]},
  "attr6": {$ifNull: [ "$attr6", ""]}
}}])

