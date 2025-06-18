package es.um.uschema.xtext.orion.utils.updater

import es.um.uschema.xtext.athena.utils.AthenaFactory
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.athena.athena.SimpleFeature
import org.eclipse.xtext.EcoreUtil2
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.EntityMergeOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.athena.athena.VariationDecl
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.orion.orion.SimpleDataFeature
import es.um.uschema.xtext.orion.validation.m2m.AthenaSchemaUpdaterValidator
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp
import es.um.uschema.xtext.orion.utils.OrionFactory
import es.um.uschema.xtext.orion.utils.OrionUtils
import es.um.uschema.xtext.orion.orion.MultipleFeatureSelector
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.athena.athena.PrimitiveType
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import org.eclipse.emf.common.util.BasicEList
import es.um.uschema.xtext.orion.orion.RelationshipAddOp
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp
import es.um.uschema.xtext.orion.orion.RelationshipSplitOp
import es.um.uschema.xtext.orion.orion.RelationshipExtractOp
import es.um.uschema.xtext.orion.orion.RelationshipMergeOp
import es.um.uschema.xtext.orion.orion.RelationshipDelVarOp
import es.um.uschema.xtext.orion.orion.RelationshipAdaptOp
import es.um.uschema.xtext.orion.orion.RelationshipUnionOp
import es.um.uschema.xtext.athena.athena.RegularRelationshipDecl
import es.um.uschema.xtext.athena.athena.RelationshipDecl
import es.um.uschema.xtext.athena.athena.SchemaTypeDecl

class AthenaSchemaUpdater
{
  AthenaSchema schema
  AthenaSchemaUpdaterValidator validator
  val aHandler = new AthenaHandler
  val athenaFactory = new AthenaFactory
  val orionFactory = new OrionFactory

  new(AthenaSchema schema, boolean enable_validation)
  {
    this.schema = schema
    this.validator = new AthenaSchemaUpdaterValidator(enable_validation)
  }

  def AthenaSchema getSchema()
  {
    return this.schema
  }

  def dispatch void processOperation(EntityAddOp op)
  {
    validator.validateOperation(this.schema, op)

    if (aHandler.getEntityDecl(schema, op.spec.name) !== null)
      return

    var EntityDecl result;

    if (!op.spec.features.empty) // If there are features just add them to a short entity
    {
      result = athenaFactory.createShortEntityDecl(op.spec.name, true)

      for (feat : op.spec.features)
        aHandler.addFeatureToSchemaType(result, processFeature(EcoreUtil2.copy(feat)))
    }
    else
    { // If not we can only create an empty regular entity
      result = athenaFactory.createRegularEntityDecl(op.spec.name, true)
      aHandler.getVariations(result).add(athenaFactory.createVariationDecl(1))
    }

    schema.entities.add(result)
  }

  def dispatch void processOperation(EntityDeleteOp op)
  {
    validator.validateOperation(this.schema, op)
    val entity = aHandler.getEntityDecl(schema, op.spec.ref)

    // Operation is only performed if there is an entity with such a name.
    if (entity !== null)
      schema.entities.remove(entity)
    //TODO: References referencing this entity
    //TODO: Aggregations that embed this entity
  }

  def dispatch void processOperation(EntityRenameOp op)
  {
    validator.validateOperation(this.schema, op)
    val entity = aHandler.getEntityDecl(schema, op.spec.ref)

    // Operation is only performed if there is an entity with such a name and there is no entity with the new name.
    if (entity !== null && aHandler.getEntityDecl(schema, op.spec.name) === null)
      entity.name = op.spec.name
  }

  def dispatch void processOperation(EntitySplitOp op)
  {
    validator.validateOperation(this.schema, op)

    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)

    if (sourceEntity === null)
      return

    val featsToSplit = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceEntity).filter(SimpleFeature)

    // For each of the two new entities: create a new short entity and clone each of the features to be moved to the splitted entity
    // TODO: What to do with variations?
    val newEntity1 = athenaFactory.createShortEntityDecl(op.spec.name1, sourceEntity.root)
    for (featName : op.spec.features1.features)
    {
      val featToSplit = featsToSplit.findFirst[f | f.name.equals(featName)]
      if (featToSplit !== null)
        aHandler.addFeatureToSchemaType(newEntity1, EcoreUtil2.copy(featToSplit))
    }

    val newEntity2 = athenaFactory.createShortEntityDecl(op.spec.name2, sourceEntity.root)
    for (featName : op.spec.features2.features)
    {
      val featToSplit = featsToSplit.findFirst[f | f.name.equals(featName)]
      if (featToSplit !== null)
        aHandler.addFeatureToSchemaType(newEntity2, EcoreUtil2.copy(featToSplit))
    }

    // The reference type should still point to the key feature type, so no need to change it.
    EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.ref === sourceEntity].forEach[r | r.ref = newEntity1]

    // For each Aggregate, if it aggregates the Entity or one of its variations, redirect that aggregate to the new splitted entity
    EcoreUtil2.getAllContentsOfType(schema, SimpleAggregateTarget).filter[r | r.aggr.contains(sourceEntity)].forEach[r | r.aggr.clear; r.aggr.add(newEntity1)]

    if (aHandler.isSchemaTypeRegular(sourceEntity))
      EcoreUtil2.getAllContentsOfType(schema, SimpleAggregateTarget).filter[r | r.aggr.exists[aggrO | aHandler.getVariations(sourceEntity).contains(aggrO)]]
        .forEach[r | r.aggr.clear; r.aggr.add(newEntity1)]

    schema.entities.remove(sourceEntity)
    schema.entities.add(newEntity1)
    schema.entities.add(newEntity2)
  }


  def dispatch void processOperation(EntityExtractOp op)
  {
    validator.validateOperation(this.schema, op)

    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)

    if (sourceEntity === null)
      return

    val featsToExtract = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceEntity).filter(SimpleFeature)

    // Create a new short entity and clone each of the features to be moved to the extracted entity
    val newEntity = athenaFactory.createShortEntityDecl(op.spec.name, sourceEntity.root)
    for (featName : op.spec.features.features)
    {
      val featToExtract = featsToExtract.findFirst[f | f.name.equals(featName)]
      if (featToExtract !== null)
        aHandler.addFeatureToSchemaType(newEntity, EcoreUtil2.copy(featToExtract))
    }

    schema.entities.add(newEntity)
  }

  def dispatch void processOperation(EntityMergeOp op)
  {
    validator.validateOperation(this.schema, op)
    val sourceEntity1 = aHandler.getEntityDecl(schema, op.spec.ref1)
    val sourceEntity2 = aHandler.getEntityDecl(schema, op.spec.ref2)

    if (sourceEntity1 === null || sourceEntity2 === null)
      return

    val newEntity = athenaFactory.createShortEntityDecl(op.spec.name, sourceEntity1.root || sourceEntity2.root)
    schema.entities.add(newEntity)

    // For each feature of the merged entities, move the first occurrence to the new merged Entity
    for (feat : (aHandler.getFeaturesInSchemaTypeAndVariations(sourceEntity1) + aHandler.getFeaturesInSchemaTypeAndVariations(sourceEntity2)).filter(SimpleFeature))
      if (aHandler.getSimpleFeatureInSchemaType(newEntity, feat.name) === null)
        aHandler.addFeatureToSchemaType(newEntity, EcoreUtil2.copy(feat))

    // For each Aggregate and Reference, move them to point to the new merged Entity
    EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.ref === sourceEntity1 || r.ref === sourceEntity2].forEach[r | r.ref = newEntity]
    // For each Aggregate, if it aggregates the Entity or one of its variations, redirect that aggregate to the new splitted entity
    EcoreUtil2.getAllContentsOfType(schema, SimpleAggregateTarget).filter[r | r.aggr.contains(sourceEntity1) || r.aggr.contains(sourceEntity2)].forEach[r | r.aggr.clear; r.aggr.add(newEntity)]

    if (aHandler.isSchemaTypeRegular(sourceEntity1))
      EcoreUtil2.getAllContentsOfType(schema, SimpleAggregateTarget).filter[r | r.aggr.exists[aggrO | aHandler.getVariations(sourceEntity1).contains(aggrO)]].forEach[r | r.aggr.clear; r.aggr.add(newEntity)]

    if (aHandler.isSchemaTypeRegular(sourceEntity2))
      EcoreUtil2.getAllContentsOfType(schema, SimpleAggregateTarget).filter[r | r.aggr.exists[aggrO | aHandler.getVariations(sourceEntity2).contains(aggrO)]].forEach[r | r.aggr.clear; r.aggr.add(newEntity)]

    // Remove merging entities
    schema.entities.remove(sourceEntity1)
    schema.entities.remove(sourceEntity2)
  }

  def dispatch void processOperation(EntityDelVarOp op)
  {
    validator.validateOperation(schema, op)
    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)

    if (sourceEntity === null || !aHandler.isSchemaTypeRegular(sourceEntity))
      return;

    aHandler.getVariations(sourceEntity).removeIf([v | v.name.equals(op.spec.target)])

// For now we do not recalculate variationIds, so further operations do not fail. However at some point we should. User responsibility?
/*
    try
    {
      val varId = Integer.parseInt(op.spec.target)
      aHandler.getVariations(sourceEntity).filter[v | Integer.parseInt(v.name) > varId].forEach[v | v.name = String.valueOf(Integer.parseInt(v.name) - 1)]
    } catch (NumberFormatException e)
    {
      e.printStackTrace()
    }
*/
    // TODO: Should we recalculate common features ?
    //TODO: Aggregations that embed this entity
  }

  // Adapt operation at schema level holds the same semantics as DelVar 
  def dispatch void processOperation(EntityAdaptOp op)
  {
    validator.validateOperation(schema, op)
    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)

    if (sourceEntity === null || !aHandler.isSchemaTypeRegular(sourceEntity))
      return;

    if (!aHandler.getVariations(sourceEntity).exists[v | v.name.equals(op.spec.target)])
      return;

    !aHandler.getVariations(sourceEntity).removeIf([v | v.name.equals(op.spec.source)]) // <= Slightly different to DelVar

//  For now we do not recalculate variationIds, so further operations do not fail. However at some point we should. User responsibility?
/*
    try
    {
      val varId = Integer.parseInt(op.spec.source)
      aHandler.getVariations(sourceEntity).filter[v | Integer.parseInt(v.name) > varId].forEach[v | v.name = String.valueOf(Integer.parseInt(v.name) - 1)]
    } catch (NumberFormatException e)
    {
      e.printStackTrace()
    }
*/
    // TODO: Should we recalculate common features ?
    //TODO: Agregaciones que AGREGUEN esta variacion
  }

  def dispatch void processOperation(EntityUnionOp op)
  {
    validator.validateOperation(schema, op)
    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)

    if (sourceEntity === null)
      return;

    if (aHandler.isSchemaTypeShort(sourceEntity))
      aHandler.getFeaturesInSchemaType(sourceEntity).filter(SimpleFeature).forEach[f | f.optional = false]

    if (aHandler.isSchemaTypeRegular(sourceEntity))
    {
      val newEntity = athenaFactory.createRegularEntityDecl(sourceEntity.name, sourceEntity.root)
      newEntity.variations.add(athenaFactory.createVariationDecl(1))
      aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceEntity).forEach[f | f instanceof SimpleFeature ? (f as SimpleFeature).optional = false; aHandler.addFeatureToSchemaType(newEntity, EcoreUtil2.copy(f))]

      // The reference type should still point to the key feature type, so no need to change it.
      EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.ref === sourceEntity].forEach[r | r.ref = newEntity]

      // For each Aggregate, if it aggregates the Entity or one of its variations, redirect that aggregate to the newly entity
      EcoreUtil2.getAllContentsOfType(schema, SimpleAggregateTarget).filter[r | r.aggr.contains(sourceEntity)].forEach[r | r.aggr.clear; r.aggr.add(newEntity)]
      EcoreUtil2.getAllContentsOfType(schema, SimpleAggregateTarget).filter[r | r.aggr.exists[aggrO | aHandler.getVariations(sourceEntity).contains(aggrO)]]
        .forEach[r | r.aggr.clear; r.aggr.add(newEntity)]

      schema.entities.remove(sourceEntity)
      schema.entities.add(newEntity)
    }
   //TODO: Agregaciones que AGREGUEN esta variacion
  }

  def dispatch void processOperation(RelationshipAddOp op)
  {
    validator.validateOperation(this.schema, op)

    if (aHandler.getRelationshipDecl(schema, op.spec.name) !== null)
      return

    var RelationshipDecl result;

    if (!op.spec.features.empty) // If there are features just add them to a short entity
    {
      result = athenaFactory.createShortRelationshipDecl(op.spec.name)

      for (feat : op.spec.features)
        aHandler.addFeatureToSchemaType(result, processFeature(EcoreUtil2.copy(feat)))
    }
    else
    { // If not we can only create an empty regular relationship
      result = athenaFactory.createRegularRelationshipDecl(op.spec.name)
      aHandler.getVariations(result).add(athenaFactory.createVariationDecl(1))
    }

    schema.relationships.add(result)
  }

  def dispatch void processOperation(RelationshipDeleteOp op)
  {
    validator.validateOperation(this.schema, op)
    val relationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    // Operation is only performed if there is a relationships with such a name.
    if (relationship !== null)
    {
      for (ref : EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.contains(relationship) || aHandler.getVariations(relationship).exists[v | r.featuredBy.contains(v)]])
      {
        val feat = ref.eContainer() as SimpleFeature
        val varContainer = EcoreUtil2.getContainerOfType(feat, VariationDecl)
        if (varContainer !== null)
          aHandler.removeSimpleFeatureInVariation(varContainer as VariationDecl, feat.name)
        else
          aHandler.removeSimpleFeatureInSchemaType(EcoreUtil2.getContainerOfType(feat, SchemaTypeDecl), feat.name)
      }
      schema.relationships.remove(relationship)
    }
  }

  def dispatch void processOperation(RelationshipRenameOp op)
  {
    validator.validateOperation(this.schema, op)
    val relationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    // Operation is only performed if there is a relationship with such a name and there is no relationship with the new name.
    if (relationship !== null && aHandler.getRelationshipDecl(schema, op.spec.name) === null)
      relationship.name = op.spec.name
  }

  def dispatch void processOperation(RelationshipSplitOp op)
  {
    validator.validateOperation(this.schema, op)

    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    if (sourceRelationship === null)
      return

    val featsToSplit = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceRelationship).filter(SimpleFeature)

    // For each of the two new relationships: create a new short relationship and clone each of the features to be moved to the splitted relationship
    // TODO: What to do with variations?
    val newRelationship1 = athenaFactory.createShortRelationshipDecl(op.spec.name1)
    for (featName : op.spec.features1.features)
    {
      val featToSplit = featsToSplit.findFirst[f | f.name.equals(featName)]
      if (featToSplit !== null)
        aHandler.addFeatureToSchemaType(newRelationship1, EcoreUtil2.copy(featToSplit))
    }

    val newRelationship2 = athenaFactory.createShortRelationshipDecl(op.spec.name2)
    for (featName : op.spec.features2.features)
    {
      val featToSplit = featsToSplit.findFirst[f | f.name.equals(featName)]
      if (featToSplit !== null)
        aHandler.addFeatureToSchemaType(newRelationship2, EcoreUtil2.copy(featToSplit))
    }

    // There should be no references nor aggregates pointing to the original Relationship.
    // But there could be a Reference being featured by the original Relationship.
    EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.contains(sourceRelationship)].forEach[r | r.featuredBy.clear; r.featuredBy.add(newRelationship1)]

    if (aHandler.isSchemaTypeRegular(sourceRelationship))
      EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.exists[featO | aHandler.getVariations(sourceRelationship).contains(featO)]]
        .forEach[r | r.featuredBy.clear; r.featuredBy.add(newRelationship1)]

    schema.relationships.remove(sourceRelationship)
    schema.relationships.add(newRelationship1)
    schema.relationships.add(newRelationship2)
  }

  def dispatch void processOperation(RelationshipExtractOp op)
  {
    validator.validateOperation(this.schema, op)

    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    if (sourceRelationship === null)
      return

    val featsToExtract = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceRelationship).filter(SimpleFeature)

    // Create a new short relationship and clone each of the features to be moved to the extracted relationship
    val newRelationship = athenaFactory.createShortRelationshipDecl(op.spec.name)
    for (featName : op.spec.features.features)
    {
      val featToExtract = featsToExtract.findFirst[f | f.name.equals(featName)]
      if (featToExtract !== null)
        aHandler.addFeatureToSchemaType(newRelationship, EcoreUtil2.copy(featToExtract))
    }

    schema.relationships.add(newRelationship)
  }

  def dispatch void processOperation(RelationshipMergeOp op)
  {
    validator.validateOperation(this.schema, op)
    val sourceRelationship1 = aHandler.getRelationshipDecl(schema, op.spec.ref1)
    val sourceRelationship2 = aHandler.getRelationshipDecl(schema, op.spec.ref2)

    if (sourceRelationship1 === null || sourceRelationship2 === null)
      return

    val newRelationship = athenaFactory.createShortRelationshipDecl(op.spec.name)
    schema.relationships.add(newRelationship)

    // For each feature of the merged relationships, move the first occurrence to the new merged Relationship
    for (feat : (aHandler.getFeaturesInSchemaTypeAndVariations(sourceRelationship1) + aHandler.getFeaturesInSchemaTypeAndVariations(sourceRelationship2)).filter(SimpleFeature))
      if (aHandler.getSimpleFeatureInSchemaType(newRelationship, feat.name) === null)
        aHandler.addFeatureToSchemaType(newRelationship, EcoreUtil2.copy(feat))

    // For each Reference, if it is featured by the Relationship or one of its variations, redirect that reference to the new merged relationship
    EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.contains(sourceRelationship1) || r.featuredBy.contains(sourceRelationship2)].forEach[r | r.featuredBy.clear; r.featuredBy.add(newRelationship)]

    if (aHandler.isSchemaTypeRegular(sourceRelationship1))
      EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.exists[feat0 | aHandler.getVariations(sourceRelationship1).contains(feat0)]].forEach[r | r.featuredBy.clear; r.featuredBy.add(newRelationship)]

    if (aHandler.isSchemaTypeRegular(sourceRelationship2))
      EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.exists[feat0 | aHandler.getVariations(sourceRelationship2).contains(feat0)]].forEach[r | r.featuredBy.clear; r.featuredBy.add(newRelationship)]

    // Remove merging relationships
    schema.relationships.remove(sourceRelationship1)
    schema.relationships.remove(sourceRelationship2)
  }

  def dispatch void processOperation(RelationshipDelVarOp op)
  {
    validator.validateOperation(schema, op)
    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    if (sourceRelationship === null || !aHandler.isSchemaTypeRegular(sourceRelationship))
      return;

    val varToRemove = aHandler.getVariations(sourceRelationship).findFirst[v | v.name.equals(op.spec.target)]

    for (ref : EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.contains(varToRemove) && r.featuredBy.size === 1])
    {
      val feat = ref.eContainer() as SimpleFeature
      val varContainer = EcoreUtil2.getContainerOfType(feat, VariationDecl)
      if (varContainer !== null)
        aHandler.removeSimpleFeatureInVariation(varContainer as VariationDecl, feat.name)
      else
        aHandler.removeSimpleFeatureInSchemaType(EcoreUtil2.getContainerOfType(feat, SchemaTypeDecl), feat.name)
    }

    aHandler.getVariations(sourceRelationship).removeIf([v | v === varToRemove])

    // For now we do not recalculate variationIds, so further operations do not fail. However at some point we should. User responsibility?
    /*
    try
    {
      val varId = Integer.parseInt(op.spec.target)
      aHandler.getVariations(sourceRelationship).filter[v | Integer.parseInt(v.name) > varId].forEach[v | v.name = String.valueOf(Integer.parseInt(v.name) - 1)]
    } catch (NumberFormatException e)
    {
      e.printStackTrace()
    }
    */
    // TODO: Should we recalculate common features ?
    //TODO: References FEATURED BY esta variacion
  }

  // Adapt operation at schema level holds the same semantics as DelVar 
  def dispatch void processOperation(RelationshipAdaptOp op)
  {
    validator.validateOperation(schema, op)
    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    if (sourceRelationship === null || !aHandler.isSchemaTypeRegular(sourceRelationship))
      return;

    if (!aHandler.getVariations(sourceRelationship).exists[v | v.name.equals(op.spec.target)])
      return;

    val varToAdapt = aHandler.getVariations(sourceRelationship).findFirst[v | v.name.equals(op.spec.source)] // <= Slightly different to DelVar
    val varAdapted = aHandler.getVariations(sourceRelationship).findFirst[v | v.name.equals(op.spec.target)]

    for (ref : EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.contains(varToAdapt)])
    {
      ref.featuredBy.remove(varToAdapt)
      if (!ref.featuredBy.contains(varAdapted))
        ref.featuredBy.add(varAdapted)
    }

    aHandler.getVariations(sourceRelationship).removeIf([v | v === varToAdapt])

    // For now we do not recalculate variationIds, so further operations do not fail. However at some point we should. User responsibility?
    /*
    try
    {
      val varId = Integer.parseInt(op.spec.source)
      aHandler.getVariations(sourceRelationship).filter[v | Integer.parseInt(v.name) > varId].forEach[v | v.name = String.valueOf(Integer.parseInt(v.name) - 1)]
    } catch (NumberFormatException e)
    {
      e.printStackTrace()
    }
    */
    // TODO: Should we recalculate common features ?
    //TODO: References FEATURED BY esta variacion
  }

  def dispatch void processOperation(RelationshipUnionOp op)
  {
    validator.validateOperation(schema, op)
    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    if (sourceRelationship === null)
      return;

    if (aHandler.isSchemaTypeShort(sourceRelationship))
      aHandler.getFeaturesInSchemaType(sourceRelationship).filter(SimpleFeature).forEach[f | f.optional = false]

    if (aHandler.isSchemaTypeRegular(sourceRelationship))
    {
      val newRelationship = athenaFactory.createRegularRelationshipDecl(sourceRelationship.name)
      newRelationship.variations.add(athenaFactory.createVariationDecl(1))
      aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceRelationship).forEach[f | f instanceof SimpleFeature ? (f as SimpleFeature).optional = false; aHandler.addFeatureToSchemaType(newRelationship, EcoreUtil2.copy(f))]

      // For each Reference, if it is featuredBy the Relationship or one of its variations, redirect that reference to the newly relationship
      EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.contains(sourceRelationship)].forEach[r | r.featuredBy.clear; r.featuredBy.add(newRelationship)]
      EcoreUtil2.getAllContentsOfType(schema, SimpleReferenceTarget).filter[r | r.featuredBy.exists[varO | aHandler.getVariations(sourceRelationship).contains(varO)]]
        .forEach[r | r.featuredBy.clear; r.featuredBy.add(newRelationship)]

      schema.relationships.remove(sourceRelationship)
      schema.relationships.add(newRelationship)
    }
  }

  def dispatch void processOperation(FeatureDeleteOp op)
  {
    validator.validateOperation(schema, op)

    for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector))
      if (aHandler.isSchemaTypeShort(schemaT) || op.spec.selector.variations.empty)
        op.spec.selector.targets.forEach[target | aHandler.removeSimpleFeatureInSchemaType(schemaT, target)]
      else // SchemaT has variations AND variations were specified.
        for (variation : aHandler.getVariations(schemaT).filter[v | op.spec.selector.variations.contains(v.name)])
          op.spec.selector.targets.forEach[target | aHandler.removeSimpleFeatureInVariation(variation, target)]
    // TODO: Should we recalculate common features ?
  }

  def dispatch void processOperation(FeatureRenameOp op)
  {
    validator.validateOperation(schema, op)

    for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector))
    {
      if (aHandler.isSchemaTypeRegular(schemaT)) // If it is Regular, perform the operation over the variations first.
      {
        val variationsToApply = aHandler.getVariations(schemaT).filter[v | op.spec.selector.variations.empty || op.spec.selector.variations.contains(v.name)]

        for (variation : variationsToApply)
          aHandler.setNameOfSimpleFeatureInVariation(variation, op.spec.selector.target, op.spec.name)
      }

      // Now if it is Short OR there are no variations (thus the operation has to be performed over the Common body of a Regular)
      if (aHandler.isSchemaTypeShort(schemaT) || op.spec.selector.variations.empty)
        aHandler.setNameOfSimpleFeatureInSchemaType(schemaT, op.spec.selector.target, op.spec.name)
    }
  }

  def dispatch void processOperation(FeatureCopyOp op)
  {
    validator.validateOperation(schema, op)

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.sourceSelector.ref)
    val targetSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.targetSelector.ref)
    val featToCopy = aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.sourceSelector.target)

    if (featToCopy === null)
      return;

    if (aHandler.isSchemaTypeShort(targetSchemaT) || op.spec.targetSelector.variations.empty) // Just copy the feature to each Entity
    {
      val newFeatToCopy = EcoreUtil2.copy(featToCopy)
      newFeatToCopy.name = op.spec.targetSelector.target

      aHandler.addFeatureToSchemaType(targetSchemaT, newFeatToCopy)
    }
    else
    {
      for (v : aHandler.getVariations(targetSchemaT).filter[v | op.spec.targetSelector.variations.contains(v.name)])
      {
        val newFeatToCopy = EcoreUtil2.copy(featToCopy)
        newFeatToCopy.name = op.spec.targetSelector.target

        aHandler.getFeaturesInVariation(v).add(newFeatToCopy)
      }
    }
  }

  def dispatch void processOperation(FeatureMoveOp op)
  {
    validator.validateOperation(schema, op)

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.sourceSelector.ref)
    val targetSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.targetSelector.ref)
    val featToMove = aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.sourceSelector.target)

    if (featToMove === null)
      return;

    if (aHandler.isSchemaTypeShort(targetSchemaT) || op.spec.targetSelector.variations.empty) // Just copy the feature to each Entity
    {
      val newFeatToMove = EcoreUtil2.copy(featToMove)
      newFeatToMove.name = op.spec.targetSelector.target

      aHandler.addFeatureToSchemaType(targetSchemaT, newFeatToMove)
    }
    else
    {
      for (v : aHandler.getVariations(targetSchemaT).filter[v | op.spec.targetSelector.variations.contains(v.name)])
      {
        val newFeatToMove = EcoreUtil2.copy(featToMove)
        newFeatToMove.name = op.spec.targetSelector.target

        aHandler.getFeaturesInVariation(v).add(newFeatToMove)
      }
    }

    aHandler.removeSimpleFeatureInSchemaType(sourceSchemaT, featToMove.name)
  }

  def dispatch void processOperation(FeatureNestOp op)
  {
    validator.validateOperation(schema, op)

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    // TODO: We might consider that op.spec.name is actually the field where the nest has to be created, instead of the Aggregate entity.
    // Look for the target Aggregated entity. If it does not exist, create a new one.
    val nestEntityName = op.spec.name.toFirstUpper
    var nestEntity = aHandler.getEntityDecl(schema, nestEntityName)
    if (nestEntity === null)
    {
      nestEntity = athenaFactory.createShortEntityDecl(nestEntityName, false)
      schema.entities.add(nestEntity)
    }

    // First move features to the nest
    for (featName : op.spec.selector.targets)
    {
      val feat = aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, featName)
      if (feat !== null)
      {
        aHandler.addFeatureToSchemaType(nestEntity, feat)
        aHandler.removeSimpleFeatureInSchemaType(sourceSchemaT, featName)
      }
    }

    // Now create an aggregate pointing to the nest
    if (aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.name) === null)
      aHandler.addFeatureToSchemaType(sourceSchemaT, athenaFactory.createSimpleFeature(op.spec.name.toFirstLower, athenaFactory.createSimpleAggr(nestEntity, "&")))
  }

  def dispatch void processOperation(FeatureUnnestOp op)
  {
    //validator.validateOperation(schema, op)

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    for (String featToUnnest : op.spec.selector.targets)
    {
      val aggrToUnnest = featToUnnest.substring(0, featToUnnest.indexOf("."))
      val nameToUnnest = featToUnnest.substring(featToUnnest.indexOf(".") + 1)
      val featAggr = aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, aggrToUnnest)

      if (featAggr !== null)
      {
        val aggrTarget = (featAggr.type as SimpleAggregateTarget).aggr.head

        // Get the feature to unnest, move it to its new location and remove it from its previous location
        if (aggrTarget instanceof EntityDecl)
        {
          val featInAggr = aHandler.getSimpleFeatureInSchemaType(aggrTarget, nameToUnnest)
          if (featInAggr !== null)
          {
            aHandler.removeSimpleFeatureInSchemaType(aggrTarget, nameToUnnest)
            aHandler.addFeatureToSchemaType(sourceSchemaT, featInAggr)
          }
        }
        else // Aggregate points to a Variation
        {
          val featInAggr = aHandler.getFeaturesInVariation(aggrTarget as VariationDecl).filter(SimpleFeature).findFirst[f | f.name.equals(nameToUnnest)]
          if (featInAggr !== null)
          {
            aHandler.removeSimpleFeatureInVariation(aggrTarget as VariationDecl, nameToUnnest)
            aHandler.addFeatureToSchemaType(sourceSchemaT, featInAggr)
          }
        }
      }
    }
  }

  def dispatch void processOperation(AttributeAddOp op)
  {
    validator.validateOperation(schema, op)

    // If someone tries to do ADD ATTRIBUTE Entity::propAggr.innerAggr {...} => We actually recursively shift it to ADD ATTRIBUTE PropAggr::innerAggr {...}
    if (op.spec.selector.target.contains("."))
      processOperation(orionFactory.createAttributeAddOp(
        orionFactory.createSingleFeatureSelector(
          op.spec.selector.target.substring(0, op.spec.selector.target.indexOf(".")).toFirstUpper,
          op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") + 1)
        ), op.spec.type, op.spec.defaultValue, op.spec.key, op.spec.optional, op.spec.unique))
    else
    {
      val featureModel = processFeature(op.spec.selector.target, op.spec.type, op.spec.defaultValue, op.spec.isKey, op.spec.isOptional, op.spec.unique)
      for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector))
      {
        if (aHandler.isSchemaTypeShort(schemaT) && aHandler.getSimpleFeatureInSchemaType(schemaT, op.spec.selector.target) === null)
          aHandler.addFeatureToSchemaType(schemaT, EcoreUtil2.copy(featureModel))
        else // RegularSchemaType
        {
          if (op.spec.selector.variations.empty && aHandler.getSimpleFeatureInSchemaType(schemaT, op.spec.selector.target) === null)
          {
            aHandler.addFeatureToSchemaType(schemaT, EcoreUtil2.copy(featureModel))

            for (variation : aHandler.getVariations(schemaT))
              aHandler.removeSimpleFeatureInVariation(variation, op.spec.selector.target)
          }
          else // Variations were specified
            for (variation : aHandler.getVariations(schemaT).filter[v | op.spec.selector.variations.contains(v.name) && aHandler.getSimpleFeatureInVariation(v, op.spec.selector.target) === null])
              aHandler.addFeatureToVariation(variation, EcoreUtil2.copy(featureModel))
        }
      }
    }
  }

  def dispatch void processOperation(AttributeCastOp op)
  {
    validator.validateOperation(schema, op)
    processTypeCast(op.spec.selector, op.spec.type)
  }

  def dispatch void processOperation(AttributePromoteOp op)
  {
    validator.validateOperation(schema, op)
    setKeyOperation(op.spec.selector, true)
  }

  def dispatch void processOperation(AttributeDemoteOp op)
  {
    validator.validateOperation(schema, op)
    setKeyOperation(op.spec.selector, false)
  }

  private def void setKeyOperation(MultipleFeatureSelector selector, boolean isKey)
  {
    for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, selector))
    {
      if (aHandler.isSchemaTypeRegular(schemaT)) // If it is Regular, perform the operation over the variations first.
      {
        val variationsToApply = aHandler.getVariations(schemaT).filter[v | selector.variations.empty || selector.variations.contains(v.name)]

        for (variation : variationsToApply)
          selector.targets.forEach[t | aHandler.setKeyOfSimpleFeatureInVariation(variation, t, isKey)]
      }

      // Now if it is Short OR there are no variations (thus the operation has to be performed over the Common body of a Regular)
      if (aHandler.isSchemaTypeShort(schemaT) || selector.variations.empty)
        selector.targets.forEach[t | aHandler.setKeyOfSimpleFeatureInSchemaType(schemaT, t, isKey)]
    }
  }

  def dispatch void processOperation(ReferenceAddOp op)
  {
    validator.validateOperation(schema, op)

    // If someone tries to do ADD REF Entity::propAggr.innerAggr {...} => We actually recursively shift it to ADD REF PropAggr::innerAggr {...}
    if (op.spec.selector.target.contains("."))
      processOperation(orionFactory.createReferenceAddOp(
        orionFactory.createSingleFeatureSelector(
          op.spec.selector.target.substring(0, op.spec.selector.target.indexOf(".")).toFirstUpper,
          op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") + 1)
        ), op.spec.type, op.spec.multiplicity, op.spec.optional, op.spec.ref))
    else
    {
      var SimpleFeature referenceModel = null;

      // A Reference may be defined as usual (pointing to an Entity with a type)
      if (op.spec.type !== null)
        referenceModel = athenaFactory.createSimpleFeature(op.spec.selector.target, athenaFactory.createSimpleRef(aHandler.getEntityDecl(schema, op.spec.ref), op.spec.multiplicity, op.spec.type), op.spec.optional)
      // Or it can be defined as featured by a Relationship / Variation
      else if (op.spec.featuredBy !== null)
      {
        val featRelationship = aHandler.getRelationshipDecl(schema, op.spec.featuredBy)
        if (featRelationship === null)
          return;

        // If variations were not specified or the relationship has no variations, this reference is just featured by Relationship.
        // Else take the variations
        if (op.spec.variations.empty || aHandler.isSchemaTypeShort(featRelationship))
          referenceModel = athenaFactory.createSimpleFeature(op.spec.selector.target, athenaFactory.createSimpleRef(aHandler.getEntityDecl(schema, op.spec.ref), op.spec.multiplicity, featRelationship), op.spec.optional)
        else
        {
          val variationsFeatured = new BasicEList<VariationDecl>()
          variationsFeatured.addAll(op.spec.variations.map[vName | aHandler.getVariations(featRelationship).findFirst[v | v.name.equals(vName)]])
          referenceModel = athenaFactory.createSimpleFeature(op.spec.selector.target, athenaFactory.createSimpleRef(aHandler.getEntityDecl(schema, op.spec.ref), op.spec.multiplicity, variationsFeatured), op.spec.optional)
        }
      }
      // Or it can be defined as featured by a set of features {...}
      else
      {
        val relationshipName = op.spec.selector.target.toFirstUpper
        var featRelationship = aHandler.getRelationshipDecl(schema, relationshipName)
        if (featRelationship === null)
        {
          if (!op.spec.features.empty) // If there are features just add them to a short relationship
            featRelationship = athenaFactory.createShortRelationshipDecl(relationshipName)
          else
          { // If not we can only create an empty regular relationship
            featRelationship = athenaFactory.createRegularRelationshipDecl(relationshipName)
            (featRelationship as RegularRelationshipDecl).variations.add(athenaFactory.createVariationDecl(1))
          }

          schema.relationships.add(featRelationship)
        }

        for (f : op.spec.features)
          aHandler.addFeatureToSchemaType(featRelationship, processFeature(f.name, f.type, f.defaultValue, f.key, f.optional, f.unique))

        referenceModel = athenaFactory.createSimpleFeature(op.spec.selector.target, athenaFactory.createSimpleRef(aHandler.getEntityDecl(schema, op.spec.ref), op.spec.multiplicity, featRelationship), op.spec.optional)
      }

      for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector))
      {
        if (aHandler.isSchemaTypeShort(schemaT) && aHandler.getSimpleFeatureInSchemaType(schemaT, op.spec.selector.target) === null)
          aHandler.addFeatureToSchemaType(schemaT, EcoreUtil2.copy(referenceModel))
        else // RegularSchemaType
        {
          if (op.spec.selector.variations.empty && aHandler.getSimpleFeatureInSchemaType(schemaT, op.spec.selector.target) === null)
          {
            aHandler.addFeatureToSchemaType(schemaT, EcoreUtil2.copy(referenceModel))

            for (variation : aHandler.getVariations(schemaT))
              aHandler.removeSimpleFeatureInVariation(variation, op.spec.selector.target)
          }
          else // Variations were specified
            for (variation : aHandler.getVariations(schemaT).filter[v | op.spec.selector.variations.contains(v.name) && aHandler.getSimpleFeatureInVariation(v, op.spec.selector.target) === null])
              aHandler.addFeatureToVariation(variation, EcoreUtil2.copy(referenceModel))
        }
      }
    }
  }

  def dispatch void processOperation(ReferenceCastOp op)
  {
    validator.validateOperation(schema, op)
    processTypeCast(op.spec.selector, op.spec.type)
  }

  def dispatch void processOperation(ReferenceMultiplicityOp op)
  {
    validator.validateOperation(schema, op)
    processMultiplicityChange(op.spec.selector, op.spec.multiplicity)
  }

  def dispatch void processOperation(ReferenceMorphOp op)
  {
    validator.validateOperation(schema, op)

    val feat = OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector)
      .flatMap[e | aHandler.getFeaturesInSchemaTypeAndVariations(e)]
      .filter(SimpleFeature)
      .findFirst[f | f.name.equals(op.spec.selector.target) && f.type instanceof SimpleReferenceTarget]

    if (feat !== null)
    {
      val reference = feat.type as SimpleReferenceTarget
      val newAggregate = athenaFactory.createSimpleAggr(reference.ref, reference.multiplicity)
      reference.ref.root = false

      if (op.spec.deleteId) // Remove ids
      {
        while (aHandler.getKeyInSchemaType(reference.ref) !== null)
          aHandler.setKeyOfSimpleFeatureInSchemaType(reference.ref, aHandler.getKeyInSchemaType(reference.ref).name, false)
      }

      for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector))
      {
        if (aHandler.isSchemaTypeRegular(schemaT)) // If it is Regular, perform the operation over the variations first.
        {
          val variationsToApply = aHandler.getVariations(schemaT).filter[v | op.spec.selector.variations.empty || op.spec.selector.variations.contains(v.name)]

          for (variation : variationsToApply)
          {
            aHandler.setTypeOfSimpleFeatureInVariation(variation, op.spec.selector.target, EcoreUtil2.copy(newAggregate))
            aHandler.setNameOfSimpleFeatureInVariation(variation, op.spec.selector.target, op.spec.name)
          }
        }

        // Now if it is Short OR there are no variations (thus the operation has to be performed over the Common body of a Regular)
        if (aHandler.isSchemaTypeShort(schemaT) || op.spec.selector.variations.empty)
        {
          aHandler.setTypeOfSimpleFeatureInSchemaType(schemaT, op.spec.selector.target, EcoreUtil2.copy(newAggregate))
          aHandler.setNameOfSimpleFeatureInSchemaType(schemaT, op.spec.selector.target, op.spec.name)
        }
      }
    }
  }

  def dispatch void processOperation(AggregateAddOp op)
  {
    validator.validateOperation(schema, op)

    // If someone tries to do ADD AGGR Entity::propAggr.innerAggr {...} => We actually recursively shift it to ADD AGGR PropAggr::innerAggr {...}
    if (op.spec.selector.target.contains("."))
    {
      processOperation(orionFactory.createAggregateAddOp(
        orionFactory.createSingleFeatureSelector(
          op.spec.selector.target.substring(0, op.spec.selector.target.indexOf(".")).toFirstUpper,
          op.spec.selector.target.substring(op.spec.selector.target.indexOf(".") + 1)
        ), op.spec.features, op.spec.multiplicity, op.spec.optional, op.spec.name))
    }
    else
    {
      val entityName = op.spec.name !== null ? op.spec.name : op.spec.selector.target.toFirstUpper
      var aggregateEntity = aHandler.getEntityDecl(schema, entityName)
      if (aggregateEntity === null)
      {
        aggregateEntity = athenaFactory.createShortEntityDecl(entityName, false)
        schema.entities.add(aggregateEntity)
      }
      val aggregateModel = athenaFactory.createSimpleFeature(op.spec.selector.target, athenaFactory.createSimpleAggr(aggregateEntity, op.spec.multiplicity), op.spec.optional)

      for (f : op.spec.features)
        aHandler.addFeatureToSchemaType(aggregateEntity, processFeature(f.name, f.type, f.defaultValue, f.key, f.optional, f.unique))
  
      for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector))
      {
        if (aHandler.isSchemaTypeShort(schemaT) && aHandler.getSimpleFeatureInSchemaType(schemaT, op.spec.selector.target) === null)
          aHandler.addFeatureToSchemaType(schemaT, EcoreUtil2.copy(aggregateModel))
        else // RegularSchemaType
        {
          if (op.spec.selector.variations.empty && aHandler.getSimpleFeatureInSchemaType(schemaT, op.spec.selector.target) === null)
          {
            aHandler.addFeatureToSchemaType(schemaT, EcoreUtil2.copy(aggregateModel))

            for (variation : aHandler.getVariations(schemaT))
              aHandler.removeSimpleFeatureInVariation(variation, op.spec.selector.target)
          }
          else // Variations were specified
            for (variation : aHandler.getVariations(schemaT).filter[v | op.spec.selector.variations.contains(v.name) && aHandler.getSimpleFeatureInVariation(v, op.spec.selector.target) === null])
              aHandler.addFeatureToVariation(variation, EcoreUtil2.copy(aggregateModel))
        }
      }
    }
  }

  def dispatch void processOperation(AggregateMultiplicityOp op)
  {
    validator.validateOperation(schema, op)
    processMultiplicityChange(op.spec.selector, op.spec.multiplicity)
  }

  def dispatch void processOperation(AggregateMorphOp op)
  {
    validator.validateOperation(schema, op)

    val feat = OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector)
      .flatMap[e | aHandler.getFeaturesInSchemaTypeAndVariations(e)]
      .filter(SimpleFeature)
      .findFirst[f | f.name.equals(op.spec.selector.target) && f.type instanceof SimpleAggregateTarget]

    if (feat !== null)
    {
      val aggregate = feat.type as SimpleAggregateTarget
      val aggregatedEntity = aHandler.getEntityDecl(schema, aHandler.getSimpleAggregateTargetName(aggregate))
      aggregatedEntity.root = true

      if (aHandler.getKeyInSchemaType(aggregatedEntity) === null)
      {
        val key = athenaFactory.createSimpleFeature("id", athenaFactory.createUnrestrictedPrimitiveType("Identifier"))
        key.key = true
        aHandler.addFeatureToSchemaType(aggregatedEntity, key)
      }

      val newReference = athenaFactory.createSimpleRef(aggregatedEntity, aggregate.multiplicity, aHandler.getKeyInSchemaType(aggregatedEntity).type as SinglePrimitiveType)

      for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, op.spec.selector))
      {
        if (aHandler.isSchemaTypeRegular(schemaT)) // If it is Regular, perform the operation over the variations first.
        {
          val variationsToApply = aHandler.getVariations(schemaT).filter[v | op.spec.selector.variations.empty || op.spec.selector.variations.contains(v.name)]

          for (variation : variationsToApply)
          {
            aHandler.setTypeOfSimpleFeatureInVariation(variation, op.spec.selector.target, EcoreUtil2.copy(newReference))
            aHandler.setNameOfSimpleFeatureInVariation(variation, op.spec.selector.target, op.spec.name)
          }
        }

        // Now if it is Short OR there are no variations (thus the operation has to be performed over the Common body of a Regular)
        if (aHandler.isSchemaTypeShort(schemaT) || op.spec.selector.variations.empty)
        {
          aHandler.setTypeOfSimpleFeatureInSchemaType(schemaT, op.spec.selector.target, EcoreUtil2.copy(newReference))
          aHandler.setNameOfSimpleFeatureInSchemaType(schemaT, op.spec.selector.target, op.spec.name)
        }
      }
    }
  }

  private def SimpleFeature processFeature(SimpleDataFeature feature)
  {
    return processFeature(feature.name, feature.type, feature.defaultValue, feature.isKey, feature.optional, feature.unique)
  }

  private def SimpleFeature processFeature(String name, DataType type, String value, boolean isKey, boolean isOptional, boolean isUnique)
  {
    if (name.contains(".")) // It is an aggregate.
    {
      val entityName = name.substring(0, name.indexOf(".")).toFirstUpper
      val featName = name.substring(name.indexOf(".") + 1)
      var entity = aHandler.getEntityDecl(schema, entityName)

      if (entity === null)
      {
        entity = athenaFactory.createShortEntityDecl(entityName, false)
        schema.entities.add(entity)
      }

      aHandler.addFeatureToSchemaType(entity, processFeature(featName, type, value, isKey, isOptional, isUnique))

      return athenaFactory.createSimpleFeature(name.substring(0, name.indexOf(".")), athenaFactory.createSimpleAggr(entity, "&"), isOptional)
    }
    else
    {
      val result = type === null ? athenaFactory.createSimpleFeature(name) : athenaFactory.createSimpleFeature(name, type, isOptional)
      result.key = isKey
      result.unique = isUnique
      result.optional = isOptional
      // Athena does not hold default values

      return result
    }
  }

  private def void processTypeCast(MultipleFeatureSelector selector, PrimitiveType type)
  {
    for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, selector))
    {
      if (aHandler.isSchemaTypeRegular(schemaT)) // If it is Regular, perform the operation over the variations first.
      {
        val variationsToApply = aHandler.getVariations(schemaT).filter[v | selector.variations.empty || selector.variations.contains(v.name)]
      
        for (variation : variationsToApply)
          selector.targets.forEach[t | aHandler.setTypeOfSimpleFeatureInVariation(variation, t, type)]
      }

      // Now if it is Short OR there are no variations (thus the operation has to be performed over the Common body of a Regular)
      if (aHandler.isSchemaTypeShort(schemaT) || selector.variations.empty)
        selector.targets.forEach[t | aHandler.setTypeOfSimpleFeatureInSchemaType(schemaT, t, type)]
    }
  }

  def void processMultiplicityChange(MultipleFeatureSelector selector, String mutiplicity)
  {
    for (schemaT : OrionUtils.getSchemaTypesFromSelector(schema, selector))
    {
      if (aHandler.isSchemaTypeRegular(schemaT)) // If it is Regular, perform the operation over the variations first.
      {
        val variationsToApply = aHandler.getVariations(schemaT).filter[v | selector.variations.empty || selector.variations.contains(v.name)]

        for (variation : variationsToApply)
          selector.targets.forEach[t | aHandler.setMultiplicityOfSimpleFeatureInVariation(variation, t, mutiplicity)]
      }

      // Now if it is Short OR there are no variations (thus the operation has to be performed over the Common body of a Regular)
      if (aHandler.isSchemaTypeShort(schemaT) || selector.variations.empty)
        selector.targets.forEach[t | aHandler.setMultiplicityOfSimpleFeatureInSchemaType(schemaT, t, mutiplicity)]
    }
  }
}
