package es.um.uschema.xtext.orion.m2t

import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.utils.OrionUtils
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.orion.orion.EntityMergeOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.validation.m2t.CassandraValidator
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.athena.utils.AthenaFactory
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp
import es.um.uschema.xtext.athena.athena.AthenaSchema
import java.util.ArrayList
import org.eclipse.xtext.EcoreUtil2
import es.um.uschema.xtext.orion.utils.costs.CassandraModelCost
import es.um.uschema.xtext.orion.utils.updater.AthenaSchemaUpdater
import es.um.uschema.xtext.orion.orion.FeatureAllocateSpec
import es.um.uschema.xtext.orion.orion.AttributeOrReferenceCastSpec
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.athena.athena.OptionPrimitiveType
import es.um.uschema.xtext.athena.utils.TypeConverter
import es.um.uschema.xtext.orion.orion.RelationshipOp
import es.um.uschema.xtext.orion.utils.io.OrionIO

class Orion2Cassandra
{
  AthenaSchemaUpdater schemaUpdater
  AthenaHandler aHandler
  TypeConverter tConverter
  CassandraValidator validator
  CassandraModelCost modelCost
  OrionIO orionIO
  java.util.List<String> scripts
  java.util.List<AthenaSchema> schemas

  new()
  {
    this.schemaUpdater = null
    this.aHandler = new AthenaHandler()
    this.tConverter = new TypeConverter()
    this.validator = new CassandraValidator()
    this.modelCost = new CassandraModelCost()
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
        result.append(generateUseKeyspace(schema.id.name))
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

  //TODO: What if the entity is not root? and therefore is a user-defined type? Then copying out a table does not work. Need to fix.
  def generateHeader(String dbName)
  '''
    CREATE KEYSPACE IF NOT EXISTS «dbName.toLowerCase» WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
    «generateUseKeyspace(dbName)»
  '''

  def generateUseKeyspace(String dbName)
  '''
    USE «dbName.toLowerCase» ;

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
    CREATE TABLE IF NOT EXISTS «op.spec.name.toLowerCase»
    (
      «FOR feat : op.spec.features.filter[f | f.isKey]»
        «generateSimpleFeature(feat.name, feat.type, false)»,
      «ENDFOR»
      «FOR feat : op.spec.features.filter[f | !f.isKey].sortBy[f | f.name.toLowerCase]»
        «generateSimpleFeature(feat.name, feat.type, false)»,
      «ENDFOR»
      PRIMARY KEY («op.spec.features.filter[f | f.isKey].map[f | f.name.toLowerCase].join(", ")»)
    );
    «IF !op.spec.features.isEmpty && op.spec.features.exists[f | f.defaultValue !== null]»
    INSERT INTO «op.spec.name.toLowerCase» («op.spec.features.filter[f | f.defaultValue !== null].map[f | f.name.toLowerCase].join(", ")») VALUES («op.spec.features.filter[f | f.defaultValue !== null].map[f | f.defaultValue.replace("\"", "'")].join(", ")»);
    «ENDIF»
  '''

  private def dispatch generateBasicOp(EntityDeleteOp op)
  '''
    DROP TABLE IF EXISTS «op.spec.ref.toLowerCase»;
  '''

  private def dispatch generateBasicOp(EntityRenameOp op)
  '''
    COPY «op.spec.ref.toLowerCase» TO 'tmp.csv' WITH HEADER = TRUE;
    DROP TABLE «op.spec.ref.toLowerCase»;
    CREATE TABLE «op.spec.name.toLowerCase»
    (
      «generateTableContent(aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature))»
      PRIMARY KEY («aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name.toLowerCase].join(", ")»)
    );
    COPY «op.spec.name.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
  '''

  private def dispatch generateBasicOp(EntitySplitOp op)
  '''
    COPY «op.spec.ref.toLowerCase» ( «FOR f : op.spec.features1.features SEPARATOR ", "»«f»«ENDFOR» ) TO 'tmp.csv' WITH HEADER = TRUE;
    CREATE TABLE «op.spec.name1.toLowerCase»
    (
      «generateTableContent(op.spec.features1.features.map[f | aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref), f)])»
      PRIMARY KEY («aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature).filter[f | f.isKey && op.spec.features1.features.contains(f.name)].map[f | f.name.toLowerCase].join(", ")»)
    );
    COPY «op.spec.name1.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
    COPY «op.spec.ref.toLowerCase» ( «FOR f : op.spec.features2.features SEPARATOR ", "»«f»«ENDFOR» )  TO 'tmp.csv' WITH HEADER = TRUE;
    CREATE TABLE «op.spec.name2.toLowerCase»
    (
      «generateTableContent(op.spec.features2.features.map[f | aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref), f)])»
      PRIMARY KEY («aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature).filter[f | f.isKey && op.spec.features2.features.contains(f.name)].map[f | f.name.toLowerCase].join(", ")»)
    );
    COPY «op.spec.name2.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
    DROP TABLE «op.spec.ref.toLowerCase»;
  '''

  private def dispatch generateBasicOp(EntityExtractOp op)
  '''
    COPY «op.spec.ref.toLowerCase» ( «FOR feat : op.spec.features.features SEPARATOR ", "»«feat»«ENDFOR» ) TO 'tmp.csv' WITH HEADER = TRUE;
    CREATE TABLE «op.spec.name.toLowerCase»
    (
      «generateTableContent(op.spec.features.features.map[f | aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref), f)])»
      PRIMARY KEY («aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref)).filter(SimpleFeature).filter[f | f.isKey && op.spec.features.features.contains(f.name)].map[f | f.name.toLowerCase].join(", ")»)
    );
    COPY «op.spec.name.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
  '''

  private def dispatch generateBasicOp(EntityMergeOp op)
  '''
    CREATE TABLE «op.spec.name.toLowerCase»
    (
      «val lFeatures = aHandler.getReducedSimpleFeaturesIn(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref1), aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref2))»
      «generateTableContent(lFeatures)»
      PRIMARY KEY («lFeatures.filter[f | f.isKey].map[f | f.name].join(", ")»)
    );
    COPY «op.spec.ref2.toLowerCase» TO 'tmp.csv' WITH HEADER = TRUE;
    COPY «op.spec.name.toLowerCase» ( «FOR feat : aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref2)).filter(SimpleFeature) SEPARATOR ", "»«feat.name.toLowerCase»«ENDFOR» ) FROM 'tmp.csv' WITH HEADER = TRUE;
    COPY «op.spec.ref1.toLowerCase» TO 'tmp.csv' WITH HEADER = TRUE;
    COPY «op.spec.name.toLowerCase» ( «FOR feat : aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.ref1)).filter(SimpleFeature) SEPARATOR ", "»«feat.name.toLowerCase»«ENDFOR» ) FROM 'tmp.csv' WITH HEADER = TRUE;
    DROP TABLE «op.spec.ref2.toLowerCase»;
    DROP TABLE «op.spec.ref1.toLowerCase»;
  '''

  private def dispatch generateBasicOp(EntityDelVarOp op)
  '''--- Operation not supported.'''

  private def dispatch generateBasicOp(EntityAdaptOp op)
  '''--- Operation not supported.'''

  private def dispatch generateBasicOp(EntityUnionOp op)
  '''-- Operation not supported.'''

  private def dispatch generateBasicOp(RelationshipOp op)
  '''-- Operation not supported.'''

  private def dispatch generateBasicOp(FeatureDeleteOp op)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector).filter[e | op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(e, t) !== null]]»
      ALTER TABLE «e.name.toLowerCase» DROP ( «FOR t : op.spec.selector.targets.reject[t | aHandler.getSimpleFeatureInSchemaType(e, t) === null] SEPARATOR ", "»«t»«ENDFOR» );
    «ENDFOR»
  '''

// este método esta mal en el forAll
  private def dispatch generateBasicOp(FeatureRenameOp op)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector).filter[e | aHandler.getSimpleFeatureInSchemaType(e, op.spec.selector.target) !== null]»
      «val featToRename = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref), op.spec.selector.target)»
      «IF featToRename.key»
        ALTER TABLE «e.name» RENAME «op.spec.selector.target.toLowerCase» TO «op.spec.name.toLowerCase»
      «ELSE»
        COPY «op.spec.selector.ref.toLowerCase» ( «aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name.toLowerCase].join(", ")», «op.spec.selector.target.toLowerCase» ) TO 'tmp.csv' WITH HEADER = TRUE;
        ALTER TABLE «e.name.toLowerCase» DROP ( «op.spec.selector.target.toLowerCase» );
        ALTER TABLE «e.name.toLowerCase» ADD «generateSimpleFeature(op.spec.name, featToRename.type, false)»;
        COPY «op.spec.selector.ref.toLowerCase» ( «aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name.toLowerCase].join(", ")», «op.spec.name.toLowerCase» ) FROM 'tmp.csv' WITH HEADER = TRUE;
      «ENDIF»
    «ENDFOR»
  '''

  private def dispatch generateBasicOp(FeatureCopyOp op)
  '''
    «generateAllocate(op.spec)»
  '''

  private def dispatch generateBasicOp(FeatureMoveOp op)
  '''
    «generateAllocate(op.spec)»
    ALTER TABLE «op.spec.sourceSelector.ref.toLowerCase» DROP ( «op.spec.sourceSelector.target.toLowerCase» );
  '''

  private def dispatch generateBasicOp(FeatureNestOp op)
  '''--- Operation not supported.'''
/*
  '''
    CREATE TYPE IF NOT EXISTS «op.spec.name.toLowerCase»
    (
      «FOR featToNest : op.spec.selector.targets SEPARATOR ", "»
        «val featureToGenerate = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref), featToNest)»
        «generateSimpleFeature(featToNest, featureToGenerate.type, true)»
      «ENDFOR»
    );
    ALTER TABLE «op.spec.selector.ref» ADD «op.spec.name» «op.spec.name.toLowerCase»;
    ALTER TABLE «op.spec.selector.ref» DROP ( «op.spec.selector.targets.join(", ")» );
  '''
*/
  private def dispatch generateBasicOp(FeatureUnnestOp op)
  '''--- Operation not supported.'''
/*
  '''
    ALTER TABLE «op.spec.selector.ref» ADD
    (
      «FOR featToUnnest : op.spec.selector.targets SEPARATOR ", "»
        «val featName = featToUnnest.substring(featToUnnest.indexOf(".") + 1)»
        «val featureToGenerate = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, featToUnnest.substring(0, featToUnnest.indexOf(".")).toLowerCase), featName)»
        «generateSimpleFeature(featName, featureToGenerate.type, false)»
      «ENDFOR»
    );
  '''
*/

  private def dispatch generateBasicOp(AttributeAddOp op)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)»
      ALTER «IF op.spec.selector.target.contains(".")»TYPE «op.spec.selector.target.substring(0, op.spec.selector.target.indexOf(".")).toLowerCase» ADD «generateSimpleFeature(op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") + 1), op.spec.type, true)»«ELSE»TABLE «e.name.toLowerCase» ADD «generateSimpleFeature(op.spec.selector.target, op.spec.type, false)»«ENDIF»;
    «ENDFOR»
  '''

  private def dispatch generateBasicOp(AttributeCastOp op)
  '''
    «generateCastSpec(op.spec)»
  '''

  private def dispatch generateBasicOp(AttributePromoteOp op)
  '''
    COPY «op.spec.selector.ref.toLowerCase»
    (
      «FOR f : (aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name] + op.spec.selector.targets)»«f.toLowerCase»,«ENDFOR»
      «FOR f : aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | !f.isKey && !op.spec.selector.targets.contains(f.name)].map[f | f.name.toLowerCase].sort SEPARATOR ','»«f»«ENDFOR»
    ) TO 'tmp.csv' WITH HEADER = TRUE;
    DROP TABLE «op.spec.selector.ref.toLowerCase»;
    CREATE TABLE «op.spec.selector.ref.toLowerCase»
    (
      «generateTableContent(aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature))»
      PRIMARY KEY («(aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name] + op.spec.selector.targets).map[f | f.toLowerCase].join(", ")»)
    );
    COPY «op.spec.selector.ref.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
  '''
  private def dispatch generateBasicOp(AttributeDemoteOp op)
  '''
    COPY «op.spec.selector.ref.toLowerCase»
    (
      «FOR f : (aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name].filter[f | !op.spec.selector.targets.contains(f)])»«f.toLowerCase»,«ENDFOR»
      «FOR f : (aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | !f.isKey && !op.spec.selector.targets.contains(f.name)].map[f | f.name]  + op.spec.selector.targets).sortBy[f | f.toLowerCase] SEPARATOR ','»«f.toLowerCase»«ENDFOR»
    ) TO 'tmp.csv' WITH HEADER = TRUE;
    DROP TABLE «op.spec.selector.ref.toLowerCase»;
    CREATE TABLE «op.spec.selector.ref.toLowerCase»
    (
      «generateTableContent(aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature))»
      PRIMARY KEY («(aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name].reject[name | op.spec.selector.targets.contains(name)].map[f | f.toLowerCase]).join(", ")»)
    );
    COPY «op.spec.selector.ref.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
  '''

  private def dispatch generateBasicOp(ReferenceAddOp op)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)»
      ALTER «IF op.spec.selector.target.contains(".")»TYPE «op.spec.selector.target.substring(0, op.spec.selector.target.indexOf(".")).toLowerCase» ADD «op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") +1).toLowerCase» «ELSE»TABLE «e.name.toLowerCase» ADD «op.spec.selector.target.toLowerCase» «ENDIF»«IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»list<«ENDIF»«generateDataType(op.spec.type)»«IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»>«ENDIF»;
      «IF op.spec.condition !== null»
        COPY «op.spec.ref.toLowerCase» ( «processCondition(op.spec.condition.c2, aHandler.getReducedFeaturesInSchemaTypeAndVariations(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name].head)» ) TO 'tmp.csv' WITH HEADER = TRUE;
        COPY «op.spec.selector.ref.toLowerCase» ( «processCondition(op.spec.condition.c1, op.spec.selector.target)» ) TO 'tmp.csv' WITH HEADER = TRUE;
      «ENDIF»
    «ENDFOR»
  '''

  private def dispatch generateBasicOp(ReferenceCastOp op)
  '''
    «generateCastSpec(op.spec)»
  '''

  private def dispatch generateBasicOp(ReferenceMultiplicityOp op)
  '''--- Operation not supported.'''
  //'''«generateMultiplicitySpec(op.spec)»'''

  private def dispatch generateBasicOp(ReferenceMorphOp op)
  '''--- Operation not supported.'''
/*
  '''
    «val theReference = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref), op.spec.selector.target).type as SimpleReferenceTarget»
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector).filter[e | aHandler.getSimpleFeatureInSchemaType(e, op.spec.selector.target) !== null]»
      CREATE TYPE IF NOT EXISTS «op.spec.selector.target.toLowerCase»
      (
        «generateTypeContent(aHandler.getReducedFeaturesInSchemaTypeAndVariations(theReference.ref).filter(SimpleFeature))»
      );
      ALTER TABLE «e.name» ADD «op.spec.name» «IF aHandler.isMultiplicityToMany(theReference.multiplicity)»list<frozen<«ENDIF»«op.spec.selector.target.toLowerCase»«IF aHandler.isMultiplicityToMany(theReference.multiplicity)»>>«ENDIF»;
    «ENDFOR»
    «IF op.spec.deleteEntity»
      DROP TABLE IF EXISTS «theReference.ref.name»;
    «ENDIF»
  '''
*/

  private def dispatch generateBasicOp(AggregateAddOp op)
  '''
    «IF op.spec.selector.target.contains(".")»
      CREATE TYPE IF NOT EXISTS «op.spec.name !== null ? op.spec.name.toLowerCase : op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") + 1).toLowerCase»
      (
        «FOR feat : op.spec.features.sortBy[f | f.name.toLowerCase] SEPARATOR ", "»
          «generateSimpleFeature(feat.name, feat.type, true)»
        «ENDFOR»
      );
      ALTER TYPE «op.spec.selector.target.substring(0, op.spec.selector.target.indexOf(".")).toLowerCase» ADD «op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") + 1).toLowerCase» frozen<«IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»list<«ENDIF»«op.spec.name !== null ? op.spec.name.toLowerCase : op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") + 1).toLowerCase»«IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»>«ENDIF»>;
    «ELSE»
      CREATE TYPE IF NOT EXISTS «op.spec.name !== null ? op.spec.name.toLowerCase : op.spec.selector.target.toLowerCase»
      (
        «FOR feat : op.spec.features.sortBy[f | f.name.toLowerCase] SEPARATOR ", "»
          «generateSimpleFeature(feat.name, feat.type, true)»
        «ENDFOR»
      );
      «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)»
        ALTER TABLE «e.name.toLowerCase» ADD «op.spec.selector.target.toLowerCase» «IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»list<frozen<«ENDIF»«op.spec.name !== null ? op.spec.name.toLowerCase : op.spec.selector.target.toLowerCase»«IF aHandler.isMultiplicityToMany(op.spec.multiplicity)»>>«ENDIF»;
      «ENDFOR»
    «ENDIF»
  '''

  private def dispatch generateBasicOp(AggregateMultiplicityOp op)
  '''--- Operation not supported.'''
  //'''«generateMultiplicitySpec(op.spec)»'''

  private def dispatch generateBasicOp(AggregateMorphOp op)
  '''--- Operation not supported.'''
/*
  '''
    «val theAggregate = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref), op.spec.selector.target).type as SimpleAggregateTarget»
    «val feats = aHandler.getFeaturesInAggregate(theAggregate.aggr).filter(SimpleFeature)»
    CREATE TABLE IF NOT EXISTS «op.spec.selector.target.toLowerCase»
    (
      «IF (!feats.exists[f | f.key])»id uuid,«ENDIF»
      «generateTableContent(feats)»
      PRIMARY KEY («IF feats.exists[f | f.key]»«feats.filter[f | f.key].map[f | f.name].join(", ")»«ELSE»id«ENDIF»)
    );
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)»
      ALTER TABLE «e.name» ADD «op.spec.name» «IF aHandler.isMultiplicityToMany(theAggregate.multiplicity)»list<«ENDIF»«IF feats.exists[f | f.key]»«generateDataType(feats.findFirst[f | f.key].type as DataType)»«ELSE»uuid«ENDIF»«IF aHandler.isMultiplicityToMany(theAggregate.multiplicity)»>«ENDIF»;
    «ENDFOR»
  '''
*/

  private def generateAllocate(FeatureAllocateSpec spec)
  '''
    «val featToCopy = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, spec.sourceSelector.ref), spec.sourceSelector.target)»
    COPY «spec.sourceSelector.ref.toLowerCase» ( «processCondition(spec.condition.c1, spec.sourceSelector.target)» ) TO 'tmp.csv' WITH HEADER = TRUE;
    ALTER TABLE «spec.targetSelector.ref.toLowerCase» ADD «generateSimpleFeature(spec.targetSelector.target, featToCopy.type, false)»;
    COPY «spec.targetSelector.ref.toLowerCase» ( «processCondition(spec.condition.c2, spec.targetSelector.target)» ) FROM 'tmp.csv' WITH HEADER = TRUE;
  '''

  private def generateCastSpec(AttributeOrReferenceCastSpec spec)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, spec.selector).filter[e | spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(e, t) !== null]]»
      COPY «e.name.toLowerCase» TO 'tmp.csv' WITH HEADER = TRUE;
      DROP TABLE «e.name.toLowerCase»;
      CREATE TABLE «e.name.toLowerCase»
      (
        «generateUpdatedTable(e as EntityDecl, spec)»
      );
      COPY «e.name.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
    «ENDFOR»
  '''

/*
  private def generateMultiplicitySpec(ReferenceOrAggregateMultiplicitySpec spec)
  '''
    «FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, spec.selector).filter[e | spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(e, t) !== null]]»
      COPY «e.name.toLowerCase» TO 'tmp.csv' WITH HEADER = TRUE;
      DROP TABLE «e.name.toLowerCase»;
      CREATE TABLE «e.name.toLowerCase»
      (
        «generateUpdatedTable(e as EntityDecl, spec)»
      );
      COPY «e.name.toLowerCase» FROM 'tmp.csv' WITH HEADER = TRUE;
    «ENDFOR»
  '''
*/

  private def generateUpdatedTable(EntityDecl entity, AttributeOrReferenceCastSpec spec)
  '''
    «generateTableContent(aHandler.getReducedFeaturesInSchemaTypeAndVariations(entity).filter(SimpleFeature).reject[f | spec.selector.targets.exists[t | t.equals(f.name)]])»
    «FOR t : spec.selector.targets»
      «generateSimpleFeature(t, spec.type, false)»,
    «ENDFOR»
    PRIMARY KEY («aHandler.getReducedFeaturesInSchemaTypeAndVariations(entity).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name.toLowerCase].join(", ")»)
  '''

/*
  private def generateUpdatedTable(EntityDecl entity, ReferenceOrAggregateMultiplicitySpec spec)
  '''
    «val features = spec.selector.targets.map[t | aHandler.getSimpleFeatureInSchemaType(entity, t)]»
    «generateTableContent(aHandler.getReducedFeaturesInSchemaTypeAndVariations(entity).filter(SimpleFeature).reject[f | spec.selector.targets.exists[t | t.equals(f.name)]])»
    «FOR f : features SEPARATOR ", "»
      «f.name.toLowerCase» «IF aHandler.isMultiplicityToMany(spec.multiplicity)»list<«IF f.type instanceof SimpleAggregateTarget»frozen<«((f.type as SimpleAggregateTarget).aggr.head instanceof EntityDecl ? (f.type as SimpleAggregateTarget).aggr.head as EntityDecl : (f.type as SimpleAggregateTarget).aggr.head.eContainer as EntityDecl).name.toLowerCase»>«ELSE»«IF f.type instanceof SimpleReferenceTarget»«generateDataType((f.type as SimpleReferenceTarget).type)»«ELSE»«generateDataType(f.type as DataType)»«ENDIF»«ENDIF»>«ELSE»«IF f.type instanceof SimpleAggregateTarget»«((f.type as SimpleAggregateTarget).aggr.head instanceof EntityDecl ? (f.type as SimpleAggregateTarget).aggr.head as EntityDecl : (f.type as SimpleAggregateTarget).aggr.head.eContainer as EntityDecl).name.toLowerCase»«ELSE»«IF f.type instanceof SimpleReferenceTarget»«generateDataType((f.type as SimpleReferenceTarget).type)»«ELSE»«generateDataType(getInnerDataType(f.type as DataType))»«ENDIF»«ENDIF»«ENDIF»,
    «ENDFOR»
    PRIMARY KEY («aHandler.getReducedFeaturesInSchemaTypeAndVariations(entity).filter(SimpleFeature).filter[f | f.isKey].map[f | f.name.toLowerCase].join(", ")»)
  '''
*/

  private def generateTableContent(Iterable<SimpleFeature> features)
  '''«generateInnerContent(features, false)»'''

/*
  private def generateTypeContent(Iterable<SimpleFeature> features)
  '''«generateInnerContent(features, true)»'''
*/

  private def generateInnerContent(Iterable<SimpleFeature> features, boolean freeze)
  '''
    «FOR simpleFeat : features.filter[f | f.isKey]»
      «generateSimpleFeature(simpleFeat.name, simpleFeat.type, freeze)»,
    «ENDFOR»
    «FOR simpleFeat : features.filter[f | !f.isKey].sortBy[f | f.name.toLowerCase]»
      «generateSimpleFeature(simpleFeat.name, simpleFeat.type, freeze)»,
    «ENDFOR»
  '''

  private def dispatch generateSimpleFeature(String name, DataType type, boolean freeze)
  '''«name.toLowerCase» «IF freeze && !(type instanceof SinglePrimitiveType)»frozen<«ENDIF»«generateDataType(type)»«IF freeze && !(type instanceof SinglePrimitiveType)»>«ENDIF»'''

  private def dispatch generateSimpleFeature(String name, SimpleAggregateTarget aggr, boolean freeze)
  '''«name.toLowerCase» «IF freeze»frozen<«ENDIF»«IF aHandler.isMultiplicityToMany(aggr.multiplicity)»list<frozen<«ENDIF»«aHandler.getSimpleAggregateTargetName(aggr).toLowerCase»«IF aHandler.isMultiplicityToMany(aggr.multiplicity)»>>«ENDIF»«IF freeze»>«ENDIF»'''

  private def dispatch generateSimpleFeature(String name, SimpleReferenceTarget ref, boolean freeze)
  '''«name.toLowerCase» «IF freeze»frozen<«ENDIF»«IF aHandler.isMultiplicityToMany(ref.multiplicity)»list<«ENDIF»«generateDataType(ref.type)»«IF aHandler.isMultiplicityToMany(ref.multiplicity)»>«ENDIF»«IF freeze»>«ENDIF»'''

  private def dispatch CharSequence generateDataType(List type)
  '''list<«IF !(type.elementType instanceof SinglePrimitiveType)»frozen<«ENDIF»«generateDataType(type.elementType)»«IF !(type.elementType instanceof SinglePrimitiveType)»>«ENDIF»>'''

  private def dispatch CharSequence generateDataType(Set type)
  '''set<«IF !(type.elementType instanceof SinglePrimitiveType)»frozen<«ENDIF»«generateDataType(type.elementType)»«IF !(type.elementType instanceof SinglePrimitiveType)»>«ENDIF»>'''

  private def dispatch CharSequence generateDataType(Map type)
  '''map<«generateDataType(type.keyType)», «IF !(type.valueType instanceof SinglePrimitiveType)»frozen<«ENDIF»«generateDataType(type.valueType)»«IF !(type.valueType instanceof SinglePrimitiveType)»>«ENDIF»>'''

  private def dispatch CharSequence generateDataType(Tuple type)
  '''tuple<«FOR DataType dt : type.elements SEPARATOR ","»«IF !(dt instanceof SinglePrimitiveType)»frozen<«ENDIF»«generateDataType(dt)»«IF !(dt instanceof SinglePrimitiveType)»>«ENDIF»«ENDFOR»>'''

  private def dispatch CharSequence generateDataType(OptionPrimitiveType type)
  '''«generateDataType(aHandler.getMostSuitableType(type.options))»'''

  private def dispatch generateDataType(SinglePrimitiveType type)
  '''«tConverter.typeToCassandraType(type.typename)»'''

  private def processCondition(String cond, String name)
  '''«IF cond.contains(name)»«cond.substring(cond.indexOf(".") + 1).toLowerCase»«ELSE»«cond.toLowerCase»«ENDIF», «name.toLowerCase»'''

/*
  private def DataType getInnerDataType(DataType dType)
  {
    if (dType instanceof List)
      return (dType as List).getElementType();
    if (dType instanceof Set)
      return (dType as Set).getElementType();
    if (dType instanceof Tuple)
      return (dType as Tuple).getElements().get(0);
    if (dType instanceof SinglePrimitiveType || dType instanceof Null)
      return dType;

    throw new IllegalArgumentException("Cannot get inner data type of a PMap");
  }
*/
}
