package es.um.uschema.xtext.orion.m2t

import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.orion.orion.EntityMergeOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.AttributeOrReferenceCastSpec
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureSelector
import java.util.ArrayList
import es.um.uschema.xtext.orion.orion.ReferenceOrAggregateMultiplicitySpec
import es.um.uschema.xtext.orion.utils.OrionUtils
import es.um.uschema.xtext.orion.orion.FeatureAllocateSpec
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.ConditionDecl
import es.um.uschema.xtext.orion.m2t.utils.MongoDBTransactionModule
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.athena.athena.Null
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.orion.validation.m2t.MongoDBValidator
import es.um.uschema.xtext.athena.utils.AthenaFactory
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp
import java.util.Arrays
import es.um.uschema.xtext.athena.athena.AthenaSchema
import org.eclipse.xtext.EcoreUtil2
import es.um.uschema.xtext.orion.utils.costs.MongoDBModelCost
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.orion.utils.updater.AthenaSchemaUpdater
import es.um.uschema.xtext.athena.utils.TypeConverter
import es.um.uschema.xtext.orion.orion.SchemaTypeOp
import es.um.uschema.xtext.orion.orion.RelationshipOp
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.athena.athena.OptionPrimitiveType
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.athena.athena.SimpleFeature

class Orion2MongoDB
{
  String indexName
  String dbName
  AthenaSchemaUpdater schemaUpdater
  AthenaHandler aHandler
  TypeConverter tConverter
  MongoDBValidator validator
  MongoDBTransactionModule tModule
  MongoDBModelCost modelCost
  OrionIO orionIO
  java.util.List<String> scripts
  java.util.List<AthenaSchema> schemas

  new(Boolean transactions)
  {
    this.indexName = "TEMP_INDEX"
    this.dbName = null
    this.aHandler = new AthenaHandler()
    this.tConverter = new TypeConverter()
    this.validator = new MongoDBValidator()
    this.tModule = new MongoDBTransactionModule(transactions)
    this.modelCost = new MongoDBModelCost()
    this.orionIO = new OrionIO()
    this.scripts = new ArrayList<String>()
    this.schemas = new ArrayList<AthenaSchema>()
  }

  def java.util.List<String> m2t(OrionOperations orion)
  {
    this.schemas.clear()
    this.scripts.clear()

    val result = new StringBuilder()
    val schema = orion.imports !== null ?
      new AthenaNormalizer().m2m(orion.imports.importedNamespace)
      :
    // If not, we create a new brand schema but with VersionId = 0
      new AthenaFactory().createAthenaSchema(orion.name, 0)

    // If the schema was created from scratch, disable validation
    // Else, if a schema was provided, activate validation
    schemaUpdater = new AthenaSchemaUpdater(schema, orion.imports !== null)

    dbName = schema.id.name

    // Sequence of operations
    if (!orion.operations.empty)
    {
      result.append(generateHeader(schema.id.name))
      result.append(generateOperations(orion.operations))

      // Now we increment the schema version: 0 to 1 if no schema was provided
      schema.id.version = schema.id.version + 1
      schemas.add(schemaUpdater.schema)
      scripts.add(result.toString)
    }
    // Sequence of evolution blocks
    else
    {
      for (eBlock : orion.evolBlocks)
      {
        if (tModule.isTransactional(orion.evolBlocks))
          result.append(tModule.generateTransactionalBegin(dbName))
        else
          result.append(generateHeader(schema.id.name))

        if (tModule.isTransactional(eBlock.operations.head))
          result.append(tModule.generateTransactionBegin)

        result.append(generateOperations(eBlock.operations))

        if (tModule.inTransaction)
          result.append(tModule.generateTransactionEnd)

        if (tModule.isTransactional(orion.evolBlocks))
          result.append(tModule.generateTransactionalEnd())

        // Now we increment the schema version: 0 to 1 if no schema was provided
        schema.id.version = schema.id.version + 1
        schemas.add(EcoreUtil2.copy(schemaUpdater.schema))
        scripts.add(result.toString)
        result.length = 0
      }
    }

    validator.summary

    println(this.modelCost.showCostMap)

    return this.scripts
  }

  def java.util.List<AthenaSchema> getSchemas()
  {
    return this.schemas
  }

  def generateHeader(String dbName)
  '''
    «dbName» = db.getSiblingDB("«dbName»")


  '''

  private def generateOperations(java.util.List<BasicOperation> operations)
  {
    val result = new StringBuilder()
    val iter = operations.iterator
    val opBatch = new ArrayList

    while(iter.hasNext)
    {
      val nextOp = iter.next
      if (isIndependent(nextOp))
      {
        if (!opBatch.empty)
        {
          result.append(generateBatchOps(opBatch))
          opBatch.clear
        }
        result.append(generateBatchOps(nextOp))
      }
      // If the current operation is compatible with the last stored operation, we stack them together
      else if (opBatch.empty || OrionUtils.haveSameSelector(opBatch.head, nextOp))
        opBatch.add(nextOp)
      // If not, generate content for the current stack, empty it and store the new operation.
      else
      {
        if (!opBatch.empty)
        {
          result.append(generateBatchOps(opBatch))
          opBatch.clear
        }

        opBatch.add(nextOp)
      }
    }

    // Generate instructions for last batch...
    if (!opBatch.empty)
      result.append(generateBatchOps(opBatch))

    return result
  }

  private def boolean isIndependent(BasicOperation op)
  {
    switch op
    {
      ReferenceMorphOp: true
      AggregateMorphOp: true
      ReferenceAddOp:   true
      FeatureCopyOp:    true
      FeatureMoveOp:    true

      default: false
    }
  }

  private def dispatch CharSequence generateBatchOps(BasicOperation op)
  '''«generateBatchOps(Arrays.asList(op))»'''

  private def dispatch CharSequence generateBatchOps(java.util.List<BasicOperation> ops)
  '''
    «IF tModule.inTransaction && !tModule.isTransactional(ops.head)»
      «tModule.generateTransactionEnd»
    «ENDIF»
    «IF !tModule.inTransaction && tModule.isTransactional(ops.head)»
      «tModule.generateTransactionBegin»
    «ENDIF»
    «IF ops.size == 1»
      « { validator.checkBasicOperation(schemaUpdater.schema, ops.head); "" } »
      // «orionIO.serialize(ops.head)»
      «IF isIndependent(ops.head)»«generateIndex(ops.head)»«ENDIF»
      «IF !(ops.head instanceof SchemaTypeOp)»«generateSingleBegin(OrionUtils.getSelector(ops.head))»«ENDIF»«generateBasicOp(ops.head, false)»«IF !(ops.head instanceof SchemaTypeOp)»«generateSingleEnd(OrionUtils.getSelector(ops.head))»«ENDIF»
      «schemaUpdater.processOperation(ops.head)»
      «modelCost.addToCosts(ops.head)»
    «ELSE»
      «generateBatchBegin(OrionUtils.getSelector(ops.head))»
      «FOR op : ops SEPARATOR ","»
        « { validator.checkBasicOperation(schemaUpdater.schema, op); "" } »
        // «orionIO.serialize(op)»
        «generateBasicOp(op, true)»
        «schemaUpdater.processOperation(op)»
        «modelCost.addToCosts(op)»
      «ENDFOR»
      «generateBatchEnd(OrionUtils.getSelector(ops.head))»
    «ENDIF»

  '''

  private def generateSingleBegin(FeatureSelector selector)
  '''
    «dbName».«IF selector.forAll»getCollectionNames().forEach(function(collName)
    {
      «dbName»[collName]«ELSE»«selector.ref»«ENDIF»'''

  private def generateSingleEnd(FeatureSelector selector)
  '''«IF selector.forAll»})«ENDIF»'''

  private def generateBatchBegin(FeatureSelector selector)
  '''
    «dbName».«IF selector.forAll»getCollectionNames().forEach(function(collName)
    {
      «dbName»[collName]«ELSE»«selector.ref»«ENDIF».bulkWrite([
  '''

  private def generateBatchEnd(FeatureSelector selector)
  '''
  «IF selector.forAll»
    ])
  })
  «ELSE»
  ])
  «ENDIF»'''

  private def dispatch generateBasicOp(EntityAddOp op, boolean inBulk)
  '''
    «dbName».createCollection("«op.spec.name»")
    «IF !op.spec.features.isNullOrEmpty»
      «dbName».«op.spec.name».updateMany({}, [{$addFields: { «FOR f : op.spec.features SEPARATOR ", "»«generateSimpleFeature(f.name, f.type, f.defaultValue)»«ENDFOR»}}], {upsert: true})
    «ENDIF»
  '''

  private def dispatch generateBasicOp(EntityDeleteOp op, boolean inBulk)
  '''
    «dbName».«op.spec.ref».drop()
  '''

  private def dispatch generateBasicOp(EntityRenameOp op, boolean inBulk)
  '''
    «dbName».«op.spec.ref».renameCollection("«op.spec.name»")
  '''

  private def dispatch generateBasicOp(EntitySplitOp op, boolean inBulk)
  '''
    «dbName».«op.spec.ref».aggregate([
      { $project: { «FOR feat : op.spec.features1.features SEPARATOR ", "»"«feat»": 1«ENDFOR» }},
      { $out: "«op.spec.name1»" }
    ])
    «dbName».«op.spec.ref».aggregate([
      { $project: { «FOR feat : op.spec.features2.features SEPARATOR ", "»"«feat»": 1«ENDFOR» }},
      { $out: "«op.spec.name2»" }
    ])
    «dbName».«op.spec.ref».drop()
  '''

  private def dispatch generateBasicOp(EntityExtractOp op, boolean inBulk)
  '''
    «dbName».«op.spec.ref».aggregate([
      { $project: { «FOR feat : op.spec.features.features SEPARATOR ", "»"«feat»": 1«ENDFOR» }},
      { $out: "«op.spec.name»" }
    ])
  '''

  private def dispatch generateBasicOp(EntityMergeOp op, boolean inBulk)
  '''
    «dbName».«op.spec.ref2».aggregate([{ $merge: { into: "«op.spec.name»", on: "«IF op.spec.condition.c2.contains(op.spec.ref2)»«op.spec.condition.c2.substring(op.spec.condition.c2.indexOf(".") + 1)»«ELSE»«op.spec.condition.c2»«ENDIF»", whenMatched: "merge", whenNotMatched: "insert" }}])
    «dbName».«op.spec.ref1».aggregate([{ $merge: { into: "«op.spec.name»", on: "«IF op.spec.condition.c1.contains(op.spec.ref1)»«op.spec.condition.c1.substring(op.spec.condition.c1.indexOf(".") + 1)»«ELSE»«op.spec.condition.c1»«ENDIF»", whenMatched: "merge", whenNotMatched: "insert" }}])
    «dbName».«op.spec.ref2».drop()
    «dbName».«op.spec.ref1».drop()
  '''

  private def dispatch generateBasicOp(EntityDelVarOp op, boolean inBulk)
  '''
    «val theVariation = aHandler.getVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.target)]»
    «dbName».«op.spec.ref».remove({
      «FOR feat : aHandler.getFeaturesInVariation(theVariation).filter(SimpleFeature) SEPARATOR ', '»"«feat.name»": {$exists: true}«ENDFOR»,
      «FOR feat : aHandler.getFeaturesNotInVariation(theVariation) SEPARATOR ', '»"«feat.name»": {$exists: false}«ENDFOR»
    })
  '''

  private def dispatch generateBasicOp(EntityAdaptOp op, boolean inBulk)
  '''
    «val sourceVariation = aHandler.getVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.source)]»
    «val targetVariation = aHandler.getVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.target)]»
    «val featuresToRemove = aHandler.getSimpleFeaturesDifference(aHandler.getFeaturesInVariation(sourceVariation), aHandler.getFeaturesInVariation(targetVariation))»
    «val featuresToAdd = aHandler.getSimpleFeaturesDifference(aHandler.getFeaturesInVariation(targetVariation), aHandler.getFeaturesInVariation(sourceVariation))»
    «dbName».«op.spec.ref».updateMany({
      «FOR feat : aHandler.getFeaturesInVariation(sourceVariation).filter(SimpleFeature) SEPARATOR ', ' AFTER ','»"«feat.name»": {$exists: true}«ENDFOR»
      «FOR feat : aHandler.getFeaturesNotInVariation(sourceVariation) SEPARATOR ', '»"«feat.name»": {$exists: false}«ENDFOR»}, [
      «IF !featuresToRemove.isEmpty»{$unset: [«FOR feat: featuresToRemove SEPARATOR ", "»"«feat.name»"«ENDFOR»]}«IF !featuresToAdd.isEmpty»,«ENDIF»«ENDIF»
      «IF !featuresToAdd.isEmpty»{$addFields: {«FOR feat: featuresToAdd SEPARATOR ", "»«generateSimpleFeature(feat.name, feat.type, null)»«ENDFOR»}}«ENDIF»
      ])
  '''

  // TODO: Fixme: For Aggregates
  private def dispatch generateBasicOp(EntityUnionOp op, boolean inBulk)
  '''
    «dbName».«op.spec.ref».updateMany({},[{$addFields: {
      «FOR feat: aHandler.getFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature).filter[f | !f.isKey] SEPARATOR ","»
        "«feat.name»": {$ifNull: [ "$«feat.name»", «generateDataType(feat.type as DataType, null)»]}
      «ENDFOR»
    }}])
  '''

  private def dispatch generateBasicOp(RelationshipOp op, boolean inBulk)
  '''// Operation not supported.'''

  private def dispatch CharSequence generateBasicOp(FeatureDeleteOp op, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter:{}, update: {$unset: { «FOR target : op.spec.selector.targets SEPARATOR ", "»"«target»": 1«ENDFOR» }}}}
    «ELSE»
      .updateMany({}, {$unset: { «FOR target : op.spec.selector.targets SEPARATOR ", "»"«target»": 1«ENDFOR» }})
    «ENDIF»
  '''

  private def dispatch CharSequence generateBasicOp(FeatureRenameOp op, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter: {}, update: {$rename: {"«op.spec.selector.target»": "«op.spec.name»" }}}}
    «ELSE»
      .updateMany({}, {$rename: {"«op.spec.selector.target»": "«op.spec.name»"}})
    «ENDIF»
  '''

  private def dispatch CharSequence generateBasicOp(FeatureCopyOp op, boolean inBulk)
  '''
    «generateAllocateSpec(op.spec)»
  '''

  private def dispatch CharSequence generateBasicOp(FeatureMoveOp op, boolean inBulk)
  '''
    «generateAllocateSpec(op.spec)»
    «dbName».«op.spec.sourceSelector.ref».updateMany({}, {$unset: {"«op.spec.sourceSelector.target»": 1}})
  '''

  private def dispatch CharSequence generateBasicOp(FeatureNestOp op, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter: {}, update: {$rename: { «FOR t : op.spec.selector.targets SEPARATOR ", "»"«t»": "«op.spec.name».«t»"«ENDFOR» }}}}
    «ELSE»
      .updateMany({}, {$rename: { «FOR t : op.spec.selector.targets SEPARATOR ", "»"«t»": "«op.spec.name».«t»"«ENDFOR»}})
    «ENDIF»
  '''

  private def dispatch CharSequence generateBasicOp(FeatureUnnestOp op, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter: {}, update: {$rename: { «FOR t : op.spec.selector.targets SEPARATOR ", "»"«t»": "«t.substring(t.indexOf(".") + 1)»"«ENDFOR»}}}}
    «ELSE»
      .updateMany({}, {$rename: { «FOR t : op.spec.selector.targets SEPARATOR ", "» "«t»": "«t.substring(t.indexOf(".") + 1)»"«ENDFOR»}})
    «ENDIF»
  '''

  private def dispatch CharSequence generateBasicOp(AttributeAddOp op, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter: {}, update: [{$addFields: { «generateSimpleFeature(op.spec.selector.target, op.spec.type, op.spec.defaultValue)»}}], "upsert": true}}
    «ELSE»
      .updateMany({}, [{$addFields: { «generateSimpleFeature(op.spec.selector.target, op.spec.type, op.spec.defaultValue)»}}], {upsert: true})
    «ENDIF»
  '''

  private def dispatch CharSequence generateBasicOp(AttributeCastOp op, boolean inBulk)
  '''
    «generateCastSpec(op.spec, inBulk)»
  '''

  // Promote operation does not have a direct translation to MongoDB.
  private def dispatch CharSequence generateBasicOp(AttributePromoteOp op, boolean inBulk)
  '''// Operation not supported.'''

  // Demote operation does not have a direct translation to MongoDB.
  private def dispatch CharSequence generateBasicOp(AttributeDemoteOp op, boolean inBulk)
  '''// Operation not supported.'''

  //TODO: What if there is no join condition? We should generate the operation the other way.
  private def dispatch CharSequence generateBasicOp(ReferenceAddOp op, boolean inBulk)
  '''
    .aggregate([
      { $lookup: { from: "«op.spec.ref»", localField: "«op.spec.condition.c1»", foreignField: "«op.spec.condition.c2»", as: "«op.spec.selector.target»" }},
      { $addFields: { "«op.spec.selector.target»": "$«op.spec.selector.target»._id"}},
      «IF aHandler.isMultiplicityToOne(op.spec.multiplicity)»{ $addFields: { "«op.spec.selector.target»": { $arrayElemAt: [ "$«op.spec.selector.target»", 0] }}},«ENDIF»
      { $out: «IF op.spec.selector.forAll»«dbName»[collName]._shortName«ELSE»"«op.spec.selector.ref»"«ENDIF» }
    ])

    «dropIndex(op)»
  '''

  private def dispatch CharSequence generateBasicOp(ReferenceMultiplicityOp op, boolean inBulk)
  '''
    «generateMultiplicitySpec(op.spec, inBulk)»
  '''

  private def dispatch CharSequence generateBasicOp(ReferenceCastOp op, boolean inBulk)
  '''
    «generateCastSpec(op.spec, inBulk)»
  '''

  private def dispatch CharSequence generateBasicOp(ReferenceMorphOp op, boolean inBulk)
  '''
    «val theReference = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref), op.spec.selector.target).type as SimpleReferenceTarget»
    «val theEntity = theReference.ref»
    .aggregate([
      { $lookup: { from: "«theEntity.name»", localField: "«op.spec.selector.target»", foreignField: "_id", as: "«op.spec.name»" }},
      «IF aHandler.isMultiplicityToOne(theReference.multiplicity)»{ $addFields: { "«op.spec.name»": { $arrayElemAt: [ "$«op.spec.name»", 0] }}},«ENDIF»
      { $out: «IF op.spec.selector.forAll»«dbName»[collName]._shortName«ELSE»"«op.spec.selector.ref»"«ENDIF» }
    ])
    «dbName».«op.spec.selector.ref».updateMany({}, {$unset: {"«op.spec.selector.target»": 1«IF op.spec.deleteId», "«IF aHandler.isMultiplicityToOne(theReference.multiplicity)»«op.spec.name»._id«ELSE»«op.spec.name».$[]._id«ENDIF»": 1«ENDIF»}})
    «IF op.spec.deleteEntity»
    «dbName».«theEntity.name».drop()
    «ENDIF»
  '''

  private def dispatch CharSequence generateBasicOp(AggregateAddOp op, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter: {}, update: [{$addFields: { "«op.spec.selector.target»": «IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»[«ENDIF»{«IF op.spec.features.empty»$literal: {}«ENDIF»«FOR f : op.spec.features SEPARATOR ", "»«generateSimpleFeature(f.name, f.type, f.defaultValue)»«ENDFOR»}«IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»]«ENDIF»}}], upsert: true}}
    «ELSE»
      .updateMany({}, [{$addFields: { "«op.spec.selector.target»": «IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»[«ENDIF»{«IF op.spec.features.empty»$literal: {}«ENDIF»«FOR f : op.spec.features SEPARATOR ", "»«generateSimpleFeature(f.name, f.type, f.defaultValue)»«ENDFOR»}«IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»]«ENDIF»}}], {upsert: true})
    «ENDIF»
  '''

  private def dispatch CharSequence generateBasicOp(AggregateMultiplicityOp op, boolean inBulk)
  '''
    «generateMultiplicitySpec(op.spec, inBulk)»
  '''

  private def dispatch CharSequence generateBasicOp(AggregateMorphOp op, boolean inBulk)
  '''.find().forEach(function(sDoc) {
    «IF aHandler.isMultiplicityToOne((aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref), op.spec.selector.target).type as SimpleAggregateTarget).multiplicity)»
      if (!sDoc.«op.spec.selector.target».hasOwnProperty('_id'))
        sDoc.«op.spec.selector.target»._id = ObjectId();

      «dbName».«op.spec.selector.target.toFirstUpper».insert(sDoc.«op.spec.selector.target»);
      sDoc.«op.spec.name» = sDoc.«op.spec.selector.target»._id;
      sDoc.«op.spec.selector.target» = null;
      «dbName».«op.spec.selector.ref».save(sDoc);
    «ELSE»
      var ids = [];
      sDoc.«op.spec.selector.target».forEach(function(i)
      {
        if (!i.hasOwnProperty('_id'))
          i._id = ObjectId();

        ids.push(i._id);
      });
      «dbName».«op.spec.selector.target.toFirstUpper».insertMany(sDoc.«op.spec.selector.target»);
      sDoc.«op.spec.name» = ids;
      sDoc.«op.spec.selector.target» = null;
      «dbName».«op.spec.selector.ref».save(sDoc);
    «ENDIF»
});
  '''

  private def generateCastSpec(AttributeOrReferenceCastSpec spec, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter: {}, update: [{$set: { «FOR t : spec.selector.targets SEPARATOR ", "»"«t»": { $convert: { input: "$«t»", to: «tConverter.typeToNumericBSONType(spec.type.typename)» }} «ENDFOR» }}]}}
    «ELSE»
      .updateMany({}, [{$set: { «FOR t : spec.selector.targets SEPARATOR ", "»"«t»" : { $convert: { input: "$«t»", to: «tConverter.typeToNumericBSONType(spec.type.typename)» }}«ENDFOR» }}])
    «ENDIF»
  '''

  private def generateMultiplicitySpec(ReferenceOrAggregateMultiplicitySpec spec, boolean inBulk)
  '''
    «IF inBulk»
      «"  "»{updateMany: {filter: {}, update: [{$set: { «FOR t : spec.selector.targets SEPARATOR ", "»"«t»": «IF aHandler.isMultiplicityToMany(spec.multiplicity)»[ "$«t»" ]«ELSE»{ $arrayElemAt: [ "$«t»", 0] }«ENDIF»«ENDFOR» }}]}}
    «ELSE»
      .updateMany({}, [{$set: { «FOR t : spec.selector.targets SEPARATOR ", "»"«t»": «IF aHandler.isMultiplicityToMany(spec.multiplicity)»[ "$«t»" ]«ELSE»{ $arrayElemAt: [ "$«t»", 0] }«ENDIF»«ENDFOR» }}])
    «ENDIF»
  '''

  //TODO: We can build Allocate as a $lookup and make use of indexes. But to do so we have to change how the pipeline is built. Future work.
  private def generateAllocateSpec(FeatureAllocateSpec spec)
  '''.find().forEach( function(sDoc) { «dbName».«spec.targetSelector.ref».updateMany({ «processCondition(spec.condition, spec.sourceSelector.ref, spec.targetSelector.ref)» }, { $set: { "«spec.targetSelector.target»": sDoc.«spec.sourceSelector.target»} }); })'''
/*
  «this.dbName».«spec.targetSelector.ref».aggregate([
    { $lookup: { from: "«spec.sourceSelector.ref»", localField: "«spec.condition.c2»", foreignField: "«spec.condition.c1»", as: "«spec.targetSelector.target»" }},
    { $addFields: { "«spec.targetSelector.target»": "$«spec.targetSelector.target».«spec.sourceSelector.target»" }},
    { $addFields: { "«spec.targetSelector.target»": { $arrayElemAt: [ "$«spec.targetSelector.target»", 0] }}},
    { $out: "«spec.targetSelector.ref»" }
  ])
 */

  private def dispatch CharSequence generateSimpleFeature(String name, SimpleAggregateTarget aggr, String defaultValue)
  '''"«name»": «IF aHandler.isMultiplicityToMany(aggr.multiplicity)»[«ENDIF»{«FOR f : aHandler.getFeaturesInAggregate(aggr.aggr).filter(SimpleFeature) SEPARATOR ", "»«generateSimpleFeature(f.name, f.type, null)»«ENDFOR»}«IF aHandler.isMultiplicityToMany(aggr.multiplicity)»]«ENDIF»'''

  private def dispatch CharSequence generateSimpleFeature(String name, DataType type, String defaultValue)
  '''«IF name.equals("_id") && type === null»«generateId()»«ELSE»"«name»": «IF type === null»null«ELSE»«generateDataType(type, defaultValue)»«ENDIF»«ENDIF»'''

  private def dispatch CharSequence generateSimpleFeature(String name, SimpleReferenceTarget ref, String defaultValue)
  '''"«name»": «IF aHandler.isMultiplicityToMany(ref.multiplicity)»[«ENDIF»«IF ref.type === null»«IF aHandler.isMultiplicityToOne(ref.multiplicity)»null«ENDIF»«ELSE»«generateDataType(ref.type, defaultValue)»«ENDIF»«IF aHandler.isMultiplicityToMany(ref.multiplicity)»]«ENDIF»'''

  // This hierarchy can be done better...
  private def CharSequence generateSimpleFeature(String name, SinglePrimitiveType type, String defaultValue, String multiplicity)
  '''"«name»": «IF aHandler.isMultiplicityToMany(multiplicity)»[«ENDIF»«IF type === null»«IF aHandler.isMultiplicityToOne(multiplicity)»null«ENDIF»«ELSE»«generateDataType(type, defaultValue)»«ENDIF»«IF aHandler.isMultiplicityToMany(multiplicity)»]«ENDIF»'''

  private def dispatch CharSequence generateDataType(Null type, String defValue)
  '''null'''

  private def dispatch CharSequence generateDataType(List type, String defValue)
  '''[«IF type.elementType !== null»«generateDataType(type.elementType, defValue)»«ENDIF»]'''

  private def dispatch CharSequence generateDataType(Set type, String defValue)
  '''[«IF type.elementType !== null»«generateDataType(type.elementType, defValue)»«ENDIF»]'''

  private def dispatch CharSequence generateDataType(Tuple type, String defValue)
  '''[«IF !type.elements.nullOrEmpty»«FOR DataType dt : type.elements»«generateDataType(dt, defValue)»«ENDFOR»«ENDIF»]'''

  private def dispatch CharSequence generateDataType(Map type, String defValue)
  '''{«IF type.keyType !== null && type.valueType !== null»«generateDataType(type.keyType, defValue)»: «generateDataType(type.valueType, defValue)»«ELSE»$literal: {}«ENDIF»}'''

  private def dispatch CharSequence generateDataType(OptionPrimitiveType type, String defValue)
  '''«generateDataType(aHandler.getMostSuitableType(type.options), defValue)»'''

  private def dispatch generateDataType(SinglePrimitiveType type, String defValue)
  {
    switch (type.typename.toLowerCase)
    {
      case "integer", case "int", case "number": "NumberInt(" + generateDefValue(Integer, defValue) + ")"
      case "float", case "double":               generateDefValue(Double, defValue)
      case "bool", case "boolean":               generateDefValue(Boolean, defValue)
      case "identifier":                         "ObjectId()"
      default:                                   generateDefValue(String, defValue)
    }
  }

  private def <T> generateDefValue(Class<T> theClass, String defValue)
  {
    try
    {
      if (defValue !== null)
      {
        switch (theClass)
        {
          case Integer: return Integer.parseInt(defValue)
          case Double:  return Double.parseDouble(defValue)
          case Boolean: return Boolean.parseBoolean(defValue)
          default:      return new String(defValue)
        }
      }
    } catch (NumberFormatException e)
    {
      return generateBaseValue(theClass)
    }
    return generateBaseValue(theClass)
  }

  private def generateId()
  '''"_id": ObjectId()'''

  private def <T> generateBaseValue(Class<T> theClass)
  {
    switch (theClass)
    {
      case Integer: "0"
      case Double:  "0.0"
      case Boolean: "false"
      default:      '""'
    }
  }

  private def processCondition(ConditionDecl cond, String sName, String tName)
  '''"«IF cond.c2.contains(tName)»«cond.c2.substring(cond.c2.indexOf(".") + 1)»«ELSE»«cond.c2»«ENDIF»": sDoc.«IF cond.c1.contains(sName)»«cond.c1.substring(cond.c1.indexOf(".") + 1)»«ELSE»«cond.c1»«ENDIF»'''

  private def dispatch generateIndex(ReferenceAddOp op) // Experimental stuff: Creating an index. If c2 is _id it is already indexed.
  '''
  «IF op.spec.condition !== null»
    «IF !op.spec.condition.c1.equals("_id")»«this.dbName».«op.spec.selector.ref».createIndex({«op.spec.condition.c1»: 1}, {name: "«this.indexName»_C1"})«ENDIF»
    «IF !op.spec.condition.c2.equals("_id")»«this.dbName».«op.spec.ref».createIndex({«op.spec.condition.c2»: 1}, {name: "«this.indexName»_C2"})«ENDIF»
  «ENDIF»
  '''

  private def dispatch dropIndex(ReferenceAddOp op)
  '''
  «IF op.spec.condition !== null»
    «IF !op.spec.condition.c1.equals("_id")»«this.dbName».«op.spec.selector.ref».dropIndex("«this.indexName»_C1")«ENDIF»
    «IF !op.spec.condition.c2.equals("_id")»«this.dbName».«op.spec.ref».dropIndex("«this.indexName»_C2")«ENDIF»
  «ENDIF»
  '''

  private def dispatch generateIndex(FeatureCopyOp op) // Experimental stuff: Creating an index. If c2 is _id it is already indexed.
  '''
  «IF !op.spec.condition.c1.equals("_id")»«this.dbName».«op.spec.sourceSelector.ref».createIndex({«op.spec.condition.c1»: 1}, {name: "«this.indexName»_C1"})«ENDIF»
  «IF !op.spec.condition.c2.equals("_id")»«this.dbName».«op.spec.targetSelector.ref».createIndex({«op.spec.condition.c2»: 1}, {name: "«this.indexName»_C2"})«ENDIF»

  '''

  private def dispatch dropIndex(FeatureCopyOp op)
  '''
  «IF !op.spec.condition.c1.equals("_id")»«this.dbName».«op.spec.sourceSelector.ref».dropIndex("«this.indexName»_C1");«ENDIF»
  «IF !op.spec.condition.c2.equals("_id")»«this.dbName».«op.spec.targetSelector.ref».dropIndex("«this.indexName»_C2");«ENDIF»
  '''

  private def dispatch generateIndex(FeatureMoveOp op) // Experimental stuff: Creating an index. If c2 is _id it is already indexed.
  '''
  «IF !op.spec.condition.c1.equals("_id")»«this.dbName».«op.spec.sourceSelector.ref».createIndex({«op.spec.condition.c1»: 1}, {name: "«this.indexName»_C1"})«ENDIF»
  «IF !op.spec.condition.c2.equals("_id")»«this.dbName».«op.spec.targetSelector.ref».createIndex({«op.spec.condition.c2»: 1}, {name: "«this.indexName»_C2"})«ENDIF»

  '''

  private def dispatch dropIndex(FeatureMoveOp op)
  '''
  «IF !op.spec.condition.c1.equals("_id")»«this.dbName».«op.spec.sourceSelector.ref».dropIndex("«this.indexName»_C1");«ENDIF»
  «IF !op.spec.condition.c2.equals("_id")»«this.dbName».«op.spec.targetSelector.ref».dropIndex("«this.indexName»_C2");«ENDIF»
  '''

  private def dispatch generateIndex(BasicOperation op) ''''''
  private def dispatch dropIndex(BasicOperation op) ''''''

}
