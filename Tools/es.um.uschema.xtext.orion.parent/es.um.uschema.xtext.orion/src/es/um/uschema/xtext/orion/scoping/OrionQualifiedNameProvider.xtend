package es.um.uschema.xtext.orion.scoping

import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import es.um.uschema.xtext.orion.orion.SingleFeatureSelector
import es.um.uschema.xtext.orion.orion.MultipleFeatureSelector
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.EntityMergeOp
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.orion.orion.RelationshipAddOp
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp
import es.um.uschema.xtext.orion.orion.RelationshipExtractOp
import es.um.uschema.xtext.orion.orion.RelationshipAdaptOp
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp
import es.um.uschema.xtext.orion.orion.RelationshipSplitOp
import es.um.uschema.xtext.orion.orion.RelationshipDelVarOp
import es.um.uschema.xtext.orion.orion.RelationshipMergeOp
import es.um.uschema.xtext.orion.orion.RelationshipUnionOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.orion.orion.AggregateAddOp

// We created a unique serialization of each operation in order to check duplicity.
class OrionQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider
{
  def QualifiedName qualifiedName(EntityAddOp op)             { return QualifiedName.create("EntityAddOp", op.spec.name)}
  def QualifiedName qualifiedName(EntityDeleteOp op)          { return QualifiedName.create("EntityDeleteOp", op.spec.ref)}
  def QualifiedName qualifiedName(EntityRenameOp op)          { return QualifiedName.create("EntityRenameOp", op.spec.ref, op.spec.name)}
  def QualifiedName qualifiedName(EntitySplitOp op)           { return QualifiedName.create("EntitySplitOp", op.spec.ref, op.spec.name1, op.spec.name2)}
  def QualifiedName qualifiedName(EntityExtractOp op)         { return QualifiedName.create("EntityExtractOp", op.spec.ref, op.spec.name)}
  def QualifiedName qualifiedName(EntityMergeOp op)           { return QualifiedName.create("EntityMergeOp", op.spec.ref1, op.spec.ref2, op.spec.name)}
  def QualifiedName qualifiedName(EntityDelVarOp op)          { return QualifiedName.create("EntityMergeOp", op.spec.ref, op.spec.target)}
  def QualifiedName qualifiedName(EntityAdaptOp op)           { return QualifiedName.create("EntityAdaptOp", op.spec.ref, op.spec.source, op.spec.target)}
  def QualifiedName qualifiedName(EntityUnionOp op)           { return QualifiedName.create("EntityUnionOp", op.spec.ref)}
  def QualifiedName qualifiedName(RelationshipAddOp op)       { return QualifiedName.create("RelationshipAddOp", op.spec.name)}
  def QualifiedName qualifiedName(RelationshipDeleteOp op)    { return QualifiedName.create("RelationshipDeleteOp", op.spec.ref)}
  def QualifiedName qualifiedName(RelationshipRenameOp op)    { return QualifiedName.create("RelationshipRenameOp", op.spec.ref, op.spec.name)}
  def QualifiedName qualifiedName(RelationshipSplitOp op)     { return QualifiedName.create("RelationshipSplitOp", op.spec.ref, op.spec.name1, op.spec.name2)}
  def QualifiedName qualifiedName(RelationshipExtractOp op)   { return QualifiedName.create("RelationshipExtractOp", op.spec.ref, op.spec.name)}
  def QualifiedName qualifiedName(RelationshipMergeOp op)     { return QualifiedName.create("RelationshipMergeOp", op.spec.ref1, op.spec.ref2, op.spec.name)}
  def QualifiedName qualifiedName(RelationshipDelVarOp op)    { return QualifiedName.create("RelationshipDelVarOp", op.spec.ref, op.spec.target)}
  def QualifiedName qualifiedName(RelationshipAdaptOp op)     { return QualifiedName.create("RelationshipAdaptOp", op.spec.ref, op.spec.source, op.spec.target)}
  def QualifiedName qualifiedName(RelationshipUnionOp op)     { return QualifiedName.create("RelationshipUnionOp", op.spec.ref)}
  def QualifiedName qualifiedName(FeatureDeleteOp op)         { return QualifiedName.create("FeatureDeleteOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(FeatureRenameOp op)         { return QualifiedName.create("FeatureRenameOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(FeatureCopyOp op)           { return QualifiedName.create("FeatureCopyOp", getCustomQualifiedName(op.spec.sourceSelector).toString, qualifiedName(op.spec.targetSelector).toString)}
  def QualifiedName qualifiedName(FeatureMoveOp op)           { return QualifiedName.create("FeatureMoveOp", getCustomQualifiedName(op.spec.sourceSelector).toString, qualifiedName(op.spec.targetSelector).toString)}
  def QualifiedName qualifiedName(FeatureNestOp op)           { return QualifiedName.create("FeatureNestOp", getCustomQualifiedName(op.spec.selector).toString, op.spec.name)}
  def QualifiedName qualifiedName(FeatureUnnestOp op)         { return QualifiedName.create("FeatureUnnestOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(AttributeAddOp op)          { return QualifiedName.create("AttributeAddOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(AttributeCastOp op)         { return QualifiedName.create("AttributeCastOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(AttributePromoteOp op)      { return QualifiedName.create("AttributePromoteOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(AttributeDemoteOp op)       { return QualifiedName.create("AttributeDemoteOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(ReferenceAddOp op)          { return QualifiedName.create("ReferenceAddOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(ReferenceCastOp op)         { return QualifiedName.create("ReferenceCastOp", getCustomQualifiedName(op.spec.selector).toString)}
  def QualifiedName qualifiedName(ReferenceMultiplicityOp op) { return QualifiedName.create("ReferenceMultiplicityOp", getCustomQualifiedName(op.spec.selector).toString, op.spec.multiplicity)}
  def QualifiedName qualifiedName(ReferenceMorphOp op)        { return QualifiedName.create("ReferenceMorphOp", getCustomQualifiedName(op.spec.selector).toString, op.spec.name)}
  def QualifiedName qualifiedName(AggregateAddOp op)          { return QualifiedName.create("AggregateAddSpec", getCustomQualifiedName(op.spec.selector).toString, op.spec.name === null ? "" : op.spec.name) }
  def QualifiedName qualifiedName(AggregateMultiplicityOp op) { return QualifiedName.create("AggregateMultiplicityOp", getCustomQualifiedName(op.spec.selector).toString, op.spec.multiplicity)}
  def QualifiedName qualifiedName(AggregateMorphOp op)        { return QualifiedName.create("AggregateMorphOp", getCustomQualifiedName(op.spec.selector).toString, op.spec.name)}

  def QualifiedName getCustomQualifiedName(SingleFeatureSelector selector)
  {
    return QualifiedName.create(selector.forAll ? "*" : selector.ref, selector.target)
  }

  def QualifiedName getCustomQualifiedName(MultipleFeatureSelector selector)
  {
    return QualifiedName.create(selector.forAll ? "*" : selector.ref, selector.targets.join("."))
  }
}
