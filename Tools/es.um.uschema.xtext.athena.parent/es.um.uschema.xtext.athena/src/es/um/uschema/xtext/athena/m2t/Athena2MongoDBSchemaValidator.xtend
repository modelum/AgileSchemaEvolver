package es.um.uschema.xtext.athena.m2t

import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.athena.athena.ShortEntityDecl
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.athena.athena.RegularEntityDecl
import es.um.uschema.xtext.athena.athena.ComposedReference
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.athena.RangedNumber
import es.um.uschema.xtext.athena.athena.RegexpRestrictedString
import es.um.uschema.xtext.athena.athena.EnumRestrictedNumber
import es.um.uschema.xtext.athena.athena.EnumRestrictedString
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.athena.athena.Null
import es.um.uschema.xtext.athena.athena.PrimitiveType
import es.um.uschema.xtext.athena.athena.OptionPrimitiveType
import es.um.uschema.xtext.athena.validation.m2t.MongoDBValidator
import es.um.uschema.xtext.athena.utils.TypeConverter

class Athena2MongoDBSchemaValidator
{
  val handler = new AthenaHandler()
  val tConverter = new TypeConverter()
  String dbName = null

  def String m2t(AthenaSchema schema)
  {
    val nSchema = new AthenaNormalizer().m2m(schema)
    new MongoDBValidator().validate(nSchema)
    dbName = nSchema.id.name

    val result = new StringBuilder()

    result.append(genHeader())

    for (EntityDecl e : nSchema.entities.filter[e | e.root])
      result.append(generateEntityDecl(e))

    return result.toString
  }

  def genHeader()
  '''
		«dbName» = db.getSiblingDB("«dbName»")
		
	'''

  def generateEntityDecl(EntityDecl entity)
  '''
		«dbName».createCollection("«entity.name»",
		{
		  validator:
		  {
		    $jsonSchema:
		    {
		      bsonType: "object",
		      «IF !handler.getFeaturesInSchemaType(entity).empty»required: [ «FOR feat : handler.getFeaturesInSchemaType(entity).filter(SimpleFeature).filter[f | entity instanceof RegularEntityDecl || !f.optional] SEPARATOR ", "»"«feat.name»"«ENDFOR» ],«ENDIF»
		      properties:
		      {
		        «FOR feat : getFeatures(entity) SEPARATOR ", "»
		          «generateFeature(feat)»
		        «ENDFOR»
		      }
		    }
		  }
		});
		
	'''
  private def dispatch getFeatures(ShortEntityDecl entity) { return handler.getFeaturesInSchemaType(entity) }
  private def dispatch getFeatures(RegularEntityDecl entity) { return handler.getReducedFeaturesInSchemaTypeAndVariations(entity) }

  def dispatch generateFeature(ComposedReference ref)
  {
    // Ignore. Just to allow the dispatch method work properly.
  }

  def dispatch generateFeature(SimpleFeature feat)
  '''
    «feat.name»:
    {
      «generateType(feat.type, feat.name, feat.isOptional)»
    }
  '''

  private def dispatch CharSequence generateType(SimpleReferenceTarget type, String name, boolean optional)
  '''
    bsonType: "«IF handler.isMultiplicityToMany(type.multiplicity)»array«ELSE»«athenaTypeToMongoDBType(type.type)»«ENDIF»",
    «IF handler.isMultiplicityToMany(type.multiplicity)»items: { bsonType: "«athenaTypeToMongoDBType(type.type)»" } ,«ENDIF»
    description: "Field «name» must be of type «IF handler.isMultiplicityToMany(type.multiplicity)»array«ELSE»«athenaTypeToMongoDBType(type.type)»«ENDIF»«IF !optional» and IS required«ENDIF»."
  '''

  private def dispatch CharSequence generateType(SimpleAggregateTarget type, String name, boolean optional)
  '''
    «val aggregatedFeatures = handler.getFeaturesInAggregate(type.aggr).filter(SimpleFeature)»
    bsonType: "«IF handler.isMultiplicityToMany(type.multiplicity)»array«ELSE»object«ENDIF»",
    «IF handler.isMultiplicityToMany(type.multiplicity)»items: { bsonType: "object" } ,«ENDIF»
    «IF aggregatedFeatures.exists[f | !f.isOptional]»required: [ «FOR feat : aggregatedFeatures.filter[f | !f.isOptional] SEPARATOR ", "»"«feat.name»"«ENDFOR» ],«ENDIF»
    properties:
    {
      «FOR feat : aggregatedFeatures SEPARATOR ", "»
      	«generateFeature(feat)»
      «ENDFOR»
    },
    description: "Field «name» must be of type «IF handler.isMultiplicityToMany(type.multiplicity)»array«ELSE»object«ENDIF»«IF !optional» and IS required«ENDIF»."
  '''

  private def dispatch generateType(List type, String name, boolean optional)
  '''
		bsonType: "«athenaTypeToMongoDBType(type)»",
		«IF type.elementType instanceof PrimitiveType»items: { bsonType: "«athenaTypeToMongoDBType(type.elementType)»" } ,«ENDIF»
		description: "Field «name» must be of type array«IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch generateType(Set type, String name, boolean optional)
  '''
		bsonType: "«athenaTypeToMongoDBType(type)»",
		«IF type.elementType instanceof PrimitiveType»items: { bsonType: "«athenaTypeToMongoDBType(type)»" } ,«ENDIF»
		description: "Field «name» must be of type array«IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch generateType(Map type, String name, boolean optional)
  '''
		bsonType: "«athenaTypeToMongoDBType(type)»",
		description: "Field «name» must be of type object«IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch generateType(Tuple type, String name, boolean optional)
  '''
		bsonType: "«athenaTypeToMongoDBType(type)»",
		«IF type.elements.forall[t | t instanceof PrimitiveType]»items: { bsonType: [ «FOR e : type.elements SEPARATOR ", "»"«athenaTypeToMongoDBType(e)»" «ENDFOR» ] } ,«ENDIF»
		description: "Field «name» must be of type array«IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch generateType(OptionPrimitiveType type, String name, boolean optional)
  '''
		bsonType: [ «FOR o : type.options SEPARATOR ", "»"«athenaTypeToMongoDBType(o)»"«ENDFOR» ],
		description: "Field «name» must be of type [ «FOR o : type.options SEPARATOR ", "»«athenaTypeToMongoDBType(o)»«ENDFOR» ]«IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch generateType(SinglePrimitiveType type, String name, boolean optional)
  '''
		bsonType: "«athenaTypeToMongoDBType(type)»",
		description: "Field «name» must be of type «athenaTypeToMongoDBType(type)»«IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch CharSequence generateType(RangedNumber type, String name, boolean optional)
  '''
		bsonType: "«athenaTypeToMongoDBType(type)»",
		minimum: «type.from»,
		maximum: «type.to»,
		description: "Field «name» must be of type «athenaTypeToMongoDBType(type)» in range [ «type.from»..«type.to» ]«IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch CharSequence generateType(RegexpRestrictedString type, String name, boolean optional)
  '''
		bsonType : "«athenaTypeToMongoDBType(type)»",
		pattern : "«type.regexp.substring(1, type.regexp.length - 1)»",
		description: "Field «name» must be of type string «IF !optional», IS required «ENDIF» and match the regular expression pattern: «type.regexp»."
	'''

  private def dispatch CharSequence generateType(EnumRestrictedNumber type, String name, boolean optional)
  '''
		enum: [ «FOR v : type.enumVals SEPARATOR ", "»«v»«ENDFOR» ],
		description: "Field «name» can only be one of the ENUM values: [ «FOR v : type.enumVals SEPARATOR ", "»«v»«ENDFOR» ] «IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch CharSequence generateType(EnumRestrictedString type, String name, boolean optional)
  '''
		enum: [ «FOR v : type.enumVals SEPARATOR ", "»"«v»"«ENDFOR» ],
		description: "Field «name» can only be one of the ENUM values: [ «FOR v : type.enumVals SEPARATOR ", "»«v»«ENDFOR» ] «IF !optional» and IS required«ENDIF»."
	'''

  private def dispatch CharSequence athenaTypeToMongoDBType(Null type)
  '''null'''

  private def dispatch CharSequence athenaTypeToMongoDBType(List type)
  '''array'''

  private def dispatch CharSequence athenaTypeToMongoDBType(Set type)
  '''array'''

  private def dispatch CharSequence athenaTypeToMongoDBType(Map type)
  '''object'''

  private def dispatch CharSequence athenaTypeToMongoDBType(Tuple type)
  '''array'''

  private def dispatch CharSequence athenaTypeToMongoDBType(SinglePrimitiveType type)
  '''«tConverter.typeToMongoDBType(type.typename)»'''
}
