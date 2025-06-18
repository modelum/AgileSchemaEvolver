package es.um.uschema.xtext.orion.m2t.utils

import es.um.uschema.xtext.orion.orion.EvolBlock
import java.util.List
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.SchemaTypeOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp

class MongoDBTransactionModule
{
  Boolean transactionMode
  Boolean inTransaction

  new(Boolean transactionMode)
  {
    this.transactionMode = transactionMode
    this.inTransaction = false
  }

  def Boolean isTransactional(List<EvolBlock> blocks)
  {
    return transactionMode && blocks.exists[b | isTransactional(b)]
  }

  def Boolean isTransactional(EvolBlock block)
  {
    return transactionMode && block.operations.exists[op | isTransactional(op)]
  }

  def Boolean isTransactional(BasicOperation op)
  {
    if (!transactionMode)
      return false

    switch (op)
    {
      case op instanceof SchemaTypeOp:            false
      case op instanceof ReferenceMorphOp:        false
      case op instanceof AggregateMorphOp:        false
      case op instanceof FeatureDeleteOp:         !(op as FeatureDeleteOp).spec.selector.forAll
      case op instanceof FeatureRenameOp:         !(op as FeatureRenameOp).spec.selector.forAll
      case op instanceof FeatureCopyOp:           !(op as FeatureCopyOp).spec.sourceSelector.forAll
      case op instanceof FeatureMoveOp:           !(op as FeatureMoveOp).spec.sourceSelector.forAll
      case op instanceof FeatureNestOp:           !(op as FeatureNestOp).spec.selector.forAll
      case op instanceof FeatureUnnestOp:         !(op as FeatureUnnestOp).spec.selector.forAll
      case op instanceof AttributeAddOp:          !(op as AttributeAddOp).spec.selector.forAll
      case op instanceof AttributeCastOp:         !(op as AttributeCastOp).spec.selector.forAll
      case op instanceof AttributePromoteOp:      !(op as AttributePromoteOp).spec.selector.forAll
      case op instanceof AttributeDemoteOp:       !(op as AttributeDemoteOp).spec.selector.forAll
      case op instanceof ReferenceCastOp:         !(op as ReferenceCastOp).spec.selector.forAll
      case op instanceof ReferenceAddOp:          !(op as ReferenceAddOp).spec.selector.forAll
      case op instanceof ReferenceMultiplicityOp: !(op as ReferenceMultiplicityOp).spec.selector.forAll
      case op instanceof AggregateAddOp:          !(op as AggregateAddOp).spec.selector.forAll
      case op instanceof AggregateMultiplicityOp: !(op as AggregateMultiplicityOp).spec.selector.forAll
      default:                                    false
    }
  }

  def Boolean inTransaction()
  {
    return inTransaction
  }

  def generateTransactionalBegin(String schemaName)
  '''
    db = db.getMongo().startSession()
    «schemaName» = db.getDatabase("«schemaName»")

  '''

  def generateTransactionBegin()
  '''
    « { inTransaction = true; "" } »
    db.startTransaction()

  '''

  def generateTransactionEnd()
  '''
    « { inTransaction = false; "" } »
    db.commitTransaction()

  '''

  def generateTransactionalEnd()
  '''
    db.endSession()
  '''
}
