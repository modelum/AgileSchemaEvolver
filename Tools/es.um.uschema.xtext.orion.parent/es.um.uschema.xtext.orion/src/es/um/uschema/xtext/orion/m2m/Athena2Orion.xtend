package es.um.uschema.xtext.orion.m2m

import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.orion.utils.OrionFactory
import es.um.uschema.xtext.athena.athena.ShortEntityDecl
import es.um.uschema.xtext.athena.athena.RegularEntityDecl
import es.um.uschema.xtext.athena.athena.ShortRelationshipDecl
import es.um.uschema.xtext.athena.athena.RegularRelationshipDecl
import es.um.uschema.xtext.orion.orion.SimpleDataFeature
import java.util.ArrayList
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import java.util.List
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.athena.athena.VariationDecl

class Athena2Orion
{
  OrionOperations orionSpec
  AthenaHandler athenaHandler
  OrionFactory factory

  new()
  {
    this.athenaHandler = new AthenaHandler()
    this.factory = new OrionFactory()
  }

  def OrionOperations m2m(AthenaSchema schema)
  {
    val simplifiedSchema = new AthenaNormalizer().m2m(schema)
    orionSpec = factory.createOrionOperations(simplifiedSchema.id.name)

    for (entity : schema.entities.filter[e | e.isRoot])
      processSchemaType(entity)

    for (relationship : schema.relationships)
      processSchemaType(relationship)

    return orionSpec
  }

  private def dispatch processSchemaType(ShortEntityDecl entity)
  {
    createShortSchemaTypeOperations(entity.name, athenaHandler.getFeaturesInSchemaType(entity).filter(SimpleFeature).toList, true)
  }

  private def dispatch processSchemaType(RegularEntityDecl entity)
  {
    createRegularSchemaTypeOperations(entity.name, entity.variations, athenaHandler.getFeaturesInSchemaType(entity).filter(SimpleFeature).toList, true)
  }

  private def dispatch processSchemaType(ShortRelationshipDecl relationship)
  {
    createShortSchemaTypeOperations(relationship.name, athenaHandler.getFeaturesInSchemaType(relationship).filter(SimpleFeature).toList, false)
  }

  private def dispatch processSchemaType(RegularRelationshipDecl relationship)
  {
    createRegularSchemaTypeOperations(relationship.name, relationship.variations, athenaHandler.getFeaturesInSchemaType(relationship).filter(SimpleFeature).toList, false)
  }

  private def createShortSchemaTypeOperations(String name, List<SimpleFeature> features, boolean isEntityType)
  {
    val addOp = isEntityType ?
      factory.createEntityAddOp(name, generateSimpleDataFeatureList(features.filter[f | f.type instanceof DataType].toList))
      :
      factory.createRelationshipAddOp(name, generateSimpleDataFeatureList(features.filter[f | f.type instanceof DataType].toList))

    orionSpec.operations.add(addOp)
    orionSpec.operations.addAll(generateRefAddOps(name, features.filter[f | f.type instanceof SimpleReferenceTarget].toList))
    orionSpec.operations.addAll(generateAggrAddOps(name, features.filter[f | f.type instanceof SimpleAggregateTarget].toList))
  }

  private def createRegularSchemaTypeOperations(String name, List<VariationDecl> variations, List<SimpleFeature> features, boolean isEntityType)
  {
    val addOp = isEntityType ?
      factory.createEntityAddOp(name, generateSimpleDataFeatureList(features.filter[f | f.type instanceof DataType].toList))
      :
      factory.createRelationshipAddOp(name, generateSimpleDataFeatureList(features.filter[f | f.type instanceof DataType].toList))

    // Generate the EntityAddOp with base features, and then ReferenceAddOps and AggregateAddOps (recursively if needed)
    orionSpec.operations.add(addOp)
    orionSpec.operations.addAll(generateRefAddOps(name, features.filter[f | f.type instanceof SimpleReferenceTarget].toList))
    orionSpec.operations.addAll(generateAggrAddOps(name, features.filter[f | f.type instanceof SimpleAggregateTarget].toList))

    // Now for each variation generate specific operations for features. Selectors will be adapted to include only over the specific variation.
    // We could optimize this process by creating a Map<Feature, List<Variations>> and packing a single operation with all the variations in which it appears.
    for (variation : variations)
    {
      val featuresInVariation = athenaHandler.getFeaturesInVariation(variation).filter(SimpleFeature)
      val attrAddOps = generateAttributeAddOps(name, featuresInVariation.filter[f | f.type instanceof DataType].toList)
      attrAddOps.forEach[op | op.spec.selector.variations.add(variation.name)]
      orionSpec.operations.addAll(attrAddOps)

      val refAddOps = generateRefAddOps(name, featuresInVariation.filter[f | f.type instanceof SimpleReferenceTarget].toList)
      refAddOps.forEach[op | op.spec.selector.variations.add(variation.name)]
      orionSpec.operations.addAll(refAddOps)

      val aggrAddOps = generateAggrAddOps(name, featuresInVariation.filter[f | f.type instanceof SimpleAggregateTarget].toList)
      aggrAddOps.forEach[op | op instanceof ReferenceAddOp ? op.spec.selector.variations.add(variation.name); op instanceof AggregateAddOp ? op.spec.selector.variations.add(variation.name)]
      orionSpec.operations.addAll(aggrAddOps)
    }
  }

  private def List<SimpleDataFeature> generateSimpleDataFeatureList(List<SimpleFeature> sFeatures)
  {
    val simpleFeatures = new ArrayList<SimpleDataFeature>()

    for (feat : sFeatures)
      simpleFeatures.add(processFeature(feat.name, feat.type as DataType, feat.key, feat.unique, feat.optional))

    return simpleFeatures
  }

  private def List<AttributeAddOp> generateAttributeAddOps(String name, List<SimpleFeature> attributes)
  {
    val result = new ArrayList<AttributeAddOp>()

    for (attr : attributes)
      result.add(factory.createAttributeAddOp(factory.createSingleFeatureSelector(name, attr.name), attr.type as DataType))

    return result
  }

  private def List<ReferenceAddOp> generateRefAddOps(String name, List<SimpleFeature> references)
  {
    val result = new ArrayList<ReferenceAddOp>()

    for (ref : references)
      result.add(factory.createReferenceAddOp(
        factory.createSingleFeatureSelector(name, ref.name),
        (ref.type as SimpleReferenceTarget).type,
        (ref.type as SimpleReferenceTarget).multiplicity,
        ref.optional,
        (ref.type as SimpleReferenceTarget).ref.name
      ))

    return result
  }

  private def List<BasicOperation> generateAggrAddOps(String name, List<SimpleFeature> aggregates)
  {
    val result = new ArrayList<BasicOperation>()

    for (aggrFeat : aggregates)
    {
      val aggrType = aggrFeat.type as SimpleAggregateTarget
      val featuresInAggr = athenaHandler.getFeaturesInAggregate(aggrType.aggr)
      val simpleFeatures = new ArrayList<SimpleDataFeature>()
  
      for (feat : featuresInAggr.filter(SimpleFeature).filter[f | f.type instanceof DataType])
        simpleFeatures.add(processFeature(feat.name, feat.type as DataType, feat.key, feat.unique, feat.optional))

      result.add(factory.createAggregateAddOp(
        factory.createSingleFeatureSelector(name, aggrFeat.name),
        simpleFeatures,
        aggrType.multiplicity,
        aggrFeat.isOptional,
        athenaHandler.getSimpleAggregateTargetName(aggrType)
      ))

      result.addAll(generateRefAddOps(athenaHandler.getSimpleAggregateTargetName(aggrType), featuresInAggr.filter(SimpleFeature).filter[f | f.type instanceof SimpleReferenceTarget].toList))
      result.addAll(generateAggrAddOps(athenaHandler.getSimpleAggregateTargetName(aggrType), featuresInAggr.filter(SimpleFeature).filter[f | f.type instanceof SimpleAggregateTarget].toList))
    }

    return result
  }

  // Conversion Athena -> Orion feature
  private def SimpleDataFeature processFeature(String name, DataType type, Boolean key, Boolean unique, Boolean optional)
  {
    val result = factory.createSimpleDataFeature(name, type)
    result.key = key
    result.unique = unique
    result.optional = optional

    return result
  }
}
