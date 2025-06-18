package es.um.uschema.xtext.orion.utils

import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import java.util.Arrays
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.orion.orion.FeatureSelector
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.AggregateMultiplicityOp
import es.um.uschema.xtext.orion.orion.AggregateMorphOp
import es.um.uschema.xtext.orion.orion.SchemaTypeOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp

class OrionUtils
{
  static def boolean haveSameSelector(BasicOperation op1, BasicOperation op2)
  {
    if (op1 instanceof SchemaTypeOp || op2 instanceof SchemaTypeOp)
      return false

    return selectorToString(getSelector(op1)).equals(selectorToString(getSelector(op2)))
  }

  static def FeatureSelector getSelector(BasicOperation op)
  {
    var FeatureSelector selector = null
    switch (op)
    {
      case op instanceof FeatureDeleteOp:         selector = (op as FeatureDeleteOp).spec.selector
      case op instanceof FeatureRenameOp:         selector = (op as FeatureRenameOp).spec.selector
      case op instanceof FeatureCopyOp:           selector = (op as FeatureCopyOp).spec.sourceSelector
      case op instanceof FeatureMoveOp:           selector = (op as FeatureMoveOp).spec.sourceSelector
      case op instanceof FeatureNestOp:           selector = (op as FeatureNestOp).spec.selector
      case op instanceof FeatureUnnestOp:         selector = (op as FeatureUnnestOp).spec.selector
      case op instanceof AttributeAddOp:          selector = (op as AttributeAddOp).spec.selector
      case op instanceof AttributeCastOp:         selector = (op as AttributeCastOp).spec.selector
      case op instanceof AttributePromoteOp:      selector = (op as AttributePromoteOp).spec.selector
      case op instanceof AttributeDemoteOp:       selector = (op as AttributeDemoteOp).spec.selector
      case op instanceof ReferenceCastOp:         selector = (op as ReferenceCastOp).spec.selector
      case op instanceof ReferenceAddOp:          selector = (op as ReferenceAddOp).spec.selector
      case op instanceof ReferenceMultiplicityOp: selector = (op as ReferenceMultiplicityOp).spec.selector
      case op instanceof ReferenceMorphOp:        selector = (op as ReferenceMorphOp).spec.selector
      case op instanceof AggregateAddOp:          selector = (op as AggregateAddOp).spec.selector
      case op instanceof AggregateMultiplicityOp: selector = (op as AggregateMultiplicityOp).spec.selector
      case op instanceof AggregateMorphOp:        selector = (op as AggregateMorphOp).spec.selector
    }

    selector
  }

  static def String selectorToString(FeatureSelector selector)
  {
    selector.forAll? '*' : selector.ref
  }

  static def getEvolutionBlock(OrionOperations orion, int index)
  {
    if (!orion.evolBlocks.empty)
      return orion.evolBlocks.findFirst[b | b.name == index]

    return null
  }

  static def getSchemaTypesFromSelector(AthenaSchema schema, FeatureSelector selector)
  {
    if (selector.forAll)
      schema.entities + schema.relationships
    else
    {
      val schemaT = (schema.entities + schema.relationships).findFirst[e | e.name.equals(selector.ref)]
      if (schemaT !== null)
        return Arrays.asList(schemaT)
      else
        return Arrays.asList()
    }
  }
}
