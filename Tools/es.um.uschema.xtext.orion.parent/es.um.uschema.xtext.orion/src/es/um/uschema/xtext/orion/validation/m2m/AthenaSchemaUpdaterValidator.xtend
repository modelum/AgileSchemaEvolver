package es.um.uschema.xtext.orion.validation.m2m

import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.EntityMergeOp
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.orion.orion.RelationshipAddOp
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp
import es.um.uschema.xtext.orion.orion.RelationshipSplitOp
import es.um.uschema.xtext.orion.orion.RelationshipExtractOp
import es.um.uschema.xtext.orion.orion.RelationshipMergeOp
import es.um.uschema.xtext.orion.orion.RelationshipDelVarOp
import es.um.uschema.xtext.orion.orion.RelationshipAdaptOp
import es.um.uschema.xtext.orion.orion.RelationshipUnionOp

class AthenaSchemaUpdaterValidator
{
  Boolean enable_validation
  OrionIO orionIO
  AthenaHandler aHandler

  new(Boolean enable_validation)
  {
    this.enable_validation = enable_validation
    this.orionIO = new OrionIO()
    this.aHandler = new AthenaHandler()
  }

  def void validateOperation(AthenaSchema schema, BasicOperation operation)
  {
    if (enable_validation)
      validateOp(schema, operation)
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityAddOp op)
  {
    if (aHandler.getEntityDecl(schema, op.spec.name) !== null)
      throw new IllegalArgumentException("EntityAddOp> Cannot create an Entity with the same name as an existing entity: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityDeleteOp op)
  {
    if (aHandler.getEntityDecl(schema, op.spec.ref) === null)
      throw new IllegalArgumentException("EntityDeleteOp> Cannot delete an Entity that does not exist: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityRenameOp op)
  {
    if (aHandler.getEntityDecl(schema, op.spec.ref) === null)
          throw new IllegalArgumentException("EntityRenameOp> Cannot rename an Entity that does not exist: " + orionIO.serialize(op))

    if (aHandler.getSchemaTypeDecl(schema, op.spec.name) !== null)
          throw new IllegalArgumentException("EntityRenameOp> Cannot rename to a name that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntitySplitOp op)
  {
    // Check Entity to split exists
    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)
    if (sourceEntity === null)
      throw new IllegalArgumentException("EntitySplitOp> Cannot split an Entity that does not exist: " + orionIO.serialize(op))

    val featsToSplit = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceEntity).filter(SimpleFeature)

    // Check features from the first group exist
    for (featName : op.spec.features1.features)
      if (!featsToSplit.exists[f | f.name.equals(featName)])
        throw new IllegalArgumentException("EntitySplitOp> Cannot split Feature \"" + featName + "\" because it does not exist: " + orionIO.serialize(op))

    // Check features from the second group exist
    for (featName : op.spec.features2.features)
      if (!featsToSplit.exists[f | f.name.equals(featName)])
        throw new IllegalArgumentException("EntitySplitOp> Cannot split Feature \"" + featName + "\" because it does not exist: " + orionIO.serialize(op))

    // Check new entities do not collide with existing schema types
    if (aHandler.getSchemaTypeDecl(schema, op.spec.name1) !== null || aHandler.getSchemaTypeDecl(schema, op.spec.name2) !== null)
      throw new IllegalArgumentException("EntitySplitOp> Cannot split to a Schema Type that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityExtractOp op)
  {
    // Check Entity to extract from
    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)
    if (sourceEntity === null)
      throw new IllegalArgumentException("EntityExtractOp> Cannot extract from an Entity that does not exist: " + orionIO.serialize(op))

    val featsToExtract = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceEntity).filter(SimpleFeature)

    // Check Features to extract do exist
    for (featName : op.spec.features.features)
      if (!featsToExtract.exists[f | f.name.equals(featName)])
        throw new IllegalArgumentException("EntityExtractOp> Cannot extract Feature \"" + featName + "\" because it does not exist: " + orionIO.serialize(op))

    // Exception if the extracted entity name already exist.
    if (aHandler.getSchemaTypeDecl(schema, op.spec.name) !== null)
      throw new IllegalArgumentException("EntityExtractOp> Cannot extract to a Schema Type that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityMergeOp op)
  {
    val sourceEntity1 = aHandler.getEntityDecl(schema, op.spec.ref1)
    val sourceEntity2 = aHandler.getEntityDecl(schema, op.spec.ref2)

    // Exception if one of the source entities do not exist, or the merged entity does already exist.
    if (sourceEntity1 === null || sourceEntity2 === null)
      throw new IllegalArgumentException("EntityMergeOp> Cannot merge an Entity because it does not exist: " + orionIO.serialize(op))

    if (aHandler.getSchemaTypeDecl(schema, op.spec.name) !== null)
      throw new IllegalArgumentException("EntityMergeOp> Cannot merge to a Schema Type that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityDelVarOp op)
  {
    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)

    if (sourceEntity === null || !aHandler.isSchemaTypeRegular(sourceEntity))
      throw new IllegalArgumentException("EntityDelVarOp> Cannot delete a variation from an Entity that does not exist or does not have variations: " + orionIO.serialize(op))

    if(!aHandler.getVariations(sourceEntity).exists[v | v.name.equals(op.spec.target)])
      throw new IllegalArgumentException("EntityDelVarOp> Cannot delete a variation that does not exist on the given Entity: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityAdaptOp op)
  {
    val sourceEntity = aHandler.getEntityDecl(schema, op.spec.ref)

    if (sourceEntity === null || !aHandler.isSchemaTypeRegular(sourceEntity))
      throw new IllegalArgumentException("EntityAdaptOp> Cannot adapt a variation from an Entity that does not exist or does not have variations: " + orionIO.serialize(op))

    if(!aHandler.getVariations(sourceEntity).exists[v | v.name.equals(op.spec.source)])
      throw new IllegalArgumentException("EntityAdaptOp> Cannot adapt a variation that does not exist on the given Entity: " + orionIO.serialize(op))

    if(!aHandler.getVariations(sourceEntity).exists[v | v.name.equals(op.spec.target)])
      throw new IllegalArgumentException("EntityAdaptOp> Cannot adapt to a variation that does not exist on the given Entity: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, EntityUnionOp op)
  {
    if (aHandler.getEntityDecl(schema, op.spec.ref) === null)
      throw new IllegalArgumentException("EntityExtractOp> Cannot union an Entity that does not exist: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipAddOp op)
  {
    if (aHandler.getRelationshipDecl(schema, op.spec.name) !== null)
      throw new IllegalArgumentException("RelationshipAddOp> Cannot create a Relationship with the same name as an existing relationship: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipDeleteOp op)
  {
    if (aHandler.getRelationshipDecl(schema, op.spec.ref) === null)
      throw new IllegalArgumentException("RelationshipDeleteOp> Cannot delete a Relationship that does not exist: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipRenameOp op)
  {
    if (aHandler.getRelationshipDecl(schema, op.spec.ref) === null)
          throw new IllegalArgumentException("RelationshipRenameOp> Cannot rename a Relationship that does not exist: " + orionIO.serialize(op))

    if (aHandler.getSchemaTypeDecl(schema, op.spec.name) !== null)
          throw new IllegalArgumentException("RelationshipRenameOp> Cannot rename to a name that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipSplitOp op)
  {
    // Check Entity to split exists
    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)
    if (sourceRelationship === null)
      throw new IllegalArgumentException("RelationshipSplitOp> Cannot split a Relationship that does not exist: " + orionIO.serialize(op))

    val featsToSplit = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceRelationship).filter(SimpleFeature)

    // Check features from the first group exist
    for (featName : op.spec.features1.features)
      if (!featsToSplit.exists[f | f.name.equals(featName)])
        throw new IllegalArgumentException("RelationshipSplitOp> Cannot split Feature \"" + featName + "\" because it does not exist: " + orionIO.serialize(op))

    // Check features from the second group exist
    for (featName : op.spec.features2.features)
      if (!featsToSplit.exists[f | f.name.equals(featName)])
        throw new IllegalArgumentException("RelationshipSplitOp> Cannot split Feature \"" + featName + "\" because it does not exist: " + orionIO.serialize(op))

    // Check new relationships do not collide with existing relationships
    if (aHandler.getSchemaTypeDecl(schema, op.spec.name1) !== null || aHandler.getSchemaTypeDecl(schema, op.spec.name2) !== null)
      throw new IllegalArgumentException("RelationshipSplitOp> Cannot split to a Schema Type that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipExtractOp op)
  {
    // Check Relationship to extract from
    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)
    if (sourceRelationship === null)
      throw new IllegalArgumentException("RelationshipExtractOp> Cannot extract from a Relationship that does not exist: " + orionIO.serialize(op))

    val featsToExtract = aHandler.getReducedFeaturesInSchemaTypeAndVariations(sourceRelationship).filter(SimpleFeature)

    // Check Features to extract do exist
    for (featName : op.spec.features.features)
      if (!featsToExtract.exists[f | f.name.equals(featName)])
        throw new IllegalArgumentException("RelationshipExtractOp> Cannot extract Feature \"" + featName + "\" because it does not exist: " + orionIO.serialize(op))

    // Exception if the extracted entity name already exist.
    if (aHandler.getSchemaTypeDecl(schema, op.spec.name) !== null)
      throw new IllegalArgumentException("RelationshipExtractOp> Cannot extract to a Schema Type that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipMergeOp op)
  {
    val sourceRelationship1 = aHandler.getRelationshipDecl(schema, op.spec.ref1)
    val sourceRelationship2 = aHandler.getRelationshipDecl(schema, op.spec.ref2)

    // Exception if one of the source relationships do not exist, or the merged relationship does already exist.
    if (sourceRelationship1 === null || sourceRelationship2 === null)
      throw new IllegalArgumentException("RelationshipMergeOp> Cannot merge a Relationship because it does not exist: " + orionIO.serialize(op))

    if (aHandler.getSchemaTypeDecl(schema, op.spec.name) !== null)
      throw new IllegalArgumentException("RelationshipMergeOp> Cannot merge to a Schema Type that already exists: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipDelVarOp op)
  {
    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    if (sourceRelationship === null || !aHandler.isSchemaTypeRegular(sourceRelationship))
      throw new IllegalArgumentException("RelationshipDelVarOp> Cannot delete a variation from a Relationship that does not exist or does not have variations: " + orionIO.serialize(op))

    if(!aHandler.getVariations(sourceRelationship).exists[v | v.name.equals(op.spec.target)])
      throw new IllegalArgumentException("RelationshipDelVarOp> Cannot delete a variation that does not exist on the given Relationship: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipAdaptOp op)
  {
    val sourceRelationship = aHandler.getRelationshipDecl(schema, op.spec.ref)

    if (sourceRelationship === null || !aHandler.isSchemaTypeRegular(sourceRelationship))
      throw new IllegalArgumentException("RelationshipAdaptOp> Cannot adapt a variation from a Relationship that does not exist or does not have variations: " + orionIO.serialize(op))

    if(!aHandler.getVariations(sourceRelationship).exists[v | v.name.equals(op.spec.source)])
      throw new IllegalArgumentException("RelationshipDelVarOp> Cannot adapt a variation that does not exist on the given Relationship: " + orionIO.serialize(op))

    if(!aHandler.getVariations(sourceRelationship).exists[v | v.name.equals(op.spec.target)])
      throw new IllegalArgumentException("RelationshipDelVarOp> Cannot adapt to a variation that does not exist on the given Relationship: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, RelationshipUnionOp op)
  {
    if (aHandler.getRelationshipDecl(schema, op.spec.ref) === null)
      throw new IllegalArgumentException("RelationshipExtractOp> Cannot union a Relationship that does not exist: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, FeatureDeleteOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("FeatureDeleteOp> Cannot delete features of a Schema Type that does not exist: " + orionIO.serialize(op))

    // If it is a short entity we just check the feature exists
    if ((aHandler.isSchemaTypeShort(sourceSchemaT) || (aHandler.isSchemaTypeRegular(sourceSchemaT) && op.spec.selector.variations.empty))
      && op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("FeatureDeleteOp> Cannot delete features of a Schema Type that does not exist: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, FeatureRenameOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("FeatureRenameOp> Cannot rename features of a Schema Type that does not exist: " + orionIO.serialize(op))

    // If no variations were given we just check the feature exists
    if (op.spec.selector.variations.empty && aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.selector.target) === null)
      throw new IllegalArgumentException("FeatureRenameOp> Cannot rename features of a Schema Type that does not exist: " + orionIO.serialize(op))

    if (aHandler.getFeaturesInSchemaTypeAndVariations(sourceSchemaT).exists[f | f instanceof SimpleFeature && (f as SimpleFeature).name.equals(op.spec.name)])
      throw new IllegalArgumentException("FeatureRenameOp> Cannot rename features to an already existing name: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, FeatureCopyOp op)
  {
    if (op.spec.sourceSelector.forAll || op.spec.targetSelector.forAll)
      throw new IllegalArgumentException("FeatureCopyOp> ForAll is not allowed here: " + orionIO.serialize(op))

    if (!op.spec.sourceSelector.variations.empty)
      throw new IllegalArgumentException("FeatureCopyOp> Variations cannot be selected on source Entity: " + orionIO.serialize(op))

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.sourceSelector.ref)
    if (sourceSchemaT === null)
      throw new IllegalArgumentException("FeatureCopyOp> Cannot find source Schema Type: " + orionIO.serialize(op))

    if (op.spec.sourceSelector.variations.empty && aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.sourceSelector.target) === null)
      throw new IllegalArgumentException("FeatureCopyOp> Cannot find source Feature: " + orionIO.serialize(op))

    val targetSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.targetSelector.ref)
    if (targetSchemaT === null)
      throw new IllegalArgumentException("FeatureCopyOp> Cannot find target Schema Type: " + orionIO.serialize(op))

    if (aHandler.getFeaturesInSchemaTypeAndVariations(targetSchemaT).exists[f | f instanceof SimpleFeature && (f as SimpleFeature).name.equals(op.spec.targetSelector.target)])
      throw new IllegalArgumentException("FeatureCopyOp> Cannot copy features when they already exist on target: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, FeatureMoveOp op)
  {
    if (op.spec.sourceSelector.forAll || op.spec.targetSelector.forAll)
      throw new IllegalArgumentException("FeatureMoveOp> ForAll is not allowed here: " + orionIO.serialize(op))

    if (!op.spec.sourceSelector.variations.empty)
      throw new IllegalArgumentException("FeatureMoveOp> Variations cannot be selected on source Entity: " + orionIO.serialize(op))

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.sourceSelector.ref)
    if (sourceSchemaT === null)
      throw new IllegalArgumentException("FeatureMoveOp> Cannot find source Entity: " + orionIO.serialize(op))

    if (op.spec.sourceSelector.variations.empty && aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.sourceSelector.target) === null)
      throw new IllegalArgumentException("FeatureMoveOp> Cannot find source Feature: " + orionIO.serialize(op))

    val targetSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.targetSelector.ref)
    if (targetSchemaT === null)
      throw new IllegalArgumentException("FeatureMoveOp> Cannot find target Schema Type: " + orionIO.serialize(op))

    if (aHandler.getFeaturesInSchemaTypeAndVariations(targetSchemaT).exists[f | f instanceof SimpleFeature && (f as SimpleFeature).name.equals(op.spec.targetSelector.target)])
      throw new IllegalArgumentException("FeatureMoveOp> Cannot move features when they already exist on target: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, FeatureNestOp op)
  {
    if (op.spec.selector.forAll)
      throw new IllegalArgumentException("FeatureNestOp> ForAll is not allowed here: " + orionIO.serialize(op))

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("FeatureNestOp> Cannot nest Features of an Schema Type that does not exist: " + orionIO.serialize(op))

    if (op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("FeatureNestOp> Cannot find all Features to nest: " + orionIO.serialize(op))

    // TODO: We do not allow variations on this operation because it shows some problems at schema level.
    if (!op.spec.selector.variations.empty)
      throw new IllegalArgumentException("FeatureNestOp> Variations are not allowed here: " + orionIO.serialize(op))
    //if (!aHandler.getSimpleFeatureInSchemaType(sourceEntity, op.spec.name).empty)
    //  throw new IllegalArgumentException("FeatureNestOp> Cannot nest Features into an existing field: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, FeatureUnnestOp op)
  {
    if (op.spec.selector.forAll)
      throw new IllegalArgumentException("FeatureUnnestOp> ForAll is not allowed here: " + orionIO.serialize(op))

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("FeatureUnnestOp> Cannot nest Features of a Schema Type that does not exist: " + orionIO.serialize(op))

    if (op.spec.selector.targets.exists[t | !t.contains(".")])
      throw new IllegalArgumentException("FeatureUnnestOp> Features to unnest must use \"dot\" notation: " + orionIO.serialize(op))

    if (!op.spec.selector.variations.empty)
      throw new IllegalArgumentException("FeatureUnnestOp> Variations are not allowed here: " + orionIO.serialize(op))

    // We do not check if there is a field on the Entity with that name.
    // TODO: We do not allow variations on this operation because it shows some problems at schema level.
    for (String featToUnnest : op.spec.selector.targets)
    {
      val aggrToUnnest = featToUnnest.substring(0, featToUnnest.indexOf("."))
      val featAggr = aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, aggrToUnnest)

      if (featAggr === null || !(featAggr.type instanceof SimpleAggregateTarget))
        throw new IllegalArgumentException("FeatureUnnestOp> Cannot find Aggregate " + aggrToUnnest + ": " + orionIO.serialize(op))

      if (!(featAggr.type as SimpleAggregateTarget).multiplicity.equals("?") && !(featAggr.type as SimpleAggregateTarget).multiplicity.equals("&"))
        throw new IllegalArgumentException("FeatureUnnestOp> Cannot unnest a ..* Aggregate: " + orionIO.serialize(op))
    }
  }

  private def dispatch void validateOp(AthenaSchema schema, AttributeAddOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("AttributeAddOp> Cannot create features of a Schema Type that does not exist: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, AttributeCastOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("AttributeCastOp> Cannot cast Attributes on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If it is a short schema type we just check the feature exists
    if ((aHandler.isSchemaTypeShort(sourceSchemaT) || (aHandler.isSchemaTypeRegular(sourceSchemaT) && op.spec.selector.variations.empty))
      && op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("AttributeCastOp> Cannot find Attributes to cast: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, AttributePromoteOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("AttributePromoteOp> Cannot promote Attributes on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If it is a short schema type we just check the feature exists
    if ((aHandler.isSchemaTypeShort(sourceSchemaT) || (aHandler.isSchemaTypeRegular(sourceSchemaT) && op.spec.selector.variations.empty))
      && op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("AttributePromoteOp> Cannot find Attributes to promote: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, AttributeDemoteOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("AttributeDemoteOp> Cannot demote Attributes on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If it is a short entity we just check the feature exists
    if ((aHandler.isSchemaTypeShort(sourceSchemaT) || (aHandler.isSchemaTypeRegular(sourceSchemaT) && op.spec.selector.variations.empty))
      && op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("AttributeDemoteOp> Cannot find Attributes to demote: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, ReferenceAddOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("ReferenceAddOp> Cannot create features of a Schema Type that does not exist: " + orionIO.serialize(op))

    if (op.spec.featuredBy !== null && aHandler.getRelationshipDecl(schema, op.spec.featuredBy) === null)
      throw new IllegalArgumentException("ReferenceAddOp> Cannot create a reference featured by a Relationship that does not exist: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, ReferenceCastOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("ReferenceCastOp> Cannot cast References on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If it is a short schema type we just check the feature exists
    if ((aHandler.isSchemaTypeShort(sourceSchemaT) || (aHandler.isSchemaTypeRegular(sourceSchemaT) && op.spec.selector.variations.empty))
      && op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("ReferenceCastOp> Cannot find References to cast: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, ReferenceMultiplicityOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("ReferenceMultiplicityOp> Cannot change multiplicity on References on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If it is a short schema type we just check the feature exists
    if ((aHandler.isSchemaTypeShort(sourceSchemaT) || (aHandler.isSchemaTypeRegular(sourceSchemaT) && op.spec.selector.variations.empty))
      && op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("ReferenceCastOp> Cannot find References to change multiplicity: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, ReferenceMorphOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("ReferenceMorphOp> Cannot morph References on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If no variations were given we just check the feature exists
    if (op.spec.selector.variations.empty && aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.selector.target) === null)
      throw new IllegalArgumentException("ReferenceMorphOp> Cannot find a Reference to morph: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, AggregateAddOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("AggregateAddOp> Cannot create features of an Entity that does not exist: " + orionIO.serialize(op))
  }

  private def dispatch void validateOp(AthenaSchema schema, AggregateMultiplicityOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("AggregateMultiplicityOp> Cannot change multiplicity on Aggregates on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If it is a short entity we just check the feature exists
    if ((aHandler.isSchemaTypeShort(sourceSchemaT) || (aHandler.isSchemaTypeRegular(sourceSchemaT) && op.spec.selector.variations.empty))
      && op.spec.selector.targets.exists[t | aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, t) === null])
      throw new IllegalArgumentException("ReferenceCastOp> Cannot find Aggregate to change multiplicity: " + orionIO.serialize(op))

    // If variations were defined we will not check if the feature does exist for all variations.
  }

  private def dispatch void validateOp(AthenaSchema schema, AggregateMorphOp op)
  {
    if (op.spec.selector.forAll)
      return

    val sourceSchemaT = aHandler.getSchemaTypeDecl(schema, op.spec.selector.ref)

    if (sourceSchemaT === null)
      throw new IllegalArgumentException("AggregateMorphOp> Cannot morph Aggregates on a Schema Type that does not exist: " + orionIO.serialize(op))

    // If no variations were given we just check the feature exists
    if (op.spec.selector.variations.empty && aHandler.getSimpleFeatureInSchemaType(sourceSchemaT, op.spec.selector.target) === null)
      throw new IllegalArgumentException("AggregateMorphOp> Cannot find an Aggregate to morph: " + orionIO.serialize(op))
  }
}
