package es.um.uschema.xtext.orion.m2t

import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.orion.utils.updater.AthenaSchemaUpdater
import es.um.uschema.xtext.athena.utils.AthenaHandler
import java.util.ArrayList
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.athena.utils.AthenaFactory
import org.eclipse.xtext.EcoreUtil2
import es.um.uschema.xtext.orion.utils.costs.Neo4jModelCost
import es.um.uschema.xtext.orion.validation.m2t.Neo4jValidator
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.EntityMergeOp
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.orion.orion.RelationshipAddOp
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp
import es.um.uschema.xtext.orion.orion.RelationshipSplitOp
import es.um.uschema.xtext.orion.orion.RelationshipExtractOp
import es.um.uschema.xtext.orion.orion.RelationshipMergeOp
import es.um.uschema.xtext.orion.orion.RelationshipDelVarOp
import es.um.uschema.xtext.orion.orion.RelationshipAdaptOp
import es.um.uschema.xtext.orion.orion.RelationshipUnionOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.AggregateOp
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.orion.utils.OrionUtils
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.orion.orion.FeatureAllocateSpec
import es.um.uschema.xtext.orion.orion.ConditionDecl
import es.um.uschema.xtext.athena.athena.OptionPrimitiveType
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.Type
import java.time.Instant

class Orion2Neo4j
{
  AthenaSchemaUpdater schemaUpdater
  AthenaHandler aHandler
  Neo4jValidator validator
  Neo4jModelCost modelCost
  OrionIO orionIO
  java.util.List<String> scripts
  java.util.List<AthenaSchema> schemas

  // TODO: Provide transaction support
  new()
  {
    this.schemaUpdater = null
    this.aHandler = new AthenaHandler()
    this.validator = new Neo4jValidator()
    this.modelCost = new Neo4jModelCost()
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

    // Sequence of operations
    if (!orion.operations.empty)
    {
      result.append(generateHeader(schema.id.name))
      result.append(generateOperations(orion.operations))

      // Now we increment the schema version. Also version 0 to 1 if no schema was provided
      schema.id.version = schema.id.version + 1
      schemas.add(schemaUpdater.schema)
      scripts.add(result.toString)
    }
    // Sequence of evolution blocks
    else
    {
      for (eBlock : orion.evolBlocks)
      {
        result.append(generateHeader(schema.id.name))
        result.append(generateOperations(eBlock.operations))

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
    CREATE DATABASE «dbName» IF NOT EXISTS ;
    :USE «dbName»

  '''

  def generateOperations(java.util.List<BasicOperation> operations)
  '''
    «FOR op : operations SEPARATOR "\n"»
      « { validator.checkBasicOperation(schemaUpdater.schema, op); "" } »
      // «orionIO.serialize(op)»
      «generateBasicOp(op)»
      «schemaUpdater.processOperation(op)»
      «modelCost.addToCosts(op)»
    «ENDFOR»
  '''

  private def dispatch generateBasicOp(EntityAddOp op)
  '''
    CREATE (x: «op.spec.name»);
    «IF !op.spec.features.isNullOrEmpty»
      MATCH (x: «op.spec.name»)
      SET«FOR f : op.spec.features SEPARATOR ','» x.«generateFeature(f.name, f.type, f.defaultValue)»«ENDFOR»
      ;
    «ENDIF»
  '''

  private def dispatch generateBasicOp(EntityDeleteOp op)
  '''
    «generateEntityHeader(op.spec.ref)»
    DETACH DELETE x
    ;
  '''

  private def dispatch generateBasicOp(EntityRenameOp op) // We might also use apoc.refactor.rename.label.
  '''
    «generateEntityHeader(op.spec.ref)»
    REMOVE x: «op.spec.ref»
    SET x: «op.spec.name»
    ;
  '''

  // TODO: This does not recreate references correctly.
  // We should get a node and all relationships, but MATCH (x: TAG)-[y]->(z) does not work.
  private def dispatch generateBasicOp(EntityExtractOp op)
  '''
    «generateEntityHeader(op.spec.ref)»
    CREATE
      (x1: «op.spec.name» {«FOR feat: op.spec.features.features SEPARATOR ','» «feat»: x.«feat»«ENDFOR» })
    ;
  '''

  //TODO: Copy relationships
  private def dispatch generateBasicOp(EntitySplitOp op)
  '''
    «generateEntityHeader(op.spec.ref)»
    CREATE
      (x1: «op.spec.name1» {«FOR feat: op.spec.features1.features SEPARATOR ','» «feat»: x.«feat»«ENDFOR» }),
      (x2: «op.spec.name2» {«FOR feat: op.spec.features2.features SEPARATOR ','» «feat»: x.«feat»«ENDFOR» })
    DELETE x
    ;
  '''

  //TODO: Copy relationships
  private def dispatch generateBasicOp(EntityMergeOp op)
  '''
    MATCH (x1: «op.spec.ref1»)
    MATCH (x2: «op.spec.ref2»)
    WHERE «processCondition(op.spec.condition, "x1", op.spec.ref1, "x2", op.spec.ref2)»
    CREATE
      (x: «op.spec.name» {«FOR feat: aHandler.getReducedSimpleFeaturesIn(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref1), aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref2)) SEPARATOR ','» «feat.name»: «IF aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref1), feat.name) !== null»x1«ELSE»x2«ENDIF».«feat.name»«ENDFOR» })
    DELETE x1, x2
    ;
  '''

  //TODO: Consider relationships
  private def dispatch generateBasicOp(EntityDelVarOp op)
  '''
    «val theVariation = aHandler.getVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.target)]»
    «generateEntityHeader(op.spec.ref)»
    WHERE«FOR feat : aHandler.getFeaturesInVariation(theVariation).filter(SimpleFeature) SEPARATOR ' AND'» x.«feat.name» IS NOT NULL«ENDFOR»
         AND«FOR feat : aHandler.getFeaturesNotInVariation(theVariation) SEPARATOR ' AND'» x.«feat.name» IS NULL«ENDFOR»
    DETACH DELETE x
    ;
  '''

  //TODO: Consider relationships
  private def dispatch generateBasicOp(EntityAdaptOp op)
  '''
    «val sourceVariation = aHandler.getVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.source)]»
    «val targetVariation = aHandler.getVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.target)]»
    «val featuresToRemove = aHandler.getSimpleFeaturesDifference(aHandler.getFeaturesInVariation(sourceVariation), aHandler.getFeaturesInVariation(targetVariation))»
    «val featuresToAdd = aHandler.getSimpleFeaturesDifference(aHandler.getFeaturesInVariation(targetVariation), aHandler.getFeaturesInVariation(sourceVariation))»
    «generateEntityHeader(op.spec.ref)»
    WHERE«FOR feat: aHandler.getFeaturesInVariation(sourceVariation).filter(SimpleFeature) SEPARATOR ' AND' AFTER ' AND'» x.«feat.name» IS NOT NULL«ENDFOR»
         «FOR feat: aHandler.getFeaturesNotInVariation(sourceVariation) SEPARATOR ' AND'» x.«feat.name» IS NULL«ENDFOR»
    «IF !featuresToRemove.empty»REMOVE«FOR feat: featuresToRemove SEPARATOR ','» x.«feat.name»«ENDFOR»«ENDIF»
    «IF !featuresToAdd.empty»SET«FOR feat: featuresToAdd SEPARATOR ','» x.«generateFeature(feat.name, feat.type, null)»«ENDFOR»«ENDIF»
    ;
  '''

  //TODO: Consider relationships
  private def dispatch generateBasicOp(EntityUnionOp op)
  '''
    «generateEntityHeader(op.spec.ref)»
    SET
    «FOR feat: aHandler.getFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature) SEPARATOR ","»
      x.«feat.name» = CASE WHEN x.«feat.name» IS NULL THEN «generateDataType(feat.type as DataType, null)» ELSE x.«feat.name» END
    «ENDFOR»
    ;
  '''

  private def dispatch generateBasicOp(RelationshipAddOp op)
  ''''''

  private def dispatch generateBasicOp(RelationshipDeleteOp op)
  '''
    MATCH ()-[x: «op.spec.ref»]->()
    DELETE x
    ;
  '''

  private def dispatch generateBasicOp(RelationshipRenameOp op)
  '''
    MATCH ()-[x: «op.spec.ref»]->()
    CALL apoc.refactor.setType(x, '«op.spec.name»')
    YIELD input, output RETURN *
    ;
  '''

  private def dispatch generateBasicOp(RelationshipExtractOp op)
  '''
    MATCH (y)-[x: «op.spec.ref»]->(z)
    CREATE
      (y)-[x1: «op.spec.name» {«FOR feat: op.spec.features.features SEPARATOR ','» «feat»: x.«feat»«ENDFOR» }]->(z)
    ;
  '''

  private def dispatch generateBasicOp(RelationshipSplitOp op)
  '''
    MATCH (y)-[x: «op.spec.ref»]->(z)
    CREATE
      (y)-[x1: «op.spec.name1» {«FOR feat: op.spec.features1.features SEPARATOR ','» «feat»: x.«feat»«ENDFOR» }]->(z),
      (y)-[x2: «op.spec.name2» {«FOR feat: op.spec.features2.features SEPARATOR ','» «feat»: x.«feat»«ENDFOR» }]->(z)
    DELETE x
    ;
  '''

  private def dispatch generateBasicOp(RelationshipMergeOp op)
  '''
    MATCH (y)-[x1: «op.spec.ref1»]->(z)
    MATCH ()-[x2: «op.spec.ref2»]->()
    WHERE «processCondition(op.spec.condition, "x1", op.spec.ref1, "x2", op.spec.ref2)»
    CREATE
      (y)-[x: «op.spec.name» {«FOR feat: aHandler.getReducedSimpleFeaturesIn(aHandler.getRelationshipDecl(schemaUpdater.schema, op.spec.ref1), aHandler.getRelationshipDecl(schemaUpdater.schema, op.spec.ref2)) SEPARATOR ','» «feat.name»: «IF aHandler.getSimpleFeatureInSchemaType(aHandler.getRelationshipDecl(schemaUpdater.schema, op.spec.ref1), feat.name) !== null»x1«ELSE»x2«ENDIF».«feat.name»«ENDFOR» }]->(z)
    DELETE x1, x2
    ;
  '''

  private def dispatch generateBasicOp(RelationshipDelVarOp op)
  '''
    «val theVariation = aHandler.getVariations(aHandler.getRelationshipDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.target)]»
    «generateRelationshipHeader(op.spec.ref)»
    WHERE«FOR feat : aHandler.getFeaturesInVariation(theVariation).filter(SimpleFeature) SEPARATOR ' AND'» x.«feat.name» IS NOT NULL«ENDFOR»
         AND«FOR feat : aHandler.getFeaturesNotInVariation(theVariation) SEPARATOR ' AND'» x.«feat.name» IS NULL«ENDFOR»
    DETACH DELETE x
    ;
  '''

  private def dispatch generateBasicOp(RelationshipAdaptOp op)
  '''
    «val sourceVariation = aHandler.getVariations(aHandler.getRelationshipDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.source)]»
    «val targetVariation = aHandler.getVariations(aHandler.getRelationshipDecl(schemaUpdater.schema, op.spec.ref)).findFirst[v | v.name.equals(op.spec.target)]»
    «val featuresToRemove = aHandler.getSimpleFeaturesDifference(aHandler.getFeaturesInVariation(sourceVariation), aHandler.getFeaturesInVariation(targetVariation))»
    «val featuresToAdd = aHandler.getSimpleFeaturesDifference(aHandler.getFeaturesInVariation(targetVariation), aHandler.getFeaturesInVariation(sourceVariation))»
    «generateRelationshipHeader(op.spec.ref)»
    WHERE«FOR feat: aHandler.getFeaturesInVariation(sourceVariation).filter(SimpleFeature) SEPARATOR ' AND'» x.«feat.name» IS NOT NULL«ENDFOR»
         AND«FOR feat: aHandler.getFeaturesNotInVariation(sourceVariation) SEPARATOR ' AND'» x.«feat.name» IS NULL«ENDFOR»
    «IF !featuresToRemove.empty»REMOVE«FOR feat: featuresToRemove SEPARATOR ','» x.«feat.name»«ENDFOR»«ENDIF»
    «IF !featuresToAdd.empty»SET«FOR feat: featuresToAdd SEPARATOR ','» x.«generateFeature(feat.name, feat.type as DataType, null)»«ENDFOR»«ENDIF»
    ;
  '''

  private def dispatch generateBasicOp(RelationshipUnionOp op)
  '''
    «generateRelationshipHeader(op.spec.ref)»
    SET
    «FOR feat: aHandler.getFeaturesInSchemaTypeAndVariations(aHandler.getRelationshipDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature).filter[f | f.type instanceof DataType] SEPARATOR ","»
      x.«feat.name» = CASE WHEN x.«feat.name» IS NULL THEN «generateDataType(feat.type as DataType, null)» ELSE x.«feat.name» END
    «ENDFOR»
    ;
  '''

  private def dispatch generateBasicOp(FeatureDeleteOp op) // If it was a reference, we do not need to remove it. Instead, DELETE RELATIONSHIP should be used.
  '''
    «IF op.spec.selector.forAll || aHandler.isEntityDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateEntityHeader(op.spec.selector.ref)»
      «generateFeatureDeleteBody(op.spec.selector.targets)»
    «ENDIF»
    «IF op.spec.selector.forAll || aHandler.isRelationshipDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateRelationshipHeader(op.spec.selector.ref)»
      «generateFeatureDeleteBody(op.spec.selector.targets)»
    «ENDIF»
  '''

  private def generateFeatureDeleteBody(java.util.List<String> names)
  '''
    REMOVE«FOR t: names SEPARATOR ','» x.«t»«ENDFOR»
    ;
  '''

  private def dispatch generateBasicOp(FeatureRenameOp op) // If it was a reference, we do not need to rename it. Instead, RENAME RELATIONSHIP should be used.
  '''
    «IF op.spec.selector.forAll || aHandler.isEntityDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateEntityHeader(op.spec.selector.ref)»
      «generateFeatureRenameBody(op.spec.selector.target, op.spec.name)»
    «ENDIF»
    «IF op.spec.selector.forAll || aHandler.isRelationshipDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateRelationshipHeader(op.spec.selector.ref)»
      «generateFeatureRenameBody(op.spec.selector.target, op.spec.name)»
    «ENDIF»
  '''

  private def generateFeatureRenameBody(String oldName, String newName)
  '''
    SET x.«newName» = x.«oldName»
    REMOVE x.«oldName»
    ;
  '''

  private def dispatch generateBasicOp(FeatureCopyOp op)
  '''
    «generateAllocateSpec(op.spec)»
    ;
  '''

  private def dispatch generateBasicOp(FeatureMoveOp op)
  '''
    «generateAllocateSpec(op.spec)»
    REMOVE x1.«op.spec.sourceSelector.target»
    ;
  '''

  // Check this. It generates: MATCH (x1: Posts), ()-[x2: Rel_Comments]->()
  // It might be enough with MATCH (x1: Posts)-[x2: Rel_Comments]->()
  private def generateAllocateSpec(FeatureAllocateSpec spec)
  '''
    MATCH («IF aHandler.isEntityDecl(schemaUpdater.schema, spec.sourceSelector.ref)»x1: «spec.sourceSelector.ref»«ELSE»)-[x1: «spec.sourceSelector.ref»]->(«ENDIF»), («IF aHandler.isEntityDecl(schemaUpdater.schema, spec.targetSelector.ref)»x2: «spec.targetSelector.ref»«ELSE»)-[x2: «spec.targetSelector.ref»]->(«ENDIF»)
    WHERE «processCondition(spec.condition, "x1", spec.sourceSelector.ref, "x2", spec.targetSelector.ref)»
    SET x2.«spec.targetSelector.target» = x1.«spec.sourceSelector.target»
  '''

  private def processCondition(ConditionDecl cond, String sRef, String sName, String tRef, String tName)
  '''«sRef».«IF cond.c1.contains(sName)»«cond.c1.substring(cond.c1.indexOf(".") + 1)»«ELSE»«cond.c1»«ENDIF» = «tRef».«IF cond.c2.contains(tName)»«cond.c2.substring(cond.c2.indexOf(".") + 1)»«ELSE»«cond.c2»«ENDIF»'''

  private def dispatch generateBasicOp(FeatureNestOp op)
  '''// Operation not supported.'''

  private def dispatch generateBasicOp(FeatureUnnestOp op)
  '''// Operation not supported.'''

  private def dispatch generateBasicOp(AttributeAddOp op)
  '''
    «IF op.spec.selector.forAll || aHandler.isEntityDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateEntityHeader(op.spec.selector.ref)»
      «generateAttributeAddBody(op.spec.selector.target, op.spec.type, op.spec.defaultValue)»
      «IF op.spec.unique»
        «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector).filter[sch | sch instanceof EntityDecl]»
          CREATE CONSTRAINT «e.name»_«op.spec.selector.target»_IS_UNIQUE IF NOT EXISTS
          ON (x: «e.name»)
          ASSERT x.«op.spec.selector.target» IS UNIQUE
          ;
        «ENDFOR»
      «ENDIF»
    «ENDIF»
    «IF op.spec.selector.forAll || aHandler.isRelationshipDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateRelationshipHeader(op.spec.selector.ref)»
      «generateAttributeAddBody(op.spec.selector.target, op.spec.type, op.spec.defaultValue)»
    «ENDIF»
  '''

  private def generateAttributeAddBody(String name, DataType type, String defaultValue)
  '''
    SET x.«generateFeature(name, type, defaultValue)»
    ;
  '''

  private def dispatch generateBasicOp(AttributeCastOp op)
  '''
    «IF op.spec.selector.forAll || aHandler.isEntityDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateEntityHeader(op.spec.selector.ref)»
      «generateAttributeCastBody(op.spec.selector.targets, op.spec.type)»
    «ENDIF»
    «IF op.spec.selector.forAll || aHandler.isRelationshipDecl(schemaUpdater.schema, op.spec.selector.ref)»
      «generateRelationshipHeader(op.spec.selector.ref)»
      «generateAttributeCastBody(op.spec.selector.targets, op.spec.type)»
    «ENDIF»
  '''

  private def generateAttributeCastBody(java.util.List<String> names, SinglePrimitiveType type)
  '''
    SET«FOR t: names SEPARATOR ','» x.«t» = «generateCastFunction(type)»(x.«t»)«ENDFOR»
    ;
  '''

  private def dispatch generateBasicOp(AttributePromoteOp op)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector).filter[sch | sch instanceof EntityDecl]»
      «FOR featName : op.spec.selector.targets»
        CREATE CONSTRAINT «e.name»_«featName»_IS_UNIQUE IF NOT EXISTS
        ON (x: «e.name»)
        ASSERT x.«featName» IS UNIQUE
        ;
      «ENDFOR»
    «ENDFOR»
  '''

  private def dispatch generateBasicOp(AttributeDemoteOp op)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector).filter[sch | sch instanceof EntityDecl]»
      «FOR featName : op.spec.selector.targets»
        DROP CONSTRAINT «e.name»_«featName»_IS_UNIQUE IF EXISTS
        ;
      «ENDFOR»
    «ENDFOR»
  '''

  private def dispatch generateBasicOp(ReferenceAddOp op)
  '''
    «val featsFeaturedBy = aHandler.getFeaturesInReference(schemaUpdater.schema, op.spec.featuredBy, op.spec.variations)»
    «val featsInReference = op.spec.features»
    MATCH (x: «op.spec.selector.ref»), (y: «op.spec.ref»)
    «IF op.spec.condition !== null»WHERE «processCondition(op.spec.condition, "y", op.spec.ref, "x", op.spec.selector.ref)»«ENDIF»
    «IF aHandler.isMultiplicityToOne(op.spec.multiplicity)»WITH x, head(collect(y)) as y«ENDIF»
    CREATE
      (x)-[:«op.spec.selector.target»«IF !featsInReference.empty» {«FOR feat : featsInReference SEPARATOR ','» «feat.name»: «generateDataType(feat.type, feat.defaultValue)»«ENDFOR» }«ENDIF»«IF !featsFeaturedBy.empty» {«FOR feat : featsFeaturedBy SEPARATOR ','» «feat.name»: «generateDataType(feat.type as DataType, null)»«ENDFOR» }«ENDIF»]->(y)
    ;
  '''

  private def dispatch generateBasicOp(ReferenceCastOp op)
  '''// Operation not supported.'''

  private def dispatch generateBasicOp(ReferenceMultiplicityOp op)
  '''// Operation not supported.'''

  private def dispatch generateBasicOp(ReferenceMorphOp op)
  '''// Operation not supported.'''

  private def dispatch generateBasicOp(AggregateOp op)
  '''// Operation not supported.'''

  private def dispatch generateFeature(String name, Type type, String defaultValue)
  ''''''

  private def dispatch generateFeature(String name, DataType type, String defaultValue)
  '''«name» = «generateDataType(type, defaultValue)»'''

  private def dispatch CharSequence generateDataType(List type, String defValue)
  '''[«IF type.elementType !== null»«generateDataType(type.elementType, defValue)»«ENDIF»]'''

  private def dispatch CharSequence generateDataType(OptionPrimitiveType type, String defValue)
  '''«generateDataType(aHandler.getMostSuitableType(type.options), defValue)»'''

  private def dispatch generateDataType(SinglePrimitiveType type, String defValue)
  {
    switch (type.typename.toLowerCase)
    {
      case "integer", case "int", case "number": generateDefValue(Integer, defValue)
      case "float", case "double":               generateDefValue(Double, defValue)
      case "bool", case "boolean":               generateDefValue(Boolean, defValue)
      case "timestamp":                          generateDefValue(Instant, defValue) // TODO: Return "datetime()?"
      default:                                   generateDefValue(String, defValue)
    }
  }

  private def generateCastFunction(SinglePrimitiveType pType)
  {
    switch (pType.typename.toLowerCase)
    {
      case "integer", case "int", case "number": "toInteger"
      case "float", case "double":               "toFloat"
      case "bool", case "boolean":               "toBoolean"
      case "timestamp":                          "date"
      default:                                   "toString"
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

  private def generateEntityHeader(String entName)
  '''MATCH (x«entName !== null ? ": " + entName»)'''

  private def generateRelationshipHeader(String relName)
  '''MATCH ()-[x«relName !== null ? ": " + relName»]->()'''
}
