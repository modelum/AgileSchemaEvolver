package m2t

import codeql.option.SeverityEnum
import codeql.template.Library
import codeql.template.Metadata
import codeql.template.Query
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp
import java.util.HashMap
import java.util.List
import java.util.Map
import orion.Mapper
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp

class Orion2CodeQL {
	
	Map<String, String> results
	int contOp = 0;
	
	new()
	{
		results = new HashMap<String, String>()
	}
	
	def Map<String, String> m2t(OrionOperations orion)
	{
		if(!orion.operations.empty || !orion.evolBlocks.empty)
		{
			results.put("utils.qll", Library.generateUtils.toString);
			results.put("suite.qls", Metadata.generateSuite(orion.name + "-query-suite").toString);
			results.put("codeql-pack.yml", Metadata.generateCodeQLPack(orion.name).toString);
		}
		
		if (!orion.operations.empty) {
			generateOperations(orion.operations)
		} 

		results
	}
	
	def void generateOperations(List<BasicOperation> operations)
	{
		for( op : operations)
		{
			generateOperation(op)
			contOp++;
		}
	}
	
	def dispatch generateOperation(BasicOperation op)
	{
		// Operations without implementation
		contOp--;
	}
	
	def dispatch generateOperation(EntityDeleteOp op)
	{
		results.put(contOp + "-EntityDeleteOp.ql", 
		'''«Metadata.generateHeader("Deleted Entity", "alert", SeverityEnum.WARNING.value, "java/orion/entity-deleted/" + contOp)»«Query.generateEntityDeleteOp(op.spec.ref)»''')
		
	}
	
	def dispatch generateOperation(EntityRenameOp op)
	{
		results.put(contOp + "-EntityRenameOp.ql", 
		'''«Metadata.generateHeader("Renamed Entity", "alert", SeverityEnum.WARNING.value, "java/orion/entity-renamed/" + contOp)»«Query.generateEntityRenameOp(op.spec.ref, op.spec.name)»''')
	}
	
	def dispatch generateOperation(FeatureRenameOp op)
	{
		var selector = op.spec.selector
		results.put(contOp + "-FeatureRenameOp.ql", 
		'''«Metadata.generateHeader("Feature Renamed", "alert", SeverityEnum.WARNING.value, "java/orion/feature-renamed/" + contOp)»«Query.generateFeatureRenameOp(selector.ref, selector.target, op.spec.name)»''')
	}
	
	def dispatch generateOperation(FeatureDeleteOp op)
	{
		var selector = op.spec.selector
		var targetCount = 0;
		for(String target : selector.targets)
		{
			results.put(contOp + "-" + targetCount + "-FeatureDeleteOp.ql", 
			'''«Metadata.generateHeader("Feature Deleted", "alert", SeverityEnum.WARNING.value, "java/orion/feature-deleted/" + contOp + "/" + targetCount)»«Query.generateFeatureDeleteOp(selector.ref, target)»''')
			targetCount++;	
		}
	}
	
	def dispatch generateOperation(AttributeCastOp op)
	{
		var selector = op.spec.selector
		var type = Mapper.OrionType2Java(op.spec.type.typename)
		var targetCount = 0;
		if(!type.isEmpty)
		{
			for(String target : selector.targets)
			{
				results.put(contOp + "-" + targetCount + "-AttributeCastOp.ql", 
				'''«Metadata.generateHeader("Attribute Casted", "alert", SeverityEnum.WARNING.value, "java/orion/attribute-casted/" + contOp + "/" + targetCount)»«Query.generateAttributeCastOp(selector.ref, target, type)»''')
				targetCount++;
			}
		}else
		{
			contOp--;
		}
	}
	
	def dispatch generateOperation(AttributePromoteOp op)
	{
		var selector = op.spec.selector
		var fields = selector.targets.join(",")
		results.put(contOp + "-AttributePromoteOp.ql", 
			'''«Metadata.generateHeader("Attribute Promoted", "alert", SeverityEnum.WARNING.value, "java/orion/attribute-promoted/" + contOp)»«Query.generateAttributePromoteOp(selector.ref, fields)»''')

	}
	
	def dispatch generateOperation(RelationshipDeleteOp op)
	{
		results.put(contOp + "-RelationshipDeleteOp.ql", 
		'''«Metadata.generateHeader("Relationship Deleted", "alert", SeverityEnum.WARNING.value, "java/orion/relationship-deleted/" + contOp)»«Query.generateRelationshipDeleteOp(op.spec.ref)»''')
	}
	
	def dispatch generateOperation(RelationshipRenameOp op)
	{
		results.put(contOp + "-RelationshipRenameOp.ql", 
		'''«Metadata.generateHeader("Relationship Renamed", "alert", SeverityEnum.WARNING.value, "java/orion/relationship-renamed/" + contOp)»«Query.generateRelationshipRenameOp(op.spec.ref, op.spec.name)»''')
	}
	
	def dispatch generateOperation(EntitySplitOp op)
	{
		results.put(contOp + "-EntitySplitOp.ql", 
		'''«Metadata.generateHeader("Split Entity", "alert", SeverityEnum.WARNING.value, "java/orion/entity-splited/" + contOp)»«Query.generateEntityDeleteOp(op.spec.ref)»''')
	}
	
	def dispatch generateOperation(FeatureMoveOp op)
	{
		var selector = op.spec.sourceSelector
		results.put(contOp + "-FeatureMoveOp.ql", 
			'''«Metadata.generateHeader("Feature Moved", "alert", SeverityEnum.WARNING.value, "java/orion/feature-moved/" + contOp)»«Query.generateFeatureDeleteOp(selector.ref, selector.target)»''')
	}
	
	def dispatch generateOperation(ReferenceCastOp op)
	{
		var selector = op.spec.selector
		var type = Mapper.OrionType2Java(op.spec.type.typename)
		println(op.spec.type.typename)
		var targetCount = 0;
		if(!type.isEmpty)
		{
			for(String target : selector.targets)
			{
				results.put(contOp + "-" + targetCount + "-ReferenceCastOp.ql", 
				'''«Metadata.generateHeader("Reference Casted", "alert", SeverityEnum.WARNING.value, "java/orion/reference-casted/" + contOp + "/" + targetCount)»«Query.generateAttributeCastOp(selector.ref, target, type)»''')
				targetCount++;
			}
		}else
		{
			contOp--;
		}
	}

}
