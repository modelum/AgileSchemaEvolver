package es.um.uschema.xtext.athena.m2t

import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.ComposedReference
import es.um.uschema.xtext.athena.athena.PrimitiveType
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.VariationDecl
import org.eclipse.xtext.EcoreUtil2
import es.um.uschema.xtext.athena.validation.m2t.CassandraValidator
import es.um.uschema.xtext.athena.athena.OptionPrimitiveType
import es.um.uschema.xtext.athena.utils.TypeConverter

class Athena2Cassandra
{
  val handler = new AthenaHandler()
  val tConverter = new TypeConverter()

  def String m2t(AthenaSchema schema)
  {
    val nSchema = new AthenaNormalizer().m2m(schema)
    new CassandraValidator().validate(nSchema)

    val result = new StringBuilder()

    result.append(genHeader(nSchema))

    // First generate code for non-root entity types (aggregates) with the least aggregates on its own.
    for (EntityDecl e : nSchema.entities.filter[e | !e.root].sortBy[e | EcoreUtil2.getAllContentsOfType(e, SimpleAggregateTarget).size])
      result.append(generateUserType(e))

    for (EntityDecl e : nSchema.entities.filter[e | e.root])
      result.append(generateEntityDecl(e))

    return result.toString
  }

  def genHeader(AthenaSchema schema)
  '''
    CREATE KEYSPACE IF NOT EXISTS «schema.id.name.toLowerCase» WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 3 } ;
    USE «schema.id.name.toLowerCase» ;

  '''

  def generateUserType(EntityDecl entity)
  '''
    CREATE TYPE IF NOT EXISTS «entity.name.toLowerCase»
    (
      «FOR feat : handler.getReducedFeaturesInSchemaTypeAndVariations(entity).filter(SimpleFeature).sortBy[f | f.name] SEPARATOR ","»
      	«generateFeature(feat, true)»
      «ENDFOR»
    );

	'''

  def generateEntityDecl(EntityDecl entity)
  '''
    CREATE TABLE IF NOT EXISTS «entity.name.toLowerCase»
    (
      «FOR feat : handler.getReducedFeaturesInSchemaTypeAndVariations(entity).filter(SimpleFeature).filter[f | f.key]»
        «generateFeature(feat, false)»,
      «ENDFOR»
      «FOR feat : handler.getReducedFeaturesInSchemaTypeAndVariations(entity).filter(SimpleFeature).filter[f | !f.key].sortBy[f | f.name.toLowerCase]»
        «generateFeature(feat, false)»,
      «ENDFOR»
      PRIMARY KEY («handler.getFeaturesInSchemaType(entity).filter(SimpleFeature).filter[f | f.key || f.unique].sortBy[f | !f.key].map[f | f.name.toLowerCase].join(", ")»)
    );

	'''

  def dispatch generateFeature(ComposedReference ref, boolean freeze)
  {
    // Ignore. Just to allow the dispatch method work properly.
  }

  def dispatch generateFeature(SimpleFeature feat, boolean freeze)
  '''«feat.name.toLowerCase» «IF freeze && !(feat.type instanceof PrimitiveType || feat.type instanceof SimpleReferenceTarget)»frozen<«ENDIF»«generateType(feat.type)»«IF freeze && !(feat.type instanceof PrimitiveType || feat.type instanceof SimpleReferenceTarget)»>«ENDIF»'''

  private def dispatch CharSequence generateType(SimpleReferenceTarget type)
  '''«IF handler.isMultiplicityToMany(type.multiplicity)»list<«ENDIF»«IF type.type !== null»«generateType(type.type)»«ELSE»«generateType((handler.getFeaturesInSchemaType(type.ref).findFirst[f | f instanceof SimpleFeature && (f as SimpleFeature).key] as SimpleFeature).type)»«ENDIF»«IF handler.isMultiplicityToMany(type.multiplicity)»>«ENDIF»'''

  private def dispatch CharSequence generateType(SimpleAggregateTarget type)
  '''«IF handler.isMultiplicityToMany(type.multiplicity)»list<frozen<«ENDIF»«type.aggr.head instanceof EntityDecl ? (type.aggr.head as EntityDecl).name : ((type.aggr.head as VariationDecl).eContainer as EntityDecl).name»«IF handler.isMultiplicityToMany(type.multiplicity)»>>«ENDIF»'''

  private def dispatch CharSequence generateType(List type)
  '''list<«IF !(type.elementType instanceof PrimitiveType)»frozen<«ENDIF»«generateType(type.elementType)»«IF !(type.elementType instanceof PrimitiveType)»>«ENDIF»>'''

  private def dispatch CharSequence generateType(Set type)
  '''set<«IF !(type.elementType instanceof PrimitiveType)»frozen<«ENDIF»«generateType(type.elementType)»«IF !(type.elementType instanceof PrimitiveType)»>«ENDIF»>'''

  private def dispatch CharSequence generateType(Map type)
  '''map<«generateType(type.keyType)», «IF !(type.valueType instanceof PrimitiveType)»frozen<«ENDIF»«generateType(type.valueType)»«IF !(type.valueType instanceof PrimitiveType)»>«ENDIF»>'''

  private def dispatch CharSequence generateType(Tuple type)
  '''tuple<«FOR DataType dt : type.elements SEPARATOR ","»«IF !(dt instanceof PrimitiveType)»frozen<«ENDIF»«generateType(dt)»«IF !(dt instanceof PrimitiveType)»>«ENDIF»«ENDFOR»>'''

  private def dispatch CharSequence generateType(OptionPrimitiveType type)
  '''«generateType(handler.getMostSuitableType(type.options))»'''

  private def dispatch CharSequence generateType(SinglePrimitiveType type)
  '''«tConverter.typeToCassandraType(type.typename)»'''
}
