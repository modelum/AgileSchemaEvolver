package es.um.uschema.xtext.athena.m2t

import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.ComposedReference
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.validation.m2t.MySQLValidator
import es.um.uschema.xtext.athena.athena.Feature
import java.util.Collection
import es.um.uschema.xtext.athena.athena.SchemaTypeDecl
import es.um.uschema.xtext.athena.utils.AthenaFactory
import es.um.uschema.xtext.athena.athena.VariationDecl
import es.um.uschema.xtext.athena.athena.RangedNumber
import es.um.uschema.xtext.athena.athena.RegexpRestrictedString
import es.um.uschema.xtext.athena.athena.EnumRestrictedNumber
import es.um.uschema.xtext.athena.athena.EnumRestrictedString
import es.um.uschema.xtext.athena.m2m.Athena2MySQLAthena
import es.um.uschema.xtext.athena.athena.OptionPrimitiveType
import es.um.uschema.xtext.athena.utils.TypeConverter

class Athena2MySQL
{
  val handler = new AthenaHandler()
  val factory = new AthenaFactory()
  val tConverter = new TypeConverter()

  def String m2t(AthenaSchema schema, boolean mysqlNormalizeRelations, boolean mysqlNormalizeCollections)
  {
    val nSchema = new Athena2MySQLAthena().m2m(new AthenaNormalizer().m2m(schema), mysqlNormalizeRelations, mysqlNormalizeCollections)

    val validator = new MySQLValidator()
    validator.validate(nSchema)
    validator.getSummary()

    val result = new StringBuilder()

    result.append(genHeader(nSchema))

    for (EntityDecl e : nSchema.entities.sortBy[e | e.root])
      result.append(generateEntityDecl(e, handler.getReducedFeaturesInSchemaTypeAndVariations(e)))

    return result.toString
  }

  def genHeader(AthenaSchema schema)
  '''
		CREATE SCHEMA «schema.id.name»;
		USE «schema.id.name»;
		
	'''

  def generateEntityDecl(EntityDecl entity, Collection<Feature> features)
  '''
		CREATE TABLE «entity.name»
		(
		  «FOR feat : features.filter(SimpleFeature)»
		  	«generateFeature(feat)»,
		  «ENDFOR»
		  «IF !features.filter(SimpleFeature).exists[f | f.key]»
		  	«generateFeature(factory.createSimpleFeature("id", factory.createUnrestrictedPrimitiveType("INTEGER")))»,
		  «ENDIF»
		  «FOR feat : features.filter(SimpleFeature).filter[f | f.unique]»
		  	UNIQUE KEY ( «feat.name» ),
		  «ENDFOR»
		  «FOR feat : features.filter(ComposedReference)»
		  	FOREIGN KEY ( «feat.names.join(", ")» ) REFERENCES «feat.target.ref.name» ( «FOR feat2 : handler.getFeaturesInSchemaType(feat.target.ref).filter(SimpleFeature).filter[f | f.key] SEPARATOR ", "»«feat2.name»«ENDFOR» ),
		  «ENDFOR»
		  «FOR feat : features.filter(SimpleFeature).filter[f | f.type instanceof SimpleReferenceTarget]»
		  	FOREIGN KEY ( «feat.name» ) REFERENCES «(feat.type as SimpleReferenceTarget).ref.name» ( «getFirstSQLKeyFeature((feat.type as SimpleReferenceTarget).ref).name» ),
		  «ENDFOR»
		  «FOR feat : features.filter(SimpleFeature).filter[f | f.type instanceof SimpleAggregateTarget]»
		  	FOREIGN KEY ( «feat.name» ) REFERENCES «(feat.type as SimpleAggregateTarget).aggr.head instanceof EntityDecl ? ((feat.type as SimpleAggregateTarget).aggr.head as EntityDecl).name : ((feat.type as SimpleAggregateTarget).aggr.head.eContainer as EntityDecl).name» ( «getFirstSQLKeyFeature((feat.type as SimpleAggregateTarget).aggr.head instanceof EntityDecl ? (feat.type as SimpleAggregateTarget).aggr.head as EntityDecl : (feat.type as SimpleAggregateTarget).aggr.head.eContainer as EntityDecl).name» ),
		  «ENDFOR»
		  PRIMARY KEY ( «IF !features.filter(SimpleFeature).exists[f | f.key]»id«ELSE»«FOR feat : features.filter(SimpleFeature).filter[f | f.key] SEPARATOR ", "»«feat.name»«ENDFOR»«ENDIF» )
		);
		
	'''

  def dispatch generateFeature(ComposedReference ref)
  {
    // Ignore
  }

  def dispatch generateFeature(SimpleFeature feat)
  '''«feat.name» «generateType(feat.type)»«IF !feat.optional && !belongsToVariation(feat)» NOT NULL«ENDIF»'''
  // The reference is generated later on as a foreign key.
  private def dispatch CharSequence generateType(SimpleReferenceTarget type)
  '''«generateType(type.type)»'''

  private def dispatch CharSequence generateType(SimpleAggregateTarget type)
  '''«generateType(getFirstSQLKeyFeature(type.aggr.head instanceof EntityDecl ? type.aggr.head as EntityDecl : type.aggr.head.eContainer as EntityDecl).type)»''' // The aggregate was already generated and the foreign key will be generated later on.

  // Lists might have been translated to m..n relationships beforehand.
  // If there is a List type at this point, we encode it as a String.
  private def dispatch CharSequence generateType(List type)
  '''JSON'''

  // Set might have been translated to m..n relationships beforehand.
  // If there is a List type at this point, we encode it as a String.
  private def dispatch CharSequence generateType(Set type)
  '''JSON'''

  // Map might have been translated to m..n relationships beforehand.
  // If there is a List type at this point, we encode it as a String.
  private def dispatch CharSequence generateType(Map type)
  '''JSON'''

  // Tuples might have been translated to m..n relationships beforehand.
  // If there is a List type at this point, we encode it as a String.
  private def dispatch CharSequence generateType(Tuple type)
  '''JSON'''

  private def dispatch CharSequence generateType(OptionPrimitiveType type)
  '''«generateType(handler.getMostSuitableType(type.options))»'''

  private def dispatch CharSequence generateType(EnumRestrictedNumber type)
  '''ENUM ( «FOR value : type.enumVals SEPARATOR ", "»'«value»'«ENDFOR» )'''

  private def dispatch CharSequence generateType(EnumRestrictedString type)
  '''ENUM ( «FOR value : type.enumVals SEPARATOR ", "»'«value»'«ENDFOR» )'''

  private def dispatch CharSequence generateType(RangedNumber type)
  '''«tConverter.typeToMySQLType(type.typename)» CHECK ( «(type.eContainer as SimpleFeature).name» BETWEEN «type.from» AND «type.to» )'''

  private def dispatch CharSequence generateType(RegexpRestrictedString type)
  '''«tConverter.typeToMySQLType(type.typename)» CHECK ( «(type.eContainer as SimpleFeature).name» LIKE '«type.regexp»' )'''

  private def dispatch CharSequence generateType(SinglePrimitiveType type)
  '''«tConverter.typeToMySQLType(type.typename)»'''

  private def getFirstSQLKeyFeature(SchemaTypeDecl schemaType)
  {
    val result = handler.getKeyInSchemaType(schemaType)

    if (result === null)
      return factory.createSimpleFeature("id", factory.createUnrestrictedPrimitiveType("INTEGER"))

    return result
  }

  private def belongsToVariation(SimpleFeature feat)
  {
    return feat.eContainer !== null && feat.eContainer.eContainer.eContainer instanceof VariationDecl
  }
}
