package es.um.uschema.xtext.orion.m2t

import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.athena.athena.EnumRestrictedNumber
import es.um.uschema.xtext.athena.athena.EnumRestrictedString
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.OptionPrimitiveType
import es.um.uschema.xtext.athena.athena.RangedNumber
import es.um.uschema.xtext.athena.athena.RegexpRestrictedString
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.athena.Type
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.athena.utils.AthenaFactory
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.athena.utils.TypeConverter
import es.um.uschema.xtext.orion.m2t.utils.SqlProcedureModule
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.ConditionDecl
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.RelationshipAddOp
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp
import es.um.uschema.xtext.orion.orion.SimpleDataFeature
import es.um.uschema.xtext.orion.orion.SingleFeatureSelector
import es.um.uschema.xtext.orion.utils.OrionUtils
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.orion.utils.updater.AthenaSchemaUpdater
import es.um.uschema.xtext.orion.validation.m2t.MySQLValidator
import java.util.ArrayList
import org.eclipse.xtext.EcoreUtil2

class Orion2MySQL {

	AthenaSchemaUpdater schemaUpdater
	AthenaHandler aHandler
	TypeConverter tConverter
	MySQLValidator validator
	OrionIO orionIO
	java.util.List<String> scripts
	java.util.List<AthenaSchema> schemas
	SqlProcedureModule sqlProcedure
	CharSequence argumentsInsert

	new() {
		this.schemaUpdater = null
		this.aHandler = new AthenaHandler()
		this.tConverter = new TypeConverter()
		this.validator = new MySQLValidator()
		this.orionIO = new OrionIO()
		this.scripts = new ArrayList<String>()
		this.schemas = new ArrayList<AthenaSchema>()
		this.sqlProcedure = new SqlProcedureModule()
	}

	def java.util.List<String> m2t(OrionOperations orion) {
		this.schemas.clear()
		this.scripts.clear()

		val result = new StringBuilder()
		val schema = orion.imports !== null
				? new AthenaNormalizer().m2m(orion.imports.importedNamespace)
				: // If not, we create a new brand schema but with VersionId = 0
			new AthenaFactory().createAthenaSchema(orion.name, 0)

		schemaUpdater = new AthenaSchemaUpdater(schema, orion.imports !== null)

		// Sequence of operations
		if (!orion.operations.empty) {
			result.append(generateHeader(schema.id.name))
			result.append(generateOperations(orion.operations))
			result.append(sqlProcedure.deleteProcedures)
			// Now we increment the schema version. Also version 0 to 1 if no schema was provided
			schema.id.version = schema.id.version + 1
			schemas.add(schemaUpdater.schema)
			scripts.add(result.toString)
		} // Sequence of evolution blocks
		else {
			for (eBlock : orion.evolBlocks) {
				result.append(generateUseKeyspace(schema.id.name))
				result.append(generateOperations(eBlock.operations))
				result.append(sqlProcedure.deleteProcedures)
				// Now we increment the schema version: 0 to 1 if no schema was provided
				schema.id.version = schema.id.version + 1
				schemas.add(EcoreUtil2.copy(schemaUpdater.schema))
				scripts.add(result.toString)
				result.length = 0
			}
		}
		
		print(result)
		return this.scripts
	}
	
	// Returns the list of schemas updated/generated
	def java.util.List<AthenaSchema> getSchemas() {
		return this.schemas
	}
	
	// Generates SQL header with CREATE DATABASE and USE commands
	def generateHeader(String dbName) '''
		CREATE DATABASE IF NOT EXISTS «dbName.toLowerCase»;
		
		«generateUseKeyspace(dbName)»
	'''

	def generateUseKeyspace(String dbName) '''
		USE «dbName.toLowerCase»;
		
	'''
	
	// Generates SQL statements for a list of Orion basic operations
	def generateOperations(java.util.List<BasicOperation> operations) '''
		«FOR op : operations SEPARATOR "\n"»
			« { validator.checkBasicOperation(schemaUpdater.schema, op); "" } »
			/* «orionIO.serialize(op)» */
			«generateBasicOp(op)»
			«schemaUpdater.processOperation(op)»
		«ENDFOR»
	'''
	
	 // Dispatch function to generate SQL for any basic operation;
	private def dispatch generateBasicOp(BasicOperation op) {}
	
	// Generates SQL for adding a new entity (table)
	private def dispatch generateBasicOp(EntityAddOp op) '''
		«val simpleDataFeatures = op.spec.features.map[EcoreUtil2.copy(it)].toList»
		«val features = simpleDataFeatures.map[toSimpleFeature].toList»
		«generateEntityAddOperation(op.spec.name, features, false)»
	'''
	
	 // Generates the CREATE TABLE statement for an entity with features, keys, uniques, references, and collections
	 // The promote field indicates whether the collections associated with the parent entity are written
	private def generateEntityAddOperation(String table, java.util.List<SimpleFeature> features, boolean promote) '''
		«val keys = features.filter[f | f.isKey].toList»
		«val simpleFeatures = features.filter[f | !f.isKey 
		&& (f.type instanceof SinglePrimitiveType || f.type instanceof List || f.type instanceof OptionPrimitiveType)].toList»
		«val uniques = features.filter[f | f.isUnique].toList»
		«val collections = features.filter[f | isCollection(f.type)].toList»
		«val references = features.filter[f | (f as SimpleFeature).type instanceof SimpleReferenceTarget]
		    			.map[f | f as SimpleFeature].toList»
		CREATE TABLE IF NOT EXISTS «table.toUpperCase»
		(
			«FOR feat : (keys + simpleFeatures).sortBy[f | f.name] SEPARATOR "\n"»«generateSimpleFeature(feat.name, feat.type, keys)»,«ENDFOR»
			«FOR ref : references SEPARATOR "\n"»«FOR r : aHandler.getKeysInSchemaType(getEntityRef(ref.type)) SEPARATOR "\n"»«generateDataType(r.name, r.type as DataType, null)»,«ENDFOR»«ENDFOR»
			«FOR ref : references SEPARATOR "\n"»CONSTRAINT «ref.name»_fk FOREIGN KEY(«aHandler.getKeysInSchemaType(getEntityRef(ref.type)).map[f | f.name].join(", ")») REFERENCES «getEntityRef(ref.type).name.toUpperCase»(«aHandler.getKeysInSchemaType(getEntityRef(ref.type)).map[f | f.name].join(", ")»),«ENDFOR»
			«FOR feat : uniques SEPARATOR "\n"»CONSTRAINT «table.toLowerCase»_«feat.name»_ak UNIQUE(«feat.name»),«ENDFOR»
			CONSTRAINT «table.toLowerCase»_pk PRIMARY KEY («keys.map[f | f.name].join(", ")»)  
		);
		«IF !promote»	
			«FOR feat : collections» 
				CREATE TABLE IF NOT EXISTS «table.toUpperCase»_«feat.name.toUpperCase»
				(
					«generateSimpleFeature(table + "," + feat.name, feat.type, keys)»
				);
			«ENDFOR»
		«ENDIF»
	'''
	
	// Generates SQL to delete an entity (table), including dropping related weak entities and foreign keys
	private def dispatch generateBasicOp(EntityDeleteOp op) '''
		CALL dropWeakEntities("«op.spec.ref.toUpperCase»");
		CALL dropFKsFromTable("«op.spec.ref.toUpperCase»");
		DROP TABLE IF EXISTS «op.spec.ref.toUpperCase»;
	'''

	// Generates SQL to rename an entity and its collection tables
	private def dispatch generateBasicOp(EntityRenameOp op) '''
		«val schema = aHandler.getSchemaTypeDecl(schemaUpdater.schema, op.spec.ref)»
		«val features = aHandler.getFeaturesInSchemaType(schema).filter[f | f instanceof SimpleFeature && isCollection((f as SimpleFeature).type)]
			.map[f | f as SimpleFeature]»
		«FOR feat : features SEPARATOR "\n"»RENAME TABLE «op.spec.ref.toUpperCase + "_" + feat.name.toUpperCase» TO «op.spec.name.toUpperCase + "_" + feat.name.toUpperCase»;«ENDFOR»
		RENAME TABLE «op.spec.ref.toUpperCase» TO «op.spec.name.toUpperCase»;
	'''
	
	// Generates SQL for extracting features into a new table 
	private def dispatch generateBasicOp(EntityExtractOp op) 
	'''«generateExtractOperation(op.spec.name, op.spec.ref, op.spec.features.features)»'''
	
	// Generates SQL for extracting features into a new table and delete the old table
	private def dispatch generateBasicOp(EntitySplitOp op) 
	'''
	«generateExtractOperation(op.spec.name1, op.spec.ref, op.spec.features1.features)»
	
	«generateExtractOperation(op.spec.name2, op.spec.ref, op.spec.features2.features)»
	
	CALL dropWeakEntities("«op.spec.ref.toUpperCase»");
	CALL dropFKsFromTable("«op.spec.ref.toUpperCase»");
	DROP TABLE IF EXISTS «op.spec.ref.toUpperCase»;
	'''

	// Generates SQL to delete features (columns or tables for collections) with dropping constraints
	private def dispatch generateBasicOp(FeatureDeleteOp op) '''
		«FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)
	    .filter[e | op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(e, t) !== null]] SEPARATOR "\n"»
			«FOR t : op.spec.selector.targets.reject[t | aHandler.getSimpleFeatureInSchemaType(e, t) === null] SEPARATOR "\n"»
				«val simpleFeature = aHandler.getSimpleFeatureInSchemaType(e, t)»
				«deleteFeature(e.name, t, simpleFeature.type)»
			«ENDFOR»
		«ENDFOR»
	'''
	
	// Helper to drop feature: either column drop or drop related collection table
	private def dispatch deleteFeature(String parent, String feature,
		DataType type) '''«IF !isCollection(type)»
		CALL dropConstraintsForColumn("«parent.toUpperCase»", "«feature»");
		ALTER TABLE «parent.toUpperCase» DROP COLUMN «feature»
		«ELSE»
		DROP TABLE «parent.toUpperCase»_«feature.toUpperCase»«ENDIF»;
	'''

	private def dispatch deleteFeature(String parent, String feature,
		SimpleAggregateTarget aggr) '''DROP TABLE «parent.toUpperCase»_«feature.toUpperCase»;'''

	private def dispatch deleteFeature(String parent, String feature,
		SimpleReferenceTarget ref) '''
	CALL dropConstraintsForColumn("«parent.toUpperCase»", "«feature»");
	ALTER TABLE «parent.toUpperCase» DROP COLUMN «feature»;'''

	// Rename a feature (column or collection table)
	private def dispatch generateBasicOp(FeatureRenameOp op) '''
		«FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)
		.filter[e | aHandler.getSimpleFeatureInSchemaType(e, op.spec.selector.target) !== null]»
			«val featToRename = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, e.name), op.spec.selector.target)»
			«renameFeature(e.name, op.spec.selector.target.toLowerCase, op.spec.name.toLowerCase, featToRename.type)»
		«ENDFOR»
	'''
	
	// Similar to deleteFeature method, dispatching based on DataType
	private def dispatch renameFeature(String table, String oldColumn, String newColumn,
		DataType type) '''«createConstraint(table, oldColumn, newColumn, type)»'''
	
	// Generates the appropriate SQL command depending on whether the feature is a collection or not
	private def dispatch createConstraint(String table, String oldColumn, String newColumn,
		DataType type) '''«IF !isCollection(type)»ALTER TABLE «table.toUpperCase» RENAME COLUMN «oldColumn.toLowerCase» TO «newColumn.toLowerCase»;«ELSE»RENAME TABLE «table.toUpperCase + "_" + oldColumn.toUpperCase» TO «table.toUpperCase + "_" + newColumn.toUpperCase»;«ENDIF»'''
	
	// First drops any existing check constraints on the old column, renames the column,
	// then adds a new CHECK constraint with the new column name and allowed enum values
	private def dispatch createConstraint(String table, String oldColumn, String newColumn,
		EnumRestrictedString type) '''
		«renameCallProcedure(table, oldColumn, newColumn)»
		ALTER TABLE «table.toUpperCase» 
		  ADD CONSTRAINT «newColumn.toLowerCase»_chk 
		  CHECK («newColumn.toLowerCase» IN ('«type.enumVals.join("', '")»'));
	'''
	
	// Similar to up method
	private def dispatch createConstraint(String table, String oldColumn, String newColumn, RangedNumber type) '''
		«renameCallProcedure(table, oldColumn, newColumn)»
		ALTER TABLE «table.toUpperCase» 
		  ADD CONSTRAINT «newColumn.toLowerCase»_chk 
		  CHECK («newColumn.toLowerCase» BETWEEN «type.from» AND «type.to»);
	'''
	
	// The same, drop check, rename and create a new check
	private def dispatch createConstraint(String table, String oldColumn, String newColumn,
		RegexpRestrictedString type) '''
		«renameCallProcedure(table, oldColumn, newColumn)»
		ALTER TABLE «table.toUpperCase» 
		  ADD CONSTRAINT «newColumn.toLowerCase»_chk 
		  CHECK («newColumn.toLowerCase» REGEXP '«type.regexp»');
	'''

	private def CharSequence renameCallProcedure(String table, String oldColumn, String newColumn) '''
		CALL dropCheckConstraintsForColumn("«table.toUpperCase»", "«oldColumn»");
		ALTER TABLE «table.toUpperCase» RENAME COLUMN «oldColumn.toLowerCase» TO «newColumn.toLowerCase»;
	'''

	private def dispatch renameFeature(String table, String oldColumn, String newColumn,
		SimpleAggregateTarget aggr) '''RENAME TABLE «table.toUpperCase + "_" + oldColumn.toUpperCase» TO «table.toUpperCase + "_" + newColumn.toUpperCase»;'''

	private def dispatch renameFeature(String table, String oldColumn, String newColumn,
		SimpleReferenceTarget ref) '''ALTER TABLE «table.toUpperCase» RENAME COLUMN «oldColumn.toLowerCase» TO «newColumn.toLowerCase»;'''

	// Copy a feature to the target table
	private def dispatch generateBasicOp(FeatureCopyOp op) '''
		«generateCopyOperation(op.spec.sourceSelector, op.spec.targetSelector, op.spec.condition)»
	'''
	
	// Adds the new column in the target table with the same type as the source feature
	// Updates the target table's new column values by joining with the source table on the specified condition
	private def generateCopyOperation(SingleFeatureSelector source, SingleFeatureSelector target,
		ConditionDecl condition) '''
		«val featToCopy = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, source.ref), source.target)»
		ALTER TABLE «target.ref.toUpperCase» ADD COLUMN «generateSimpleFeature(target.target, featToCopy.type, null)»;
		
		UPDATE «target.ref.toUpperCase» tg
		JOIN «source.ref.toUpperCase» sr ON tg.«condition.c1» = sr.«condition.c2»
		SET tg.«target.target.toLowerCase» = sr.«source.target.toLowerCase»;
	'''

	// Copy and remove a feature the source table
	private def dispatch generateBasicOp(FeatureMoveOp op) '''
		«generateCopyOperation(op.spec.sourceSelector, op.spec.targetSelector, op.spec.condition)»
		
		«val featureToDelete = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, op.spec.sourceSelector.ref), op.spec.sourceSelector.target)»
		CALL dropConstraintsForColumn("«op.spec.sourceSelector.ref.toUpperCase»", "«op.spec.sourceSelector.target.toLowerCase»");
		«deleteFeature(op.spec.sourceSelector.ref.toUpperCase, op.spec.sourceSelector.target.toLowerCase, featureToDelete.type)»
	'''

	// Adds a new attribute (column or table if collection) to one or more entities:
	//  - If the type is NOT a collection, add a column
	//  - If the type IS a collection, create a new table for the collection with foreign keys as needed
	private def dispatch generateBasicOp(AttributeAddOp op) '''
		«FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)
		.filter[e | aHandler.getSimpleFeatureInSchemaType(e, op.spec.selector.target) === null]»
			«IF !isCollection(op.spec.type)»ALTER TABLE «e.name.toUpperCase» ADD COLUMN «generateSimpleFeature(op.spec.selector.target, op.spec.type, null)»;
			«ELSE»
				CREATE TABLE IF NOT EXISTS «e.name.toUpperCase»_«op.spec.selector.target.toUpperCase»
				(
					«val keys = aHandler.getFeaturesInSchemaType(aHandler.getEntityDecl(schemaUpdater.schema, e.name))
	  		.filter[f | f instanceof SimpleFeature && (f as SimpleFeature).isKey].map[f | f as SimpleFeature].toList»
					«generateSimpleFeature(e.name + "," + op.spec.selector.target, op.spec.type, keys)»
				);
			«ENDIF»
		«ENDFOR»
	'''

	// Casts (changes) the type of attributes in selected entities only if the feature exist.
	private def dispatch generateBasicOp(AttributeCastOp op) '''
		«FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)
		.filter[e | op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(e, t) !== null]]»
			«FOR target : op.spec.selector.targets»
				«val feature = aHandler.getSimpleFeatureInSchemaType(e, target)»
				«IF feature !== null»
					ALTER TABLE «e.name.toUpperCase» MODIFY COLUMN «feature.name.toLowerCase» «tConverter.typeToMySQLType(op.spec.type.typename)»;
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
	'''

	// Promotes one or more attributes to keys (primary keys):
	// (1) Create a new temporary table with updated PK (primary key)
	// (2) Copy data from old table to new table
	// (3) Update foreign keys schema and data using stored procedures
	// (4) Update PK constraints for aggregate/special types (set, tuple, map)
	// (5) Drop old table and rename new table to original name
	private def dispatch generateBasicOp(AttributePromoteOp op) '''
		«FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)»
			«val currentKeys = aHandler.getKeysInSchemaType(e).map[f | f.name].toSet»
			«val promoteKeys = op.spec.selector.targets.toSet»
			«val newKeys = currentKeys + promoteKeys»
			«IF newKeys != currentKeys»
				«val features = aHandler.getFeaturesInSchemaType(e).map[f | f as SimpleFeature].toList»
				«{features.forEach[f | if (newKeys.contains(f.name)) aHandler.setKeyOfSimpleFeatureInSchemaType(e, f.name, true)] ""}»
				«generateEntityAddOperation(op.spec.selector.ref + "_new", features, true)»
				INSERT INTO «e.name.toUpperCase + "_NEW"» SELECT * FROM «e.name.toUpperCase»;
				CALL update_fk_schema("«e.name.toUpperCase»", "«currentKeys.join("\", \"")»", "«promoteKeys.join("\", \"")»");
				CALL update_fk_data("«e.name.toUpperCase»", "«currentKeys.join("\", \"")»", "«promoteKeys.join("\", \"")»");
				   «FOR collection : features.filter[f | isCollection(f.type)].toList»
				   ALTER TABLE «e.name.toUpperCase»_«collection.name.toUpperCase» DROP PRIMARY KEY;
				   ALTER TABLE «e.name.toUpperCase»_«collection.name.toUpperCase» ADD PRIMARY KEY («generateSpecialKey(newKeys.toList, collection.type, collection.name)»);
				«ENDFOR»
				DROP TABLE «e.name.toUpperCase»;
				ALTER TABLE «e.name.toUpperCase»_NEW RENAME TO «e.name.toUpperCase»;
			«ENDIF»
				«ENDFOR»
	'''

	// Helpers to generate the special key fields used as primary keys for collections and aggregates
	private def dispatch generateSpecialKeyDataType(java.util.List<String> keys, Set type,
		String name) '''«keys.join(", ")», «name»'''

	private def dispatch generateSpecialKeyDataType(java.util.List<String> keys, Map type,
		String name) '''«keys.join(", ")», «name»_key'''

	private def dispatch generateSpecialKeyDataType(java.util.List<String> keys, Tuple type,
		String name) '''«keys.join(", ")»'''

	private def dispatch generateSpecialKey(java.util.List<String> keys, SimpleAggregateTarget type,
		String name) '''«keys.join(", ")»«IF !isOneorCeroToOne(type.multiplicity)»«name»_id«ENDIF»'''

	private def dispatch generateSpecialKey(java.util.List<String> keys, DataType type,
		String name) '''«generateSpecialKeyDataType(keys, type, name)»'''


	// - If multiplicity is "?" or "&" (zero-or-one or exactly-one), it adds foreign key columns directly in the parent table.
	// - If multiplicity is "*" or "+" (many), it adds foreign key columns in the referenced (target) table instead.
	// The method also calls helper functions to generate relationship tables if is the first reference on the m:n table,
	// for the second reference,  delete the Pk/Fk and create a new PK with the references.
	private def dispatch generateBasicOp(ReferenceAddOp op) '''
		«val parent = op.spec.selector.ref»
		«val featureName = op.spec.selector.target»
		«val targetEntity = op.spec.ref»
		«val multiplicity = op.spec.multiplicity»
		«val parentEntity = aHandler.getSchemaTypeDecl(schemaUpdater.schema, parent)»
		«val referencedEntity = aHandler.getEntityDecl(schemaUpdater.schema, targetEntity)»
		«val referencedKeys = aHandler.getKeysInSchemaType(referencedEntity)»
		«val relationship = aHandler.getRelationshipDecl(schemaUpdater.schema, parent)»
		«IF relationship !== null && aHandler.getFeaturesInSchemaType(relationship).isEmpty»
			«generateRelationshipTable(referencedEntity, op)»
		«ELSE»
			«IF isOneorCeroToOne(multiplicity)»
				-- (1) Multiplicity ? o &: Add reference column at actual table
				ALTER TABLE «parent.toUpperCase» 
				«getFieldWithSubIndx(op.spec.selector.target, referencedKeys.size).split(", ").map[c | "ADD COLUMN " + generateSimpleFeature(c, op.spec.type, null)].join(",\n")»;
				
				-- (2) Add foreign key
				ALTER TABLE «parent.toUpperCase»
				ADD CONSTRAINT «parent.toLowerCase»_«featureName.toLowerCase»_fk FOREIGN KEY («getFieldWithSubIndx(op.spec.selector.target, referencedKeys.size)»)
				REFERENCES «targetEntity.toUpperCase»(«referencedKeys.map[k | k.name].join(", ")»);
			«ELSE»
				-- (1) Multiplicity * o +: Add reference column at the referenced table
				ALTER TABLE «targetEntity.toUpperCase» 
				ADD COLUMN «generateSimpleFeature(op.spec.selector.target, op.spec.type, null)»;
				
				-- (2) Add foreign key
				ALTER TABLE «targetEntity.toUpperCase»
				ADD CONSTRAINT «parent.toLowerCase»_fk FOREIGN KEY («aHandler.getKeysInSchemaType(parentEntity).map[k | k.name].join(", ")»)
				REFERENCES «parent.toUpperCase»(«op.spec.selector.target»);
			«ENDIF»
			
			«IF relationship !== null»
				«val featureNameFirst = aHandler.getFeaturesInSchemaType(relationship).map[f | (f as SimpleFeature).name].toList.first»
				CALL dropFKsInTable("«parentEntity.name.toUpperCase»");
				ALTER TABLE «parentEntity.name.toUpperCase» DROP PRIMARY KEY;
				
				«val referenceEntityRelationship = aHandler.getReferencedEntities(relationship).get(0)»
				«val referenceFirstKeys = aHandler.getKeysInSchemaType(referenceEntityRelationship)»
				
				ALTER TABLE «parentEntity.name.toUpperCase» ADD PRIMARY KEY («getFieldWithSubIndx(featureNameFirst, referenceFirstKeys.size)», «getFieldWithSubIndx(featureName, referencedKeys.size)»);
				
				ALTER TABLE «parentEntity.name.toUpperCase» 
				ADD CONSTRAINT «parentEntity.name.toLowerCase»_«featureName.toLowerCase»_fk FOREIGN KEY («getFieldWithSubIndx(featureName, referencedKeys.size)») 
				REFERENCES «referencedEntity.name.toUpperCase» («referencedKeys.map[k | k.name].join(", ")»);
				
				ALTER TABLE «parentEntity.name.toUpperCase» 
				ADD CONSTRAINT «parentEntity.name.toLowerCase»_«featureNameFirst.toLowerCase»_fk FOREIGN KEY («getFieldWithSubIndx(featureNameFirst, referenceFirstKeys.size)») 
				REFERENCES «referencedEntity.name.toUpperCase» («referenceFirstKeys.map[k | k.name].join(", ")»);
			«ENDIF»
		«ENDIF»
	'''
	
	private def String getFieldWithSubIndx(String field, int amount)
	{
		if (amount <= 1) {
        return field
    	}	

		(1 .. amount)
		    .map[ idx | field + "_" + idx ]
		    .join(", ")
	}
	
	private def CharSequence generateRelationshipTable(EntityDecl referencedEntity, ReferenceAddOp op)
	'''
	«val cols = aHandler.getKeysInSchemaType(referencedEntity)»
	   CREATE TABLE IF NOT EXISTS «op.spec.selector.ref.toUpperCase» (
	   «getFieldWithSubIndx(op.spec.selector.target, cols.size).split(", ").map[c | generateSimpleFeature(c, op.spec.type, null) + ","].join("\n")»
	   	CONSTRAINT «op.spec.selector.target»_pk PRIMARY KEY («getFieldWithSubIndx(op.spec.selector.target, cols.size)»),
	   	CONSTRAINT «op.spec.selector.ref.toLowerCase»_«op.spec.selector.target.toLowerCase»_fk FOREIGN KEY («getFieldWithSubIndx(op.spec.selector.target, cols.size)») REFERENCES «op.spec.ref.toUpperCase»(«cols.map[f | f.name].join(", ")»)
	   );
	'''

	// Cast the data type of foreign key columns in tables.
	// For each entity and for each referenced target column,
	// it calls a stored procedure to cast the both columns in the database.
	private def dispatch generateBasicOp(ReferenceCastOp op) '''
		«FOR e : OrionUtils.getSchemaTypesFromSelector(schemaUpdater.schema, op.spec.selector)
	          .filter[e | op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(e, t) !== null]]»
			«FOR columnName : op.spec.selector.targets
	            .filter[t | aHandler.getSimpleFeatureInSchemaType(e, t) !== null]»
				CALL castColumnFKs("«e.name.toUpperCase»", "«columnName.toLowerCase»", "«tConverter.typeToMySQLType(op.spec.type.typename)»");
			«ENDFOR»
		  «ENDFOR»
	'''

	// Add an aggregate (a collection or complex attribute) to an entity.
	// It creates a new table named after the parent entity and the aggregate's name, including keys from the parent entity and the aggregate's features.
	private def dispatch generateBasicOp(AggregateAddOp op) '''
		«val parentEntity = aHandler.getEntityDecl(schemaUpdater.schema, op.spec.selector.ref)»
		«val keys = aHandler.getKeysInSchemaType(parentEntity)»
		«val features = op.spec.features.map[EcoreUtil2.copy(it)].map[toSimpleFeature].toList»
		«val uniques = features.filter[f | f.isUnique].toList»
		«val table = op.spec.selector.ref + "_" + op.spec.selector.target»
		CREATE TABLE IF NOT EXISTS «table.toUpperCase»
		(
			«IF !isOneorCeroToOne(op.spec.multiplicity)»
				«val additionalKey = createKey(op.spec.selector.target + "_id", "Identifier")»
				«generateDataType(additionalKey.name, additionalKey.type as DataType, null)»,
			«ENDIF»
			«FOR key : keys SEPARATOR "\n"»«generateSimpleFeature(key.name, key.type, null)»,«ENDFOR»
			«FOR feat : features SEPARATOR "\n"»«generateSimpleFeature(feat.name, feat.type, null)»,«ENDFOR»
			«FOR feat : uniques SEPARATOR "\n"»CONSTRAINT «table.toLowerCase»_«feat.name»_ak UNIQUE(«feat.name»),«ENDFOR»
			«IF isOneorCeroToOne(op.spec.multiplicity)»
				CONSTRAINT «op.spec.selector.target»_pk PRIMARY KEY(«keys.map[f | f.name].join(", ")»),
			«ELSE»
				CONSTRAINT «op.spec.selector.target»_pk PRIMARY KEY(«keys.map[f | f.name].join(", ")», «op.spec.selector.target»_id),
			«ENDIF»
			CONSTRAINT «table.toLowerCase»_fk FOREIGN KEY(«keys.map[f | f.name].join(", ")») REFERENCES «op.spec.selector.ref.toUpperCase»(«keys.map[f | f.name].join(", ")») 
		);
	'''

	// Creates a table with the relationship's features and unique constraints.
	private def dispatch generateBasicOp(RelationshipAddOp op) 
	'''
	«IF op.spec.features.isEmpty»-- YOU NEED ADD AT LEAST ONE REFERENCE TO GENERATE THE TABLE
	«ELSE»
	«val features = op.spec.features.map[EcoreUtil2.copy(it)].map[toSimpleFeature].toList»
	«val uniques = features.filter[f | f.isUnique].toList»
	CREATE TABLE IF NOT EXISTS «op.spec.name»
	(
	   «FOR feat : features SEPARATOR ",\n"»«generateSimpleFeature(feat.name, feat.type, null)»«ENDFOR»
	   «FOR feat : uniques SEPARATOR "\n"»CONSTRAINT «op.spec.name.toLowerCase»_«feat.name»_ak UNIQUE(«feat.name»),«ENDFOR»
	);
	«ENDIF»
	'''
	
	// Rename an existing relationship type table.
	private def dispatch generateBasicOp(RelationshipRenameOp op) 
	'''RENAME TABLE «op.spec.ref.toUpperCase» TO «op.spec.name.toUpperCase»;'''
	
	// Delete an existing relationship type table.
	private def dispatch generateBasicOp(RelationshipDeleteOp op) 
	'''DROP TABLE «op.spec.ref.toUpperCase»;'''

	private def dispatch generateBasicOp(EntityDelVarOp op) '''--- Operation not supported.'''

	private def dispatch generateBasicOp(EntityAdaptOp op) '''--- Operation not supported.'''

	private def dispatch generateBasicOp(EntityUnionOp op) '''-- Operation not supported.'''

	private def dispatch generateBasicOp(FeatureNestOp op) '''--- Operation not supported.'''

	private def dispatch generateBasicOp(FeatureUnnestOp op) '''--- Operation not supported.'''

	private def dispatch generateBasicOp(ReferenceMultiplicityOp op) '''--- Operation not supported.'''

	private def dispatch generateBasicOp(ReferenceMorphOp op) '''--- Operation not supported.'''

	private def dispatch generateBasicOp(AggregateMultiplicityOp op) '''--- Operation not supported.'''

	private def dispatch generateBasicOp(AggregateMorphOp op) '''--- Operation not supported.'''
	
	// The simple feature with a given data type and keys.
	private def dispatch generateSimpleFeature(String name, DataType type,
		java.util.List<SimpleFeature> keys) '''«generateDataType(name, type, keys)»'''

	// Generates SQL for a simple aggregate target, without recursive expansion.
	// It also generates unique and primary key constraints depending on multiplicity.
	private def dispatch generateSimpleFeature(String name, SimpleAggregateTarget aggr,
		java.util.List<SimpleFeature> keys) '''
		«val parent = name.split(",").head»
		«val aggrName = name.split(",").last»
		«val features = aHandler.getFeaturesInSchemaType(aggr.aggr.get(0) as EntityDecl)
			.filter[f | f instanceof SimpleFeature && !((f as SimpleFeature).type instanceof SimpleAggregateTarget)].map[f | f as SimpleFeature].toList»
		«val datatypeFeatures = features.filter[f | !((f as SimpleFeature).type instanceof SimpleReferenceTarget)].sortBy[f | f.name].toList»
		«val references = features.filter[f | (f as SimpleFeature).type instanceof SimpleReferenceTarget]
	    			.map[f | f as SimpleFeature].sortBy[f | f.name].toList»
		   «val uniques = features.filter[f | f.isUnique].toList»
		«IF !isOneorCeroToOne(aggr.multiplicity)»
			«val additionalKey = createKey(aggrName, "Identifier")»
			«generateDataType(additionalKey.name + "_id", additionalKey.type as DataType, null)»,
		«ENDIF»
		«FOR key : keys SEPARATOR "\n"»«generateDataType(key.name, key.type as DataType, null)»,«ENDFOR»
		«FOR feat : datatypeFeatures SEPARATOR "\n"»«generateDataType(feat.name, feat.type as DataType, null)»,«ENDFOR»
		«FOR ref : references SEPARATOR "\n"»«FOR r : aHandler.getKeysInSchemaType(getEntityRef(ref.type)) SEPARATOR "\n"»«generateDataType(r.name, r.type as DataType, null)»,«ENDFOR»«ENDFOR»
		«FOR ref : references SEPARATOR "\n"»CONSTRAINT «ref.name»_fk FOREIGN KEY(«aHandler.getKeysInSchemaType(getEntityRef(ref.type)).map[f | f.name].join(", ")») REFERENCES «getEntityRef(ref.type).name.toUpperCase»(«aHandler.getKeysInSchemaType(getEntityRef(ref.type)).map[f | f.name].join(", ")»),«ENDFOR»
		«FOR feat : uniques SEPARATOR "\n"»CONSTRAINT «parent»_«aggrName»_«feat.name»_ak UNIQUE(«feat.name»),«ENDFOR»
		«IF isOneorCeroToOne(aggr.multiplicity)»
			CONSTRAINT «aggrName»_pk PRIMARY KEY(«keys.map[f | f.name].join(", ")»),
		«ELSE»
			CONSTRAINT «aggrName»_pk PRIMARY KEY(«keys.map[f | f.name].join(", ")», «aggrName»_id),
		«ENDIF»
		CONSTRAINT «parent»_«aggrName»_fk FOREIGN KEY(«keys.map[f | f.name].join(", ")») REFERENCES «parent.toUpperCase»(«keys.map[f | f.name].join(", ")»)
		«{getArgumentsInsert(datatypeFeatures, references) ""}»
	'''

	private def getArgumentsInsert(java.util.List<SimpleFeature> datatypeFeatures,
		java.util.List<SimpleFeature> references) {
		argumentsInsert = '''«FOR f : datatypeFeatures SEPARATOR ", "»«f.name»«ENDFOR»«IF references.size > 0», «ENDIF»«FOR ref : references»«FOR r : aHandler.getKeysInSchemaType(getEntityRef(ref.type)) SEPARATOR ", "»«r.name»«ENDFOR»«ENDFOR»'''
	}
	
	// Simple feature delegating to generateDataType.
	private def dispatch generateSimpleFeature(String name, SimpleReferenceTarget ref,
		java.util.List<SimpleFeature> keys) '''«generateDataType(name, ref.type, keys)»'''
	
	// ---------------------------DATA TYPE GENERATORS------------------------------------ //
	
	// List
	private def dispatch CharSequence generateDataType(String name, List type,
		java.util.List<SimpleFeature> keys) '''«name.toLowerCase» JSON'''
	
	// Set
	private def dispatch CharSequence generateDataType(String name, Set type, java.util.List<SimpleFeature> keys) '''
		«val setName = name.split(",").last»
		«val parentName = name.split(",").head»
		«FOR feat : keys SEPARATOR "\n"»«generateDataType(feat.name, feat.type as DataType, keys)», «ENDFOR»
		«generateDataType(setName, type.elementType, keys)»,
		CONSTRAINT «(setName + "_" + parentName).toLowerCase»_pk PRIMARY KEY («keys.map[f | f.name].join(", ")», «setName»),
		«IF keys.size == 1»
			CONSTRAINT «(setName + "_" + parentName).toLowerCase»_fk FOREIGN KEY («keys.head.name») REFERENCES «parentName.toUpperCase»(«keys.head.name»)
		«ELSE»
			CONSTRAINT «(setName + "_" + parentName).toLowerCase»_fk FOREIGN KEY («keys.map[f | f.name].join(", ")») REFERENCES «parentName.toUpperCase»(«keys.map[f | f.name].join(", ")»)
		«ENDIF»
	'''
	
	// Map
	private def dispatch CharSequence generateDataType(String name, Map type, java.util.List<SimpleFeature> keys) '''
		«val mapName = name.split(",").last»
		«val parentName = name.split(",").head»
		«FOR feat : keys SEPARATOR "\n"»«generateDataType(feat.name, feat.type as DataType, keys)», «ENDFOR»
		«generateDataType(mapName + "_key", type.keyType, keys)»,
		«generateDataType(mapName + "_value", type.valueType, keys)»,
		CONSTRAINT «(mapName + "_" + parentName).toLowerCase»_pk PRIMARY KEY («keys.map[f | f.name].join(", ")», «mapName + "_key"»),
		«IF keys.size == 1»
			CONSTRAINT «(mapName + "_" + parentName).toLowerCase»_fk FOREIGN KEY («keys.head.name») REFERENCES «parentName.toUpperCase»(«keys.head.name»)
		«ELSE»
			CONSTRAINT «(mapName + "_" + parentName).toLowerCase»_fk FOREIGN KEY («keys.map[f | f.name.toLowerCase].join(", ")») REFERENCES «parentName»(«keys.map[f | f.name.toLowerCase].join(", ")»)
		«ENDIF»
	'''
	
	// Tuple
	private def dispatch CharSequence generateDataType(String name, Tuple type, java.util.List<SimpleFeature> keys) '''
		«val tupleName = name.split(",").last»
		«val parentName = name.split(",").head»
		«FOR feat : keys SEPARATOR "\n"»«generateDataType(feat.name, feat.type as DataType, keys)», «ENDFOR»
		«FOR DataType t : type.elements SEPARATOR "\n"»«generateDataType(tupleName + "_" + type.elements.indexOf(t), t, keys)», «ENDFOR»
		CONSTRAINT «(tupleName + "_" + parentName).toLowerCase»_pk PRIMARY KEY («keys.map[f | f.name].join(", ")»),
		«IF keys.size == 1»
			CONSTRAINT «(tupleName + "_" + parentName).toLowerCase»_fk FOREIGN KEY («keys.head.name») REFERENCES «parentName.toUpperCase»(«keys.head.name»)
		«ELSE»
			CONSTRAINT «(tupleName + "_" + parentName).toLowerCase»_fk FOREIGN KEY («keys.map[f | f.name].join(", ")») REFERENCES «parentName.toUpperCase»(«keys.map[f | f.name].join(", ")»)
		«ENDIF»
	'''

	// Optional
	private def dispatch CharSequence generateDataType(String name, OptionPrimitiveType type,
		java.util.List<SimpleFeature> keys) '''«generateDataType(name, aHandler.getMostSuitableType(type.options), keys)»'''

	// Primitive type
	private def dispatch generateDataType(String name, SinglePrimitiveType type,
		java.util.List<SimpleFeature> keys) '''«name.toLowerCase» «tConverter.typeToMySQLType(type.typename)»'''

	// String enumerated
	private def dispatch generateDataType(String name, EnumRestrictedString type,
		java.util.List<SimpleFeature> keys) '''«name.toLowerCase» «tConverter.typeToMySQLType(type.typename)» CHECK («name.toLowerCase» IN ('«type.enumVals.join("', '")»'))'''

	// Number enumerated
	private def dispatch generateDataType(String name, EnumRestrictedNumber type,
		java.util.List<SimpleFeature> keys) '''«name.toLowerCase» «tConverter.typeToMySQLType(type.typename)» CHECK («name.toLowerCase» IN («type.enumVals.join(", ")»))'''

	// Numbers range
	private def dispatch generateDataType(String name, RangedNumber type,
		java.util.List<SimpleFeature> keys) '''«name.toLowerCase» «tConverter.typeToMySQLType(type.typename)» CHECK («name.toLowerCase» BETWEEN «type.from» AND «type.to»)'''

	// Expressions regular
	private def dispatch generateDataType(String name, RegexpRestrictedString type,
		java.util.List<SimpleFeature> keys) '''«name.toLowerCase» «tConverter.typeToMySQLType(type.typename)» CHECK («name.toLowerCase» REGEXP '«regexpWithoutSlashes(type.regexp)»')'''
	
	private def String regexpWithoutSlashes(String regexp) {
    	regexp.replaceFirst("^/", "").replaceFirst("/$", "")
	}
	// Method to filter collections, collections are new additional tables.
	private def boolean isCollection(Type type) {
		type instanceof Set || type instanceof Map || type instanceof Tuple || type instanceof SimpleAggregateTarget
	}

	private def EntityDecl getEntityRef(Type ref) {
		((ref as SimpleReferenceTarget).ref as EntityDecl)
	}
	
	// Method aux to split and extract
	// 1) Creates a new table named `newTable`:
	// 2) Copies data from the source table to the new table for the selected features.
	private def CharSequence generateExtractOperation(String newTable, String sourceTable,
		java.util.List<String> features) '''
		«val schema = aHandler.getEntityDecl(schemaUpdater.schema,sourceTable)»
		«val  simpleFeatures = aHandler.getFeaturesInSchemaType(schema)»
		«val keys = simpleFeatures.filter[f | f instanceof SimpleFeature && (f as SimpleFeature).isKey].map[f | f as SimpleFeature].toList»
		«val datatypeFeatures = simpleFeatures.filter[f | f instanceof SimpleFeature && !(f as SimpleFeature).isKey && features.contains((f as SimpleFeature).name) && (f as SimpleFeature).type instanceof DataType]
    .map[f | f as SimpleFeature].toList»
		«val references = simpleFeatures.filter[f | f instanceof SimpleFeature && features.contains((f as SimpleFeature).name) && (f as SimpleFeature).type instanceof SimpleReferenceTarget]
    			.map[f | f as SimpleFeature].toList»
		-- (1) Crear nueva tabla con los atributos extraídos
		CREATE TABLE IF NOT EXISTS «newTable.toUpperCase()» (
		    «FOR key : keys SEPARATOR "\n"»«generateSimpleFeature(key.name, key.type, null)»,«ENDFOR»
		    «FOR feat : datatypeFeatures SEPARATOR "\n"»«generateSimpleFeature(feat.name, feat.type, null)»,«ENDFOR»
		    «FOR ref : references SEPARATOR "\n"»«FOR r : aHandler.getKeysInSchemaType(getEntityRef(ref.type)) SEPARATOR "\n"»«generateSimpleFeature(r.name, r.type, null)»,«ENDFOR»«ENDFOR»	    
		    «FOR ref : references SEPARATOR "\n"»CONSTRAINT «ref.name»_fk FOREIGN KEY(«aHandler.getKeysInSchemaType(getEntityRef(ref.type)).map[f | f.name].join(", ")») REFERENCES «getEntityRef(ref.type).name.toUpperCase»(«aHandler.getKeysInSchemaType(getEntityRef(ref.type)).map[f | f.name].join(", ")»),«ENDFOR»
		    CONSTRAINT «newTable.toLowerCase»_pk PRIMARY KEY («keys.map[f | f.name].join(", ")»)
		);
		
		-- (2) Copiar datos a la nueva tabla
		INSERT INTO «newTable.toUpperCase()» («keys.map[f | f.name].join(", ")»«IF datatypeFeatures.size > 0», «ENDIF»«FOR f : datatypeFeatures SEPARATOR ", "»«f.name»«ENDFOR»«IF references.size > 0», «ENDIF»«FOR ref : references»«FOR r : aHandler.getKeysInSchemaType(getEntityRef(ref.type)) SEPARATOR ", "»«r.name»«ENDFOR»«ENDFOR»)
		SELECT «keys.map[f | f.name].join(", ")»«IF datatypeFeatures.size > 0», «ENDIF»«FOR f : datatypeFeatures SEPARATOR ", "»«f.name»«ENDFOR»«IF references.size > 0», «ENDIF»«FOR ref : references»«FOR r : aHandler.getKeysInSchemaType(getEntityRef(ref.type)) SEPARATOR ", "»«r.name»«ENDFOR»«ENDFOR» FROM «sourceTable.toUpperCase()»;	
	'''
	
	// Converts a SimpleDataFeature (orion) into a SimpleFeature (Athena)
	def SimpleFeature toSimpleFeature(SimpleDataFeature simpleDataFeature) {
		val factory = new AthenaFactory()
		val simpleFeature = factory.createSimpleFeature(simpleDataFeature.name, simpleDataFeature.type)
		simpleFeature.unique = simpleDataFeature.unique
		simpleFeature.optional = simpleDataFeature.optional
		simpleFeature.key = simpleDataFeature.key
		simpleFeature
	}
	
	// Creates a key feature with the given name and primitive type.
	def SimpleFeature createKey(String name, String typename) {
		val factory = new AthenaFactory()
		val simpleFeature = factory.createSimpleFeature(name)
		simpleFeature.type = factory.createSinglePrimitiveType(typename)
		simpleFeature.key = true
		simpleFeature.unique = false
		simpleFeature.optional = false
		simpleFeature
	}

	def boolean isOneorCeroToOne(String multiplicity) {
		return multiplicity.equals("&") || multiplicity.equals("?")
	}

	

}