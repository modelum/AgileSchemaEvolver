package es.um.uschema.xtext.orion.validation.m2t

import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.RelationshipDecl
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.athena.Type
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.RelationshipAddOp
import es.um.uschema.xtext.orion.utils.OrionFactory
import es.um.uschema.xtext.orion.utils.OrionUtils
import es.um.uschema.xtext.orion.utils.io.OrionIO
import java.util.ArrayList
import org.eclipse.emf.ecore.EObject
import es.um.uschema.xtext.orion.orion.FeatureMoveOp

class MySQLValidator {
	val errorLog = new ArrayList()
	val warningLog = new ArrayList()
	val orionIO = new OrionIO()
	val factory = new OrionFactory()
	val aHandler = new AthenaHandler()
	val reservedWords = #[
	  "user", "order", "group", "select", "table", "index", "key", "name",
	  "from", "where", "join", "insert", "update", "delete",
	  "create", "drop", "alter", "view", "trigger", "procedure", "function",
	  "grant", "revoke", "unique", "primary", "foreign", "references", "check",
	  "database", "distinct", "into", "values", "and", "or", "not", "between",
	  "in", "like", "is", "null", "union", "all", "any", "exists", "case",
	  "when", "then", "else", "end", "having", "limit"
	]
	
	def getSummary() {
		if (!warningLog.empty)
			System.err.println("Some warnings were detected on this Orion file:\n" + warningLog.join("\n"))

		if (!errorLog.empty)
			throw new IllegalArgumentException("Some errors were detected on this Orion file:\n" + errorLog.join("\n"))
	}

	def dispatch checkBasicOperation(AthenaSchema schema, BasicOperation op) {
		// This method is used for operations where a validation does not apply...
	}

	def dispatch checkBasicOperation(AthenaSchema schema, EntityAddOp op) {
		if (op.spec.features.empty)
			registerErrorMessage("EntityAddOp", "A new Entity should define fields: ", op)
		else {
			if (op.spec.features.exists[f|f.type === null])
				registerErrorMessage("EntityAddOp", "The type must be a valid type: ", op)

			if(op.spec.features.exists[f | f.unique && f.optional])
				registerWarningMessage("EntityAddOp", "A UNIQUE column declared as optional (NULL) may allow duplicate NULLs: ", op)

			if (!op.spec.features.exists[f|f.key])
				registerErrorMessage("EntityAddOp", "A primary key is obligatory: ", op)

			for (f : op.spec.features)
				if (reservedWords.contains(f.name.toLowerCase))
					registerWarningMessage("EntityAddOp", "The field name '" + f.name + "' is a reserved SQL keyword and may cause issues.", op)
		}
	}

	def dispatch checkBasicOperation(AthenaSchema schema, EntityExtractOp op) {
		val aggrFeatures = op.spec.features.features.map [ f |
			aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schema, op.spec.ref), f)
		].filterNull

		if (aggrFeatures.exists[f|isSpecialPrimitive(f.type) && f.type instanceof SimpleAggregateTarget])
			registerErrorMessage("EntityExtractOp", "Cannot extract special primitive features or aggregates.", op)
	}

	def dispatch checkBasicOperation(AthenaSchema schema, FeatureCopyOp op) {
		val sourceEntity = aHandler.getEntityDecl(schema, op.spec.sourceSelector.ref)
		val feat = aHandler.getSimpleFeatureInSchemaType(sourceEntity, op.spec.sourceSelector.target)

		if (!(feat.type instanceof SinglePrimitiveType || feat.type instanceof SimpleReferenceTarget))
			registerErrorMessage("FeatureCopyOp", "Only primitive or reference features (?, *) can be copied.", op)
		else if(feat.type instanceof SimpleReferenceTarget &&
				!isOneorCeroToOne((feat.type as SimpleReferenceTarget).multiplicity))
		{
			registerErrorMessage("FeatureCopyOp", "Only references ? or & are allowed", op)
		}
		if(reservedWords.contains(op.spec.sourceSelector.target))
		{
			registerWarningMessage("FeatureCopyOp", "The field name '" + op.spec.sourceSelector.target + "' is a reserved SQL keyword and may cause issues.", op)
		}
	}
	
	def dispatch checkBasicOperation(AthenaSchema schema, FeatureMoveOp op) 
	{
		if(reservedWords.contains(op.spec.sourceSelector.target))
		{
			registerWarningMessage("FeatureCopyOp", "The field name '" + op.spec.sourceSelector.target + "' is a reserved SQL keyword and may cause issues.", op)
		}
	}

	def dispatch checkBasicOperation(AthenaSchema schema, AttributeCastOp op) {
		for (e : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector)) {
			for (target : op.spec.selector.targets) {
				val f = aHandler.getSimpleFeatureInSchemaType(e, target)
				if (f !== null && isSpecialPrimitive(f.type))
					registerErrorMessage("AttributeCastOp", "Only simple primitive types are allowed to be casted: ",
						op)
			}
		}
	}

	def dispatch checkBasicOperation(AthenaSchema schema, AttributePromoteOp op) {
		for (e : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector)) {
			for (target : op.spec.selector.targets) {
				val f = aHandler.getSimpleFeatureInSchemaType(e, target)
				if (f !== null && isSpecialPrimitive(f.type))
					registerErrorMessage("AttributePromoteOp",
						"Only simple primitive types are allowed to be promoted: ", op)
			}
		}
	}

	def dispatch checkBasicOperation(AthenaSchema schema, ReferenceAddOp op) {
		val parentEntity = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)
		
		if (parentEntity instanceof RelationshipDecl) {		
			val existingRefs = aHandler.getReferencedEntities(parentEntity)
			if (existingRefs.exists[r | r.name == op.spec.ref])
				registerErrorMessage("ReferenceAddOp", "This relationship already contains a reference to entity '" + op.spec.ref + "'.", op)
		}
		
		if(reservedWords.contains(op.spec.selector.target))
		{
			registerWarningMessage("ReferenceAddOp", "The field name '" + op.spec.selector.target + "' is a reserved SQL keyword and may cause issues.", op)
		}
	}

	def dispatch checkBasicOperation(AthenaSchema schema, AggregateAddOp op) {
		if (op.spec.features.empty)
			registerErrorMessage("AggregateAddOp", "Aggregates must define at least one feature: ", op)
		else{
			if (op.spec.features.exists[f|f.isKey])
				registerErrorMessage("AggregateAddOp", "Aggregate can't have a key: ", op)
			
			if(op.spec.features.exists[f | reservedWords.contains(f.name)])
				registerWarningMessage("AggregateAddOp", "A feature have a reserved SQL keyword and may cause issues.", op)

		}
	}
	
	def dispatch checkBasicOperation(AthenaSchema schema, RelationshipAddOp op)
	{
		if(op.spec.features.exists[f | f.isKey])
			registerErrorMessage("RelationshipAddOp", "RelationShip (n:m) don't have primary key distinct of references: ", op)
		
		if(op.spec.features.exists[f | reservedWords.contains(f.name)])
				registerWarningMessage("RelationshipAddOp", "A feature have a reserved SQL keyword and may cause issues.", op)
				
		for( f : op.spec.features)
		{
			if(!(f.type instanceof List) && isSpecialPrimitive(f.type))
				registerErrorMessage("RelationshipAddOp", "Only simple primitive types are allowed when you create a relationship", op)
		}
	}

	private def boolean isSpecialPrimitive(Type t) {
		t instanceof List || t instanceof Map || t instanceof Set || t instanceof Tuple
	}

	def boolean isOneorCeroToOne(String multiplicity) {
		return multiplicity.equals("&") || multiplicity.equals("?")
	}

	private def registerErrorMessage(String opName, String message, EObject obj) {
		errorLog.add("MySQL> " + opName + "> " + message + (obj !== null ? orionIO.serialize(obj)))
	}

	private def registerWarningMessage(String opName, String message, EObject obj) {
		warningLog.add("MySQL> " + opName + "> " + message + (obj !== null ? orionIO.serialize(obj)))
	}
	
}
