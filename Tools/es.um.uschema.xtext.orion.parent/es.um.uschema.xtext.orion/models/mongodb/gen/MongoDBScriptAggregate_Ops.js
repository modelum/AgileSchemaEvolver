MongoDBScriptAggregate_Ops = db.getSiblingDB("MongoDBScriptAggregate_Ops")


// ADD ENTITY EntityToAggr: { +_id: Identifier }

MongoDBScriptAggregate_Ops.createCollection("EntityToAggr")
MongoDBScriptAggregate_Ops.EntityToAggr.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

MongoDBScriptAggregate_Ops.EntityToAggr.bulkWrite([
// ADD AGGR EntityToAggr::aggrSimple : { attr1: String, attr2: Number, attr3: Map, attr4: List }&
  {updateMany: {filter: {}, update: [{$addFields: { "aggrSimple": {"attr1": "", "attr2": NumberInt(0), "attr3": {$literal: {}}, "attr4": []}}}], upsert: true}},
// ADD AGGR EntityToAggr::aggrList : { attr1: String, attr2: Number, attr3: Map, attr4: List }+
  {updateMany: {filter: {}, update: [{$addFields: { "aggrList": [{"attr1": "", "attr2": NumberInt(0), "attr3": {$literal: {}}, "attr4": []}]}}], upsert: true}},
// ADD AGGR EntityToAggr::aggrSimple.innerAggrSimple: { innerAttr1: String, innerAttr2: Number, innerAttr3: Map, innerAttr4: List }&
  {updateMany: {filter: {}, update: [{$addFields: { "aggrSimple.innerAggrSimple": {"innerAttr1": "", "innerAttr2": NumberInt(0), "innerAttr3": {$literal: {}}, "innerAttr4": []}}}], upsert: true}},
// ADD AGGR EntityToAggr::aggrSimple.innerAggrList: { innerAttr1: String, innerAttr2: Number, innerAttr3: Map, innerAttr4: List }+
  {updateMany: {filter: {}, update: [{$addFields: { "aggrSimple.innerAggrList": [{"innerAttr1": "", "innerAttr2": NumberInt(0), "innerAttr3": {$literal: {}}, "innerAttr4": []}]}}], upsert: true}},
// ADD AGGR EntityToAggr::strAggrSimpleChange: { attr1: String, attr2 }&
  {updateMany: {filter: {}, update: [{$addFields: { "strAggrSimpleChange": {"attr1": "", "attr2": null}}}], upsert: true}},
// ADD AGGR EntityToAggr::strAggrArrayChange: { attr1: String, attr2 }+
  {updateMany: {filter: {}, update: [{$addFields: { "strAggrArrayChange": [{"attr1": "", "attr2": null}]}}], upsert: true}},
// ADD AGGR EntityToAggr::numAggrSimpleChange: { attr1: Number, attr2 }&
  {updateMany: {filter: {}, update: [{$addFields: { "numAggrSimpleChange": {"attr1": NumberInt(0), "attr2": null}}}], upsert: true}},
// ADD AGGR EntityToAggr::numAggrArrayChange: { attr1: Number, attr2 }+

  {updateMany: {filter: {}, update: [{$addFields: { "numAggrArrayChange": [{"attr1": NumberInt(0), "attr2": null}]}}], upsert: true}},
// MULT AGGR EntityToAggr::strAggrSimpleChange, numAggrSimpleChange TO +
  {updateMany: {filter: {}, update: [{$set: { "strAggrSimpleChange": [ "$strAggrSimpleChange" ], "numAggrSimpleChange": [ "$numAggrSimpleChange" ] }}]}},
// MULT AGGR EntityToAggr::strAggrArrayChange, numAggrArrayChange TO &

  {updateMany: {filter: {}, update: [{$set: { "strAggrArrayChange": { $arrayElemAt: [ "$strAggrArrayChange", 0] }, "numAggrArrayChange": { $arrayElemAt: [ "$numAggrArrayChange", 0] } }}]}},
// ADD AGGR EntityToAggr::aggrByHand1: { string1: String }&

  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand1": {"string1": ""}}}], upsert: true}},
// ADD ATTR EntityToAggr::aggrByHand1.nullAttrSimpleChange
  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand1.nullAttrSimpleChange": null}}], "upsert": true}},
// ADD ATTR EntityToAggr::aggrByHand1.nullAttrArrayChange: List
  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand1.nullAttrArrayChange": []}}], "upsert": true}},
// ADD ATTR EntityToAggr::aggrByHand1.strAttrSimpleChange: String ("ref1")
  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand1.strAttrSimpleChange": "ref1"}}], "upsert": true}},
// ADD ATTR EntityToAggr::aggrByHand1.strAttrArrayChange: List<String> ("ref1")

  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand1.strAttrArrayChange": ["ref1"]}}], "upsert": true}},
// ADD AGGR EntityToAggr::aggrByHand2: { string2: String }&

  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand2": {"string2": ""}}}], upsert: true}},
// ADD ATTR EntityToAggr::aggrByHand2.numAttrSimpleChange: Number (33)
  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand2.numAttrSimpleChange": NumberInt(33)}}], "upsert": true}},
// ADD ATTR EntityToAggr::aggrByHand2.numAttrArrayChange: List<Number> (44)

  {updateMany: {filter: {}, update: [{$addFields: { "aggrByHand2.numAttrArrayChange": [NumberInt(44)]}}], "upsert": true}},
// MULT AGGR EntityToAggr::aggrByHand1 TO +

  {updateMany: {filter: {}, update: [{$set: { "aggrByHand1": [ "$aggrByHand1" ] }}]}}
])

// ADD ENTITY EntityMorphAggr: { +_id }

MongoDBScriptAggregate_Ops.createCollection("EntityMorphAggr")
MongoDBScriptAggregate_Ops.EntityMorphAggr.updateMany({}, [{$addFields: { "_id": ObjectId()}}], {upsert: true})

MongoDBScriptAggregate_Ops.EntityMorphAggr.bulkWrite([
// ADD AGGR EntityMorphAggr::aggr1: { string1: String, string2: String }&
  {updateMany: {filter: {}, update: [{$addFields: { "aggr1": {"string1": "", "string2": ""}}}], upsert: true}},
// ADD AGGR EntityMorphAggr::aggr2: { aList: List, aMap: Map }&
  {updateMany: {filter: {}, update: [{$addFields: { "aggr2": {"aList": [], "aMap": {$literal: {}}}}}], upsert: true}},
// ADD AGGR EntityMorphAggr::aggr3: { string5: String, string6: String }+
  {updateMany: {filter: {}, update: [{$addFields: { "aggr3": [{"string5": "", "string6": ""}]}}], upsert: true}},
// ADD AGGR EntityMorphAggr::aggr4: { aSet: Set, aTuple: Tuple }+

  {updateMany: {filter: {}, update: [{$addFields: { "aggr4": [{"aSet": [], "aTuple": []}]}}], upsert: true}}
])

// MORPH AGGR EntityMorphAggr::aggr1 TO refToAggr1
MongoDBScriptAggregate_Ops.EntityMorphAggr.find().forEach(function(sDoc) {
    if (!sDoc.aggr1.hasOwnProperty('_id'))
      sDoc.aggr1._id = ObjectId().str;

    MongoDBScriptAggregate_Ops.Aggr1.insert(sDoc.aggr1);
    MongoDBScriptAggregate_Ops.EntityMorphAggr.updateMany({}, {$set: {"refToAggr1": sDoc.aggr1._id }})
});

// MORPH AGGR EntityMorphAggr::aggr2 TO refToAggr2
MongoDBScriptAggregate_Ops.EntityMorphAggr.find().forEach(function(sDoc) {
    if (!sDoc.aggr2.hasOwnProperty('_id'))
      sDoc.aggr2._id = ObjectId().str;

    MongoDBScriptAggregate_Ops.Aggr2.insert(sDoc.aggr2);
    MongoDBScriptAggregate_Ops.EntityMorphAggr.updateMany({}, {$set: {"refToAggr2": sDoc.aggr2._id }})
});

// MORPH AGGR EntityMorphAggr::aggr3 TO refToAggr3
MongoDBScriptAggregate_Ops.EntityMorphAggr.find().forEach(function(sDoc) {
    var ids = [];
    sDoc.aggr3.forEach(function(i)
    {
      if (!i.hasOwnProperty('_id'))
        i._id = ObjectId().str;

      ids.push(i._id);
    });
    MongoDBScriptAggregate_Ops.Aggr3.insertMany(sDoc.aggr3);
    MongoDBScriptAggregate_Ops.EntityMorphAggr.updateMany({}, {$set: {"refToAggr3": ids}});
});

// MORPH AGGR EntityMorphAggr::aggr4 TO refToAggr4
MongoDBScriptAggregate_Ops.EntityMorphAggr.find().forEach(function(sDoc) {
    var ids = [];
    sDoc.aggr4.forEach(function(i)
    {
      if (!i.hasOwnProperty('_id'))
        i._id = ObjectId().str;

      ids.push(i._id);
    });
    MongoDBScriptAggregate_Ops.Aggr4.insertMany(sDoc.aggr4);
    MongoDBScriptAggregate_Ops.EntityMorphAggr.updateMany({}, {$set: {"refToAggr4": ids}});
});

