package es.um.uschema.xtext.orion.utils.costs

import java.util.List
import es.um.uschema.xtext.orion.orion.BasicOperation
import java.util.Map
import java.util.HashMap
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.EntityDeleteOp
import es.um.uschema.xtext.orion.orion.EntityRenameOp
import es.um.uschema.xtext.orion.orion.EntityExtractOp
import es.um.uschema.xtext.orion.orion.EntitySplitOp
import es.um.uschema.xtext.orion.orion.EntityMergeOp
import es.um.uschema.xtext.orion.orion.EntityDelVarOp
import es.um.uschema.xtext.orion.orion.EntityAdaptOp
import es.um.uschema.xtext.orion.orion.EntityUnionOp
import es.um.uschema.xtext.orion.orion.RelationshipAddOp
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp
import es.um.uschema.xtext.orion.orion.RelationshipExtractOp
import es.um.uschema.xtext.orion.orion.RelationshipSplitOp
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp
import es.um.uschema.xtext.orion.orion.RelationshipDelVarOp
import es.um.uschema.xtext.orion.orion.RelationshipMergeOp
import es.um.uschema.xtext.orion.orion.RelationshipAdaptOp
import es.um.uschema.xtext.orion.orion.RelationshipUnionOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.AttributeCastOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp
import es.um.uschema.xtext.orion.orion.ReferenceCastOp
import es.um.uschema.xtext.orion.orion.AggregateOp
import es.um.uschema.xtext.orion.orion.ReferenceMultiplicityOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp

class Neo4jModelCost
{
  Map<OperationCost, Integer> costMap

  new()
  {
    this.costMap = new HashMap<OperationCost, Integer>

    for (op : OperationCost.values)
      this.costMap.put(op, 0)
  }

  def void addToCosts(List<BasicOperation> operations)
  {
    for (op : operations)
      addToCosts(op)
  }

  def void addToCosts(BasicOperation operation)
  {
    this.costMap.put(getCostFrom(operation), this.costMap.get(getCostFrom(operation)) + 1)
  }

  def Map<OperationCost, Integer> getCostMap()
  {
    return this.costMap
  }

  def String showCostMap()
  {
    val result = new StringBuilder()
    result.append("Neo4j Model cost:\n")

    for (entry : costMap.entrySet.sortBy[e | e.value])
      result.append("  " + entry.key + ": " + entry.value + "\n")

    return result.toString
  }

  private def dispatch OperationCost getCostFrom(FeatureDeleteOp op)         { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(FeatureRenameOp op)         { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(FeatureCopyOp op)           { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(FeatureMoveOp op)           { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(FeatureNestOp op)           { return OperationCost.NOT_IMPLEMENTED_OP    }
  private def dispatch OperationCost getCostFrom(FeatureUnnestOp op)         { return OperationCost.NOT_IMPLEMENTED_OP    }
  private def dispatch OperationCost getCostFrom(AttributeAddOp op)          { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(AttributeCastOp op)         { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(AttributePromoteOp op)      { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(AttributeDemoteOp op)       { return OperationCost.CONSTANT_TIME_OP      }
  private def dispatch OperationCost getCostFrom(ReferenceAddOp op)          { return OperationCost.MULTIPLE_TRAVERSAL_OP }
  private def dispatch OperationCost getCostFrom(ReferenceCastOp op)         { return OperationCost.NOT_IMPLEMENTED_OP    }
  private def dispatch OperationCost getCostFrom(ReferenceMultiplicityOp op) { return OperationCost.NOT_IMPLEMENTED_OP    }
  private def dispatch OperationCost getCostFrom(ReferenceMorphOp op)        { return OperationCost.NOT_IMPLEMENTED_OP    }
  private def dispatch OperationCost getCostFrom(AggregateOp op)             { return OperationCost.NOT_IMPLEMENTED_OP    }
  private def dispatch OperationCost getCostFrom(EntityAddOp op)             { return OperationCost.CONSTANT_TIME_OP      }
  private def dispatch OperationCost getCostFrom(EntityDeleteOp op)          { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(EntityRenameOp op)          { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(EntityExtractOp op)         { return OperationCost.MULTIPLE_TRAVERSAL_OP }
  private def dispatch OperationCost getCostFrom(EntitySplitOp op)           { return OperationCost.MULTIPLE_TRAVERSAL_OP }
  private def dispatch OperationCost getCostFrom(EntityMergeOp op)           { return OperationCost.MULTIPLE_TRAVERSAL_OP }
  private def dispatch OperationCost getCostFrom(EntityDelVarOp op)          { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(EntityAdaptOp op)           { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(EntityUnionOp op)           { return OperationCost.MULTIPLE_TRAVERSAL_OP }
  private def dispatch OperationCost getCostFrom(RelationshipAddOp op)       { return OperationCost.NOT_IMPLEMENTED_OP    }
  private def dispatch OperationCost getCostFrom(RelationshipDeleteOp op)    { return OperationCost.CONSTANT_TIME_OP      }
  private def dispatch OperationCost getCostFrom(RelationshipRenameOp op)    { return OperationCost.MULTIPLE_TRAVERSAL_OP }
  private def dispatch OperationCost getCostFrom(RelationshipExtractOp op)   { return OperationCost.HIGH_COST_OP          }
  private def dispatch OperationCost getCostFrom(RelationshipSplitOp op)     { return OperationCost.HIGH_COST_OP          }
  private def dispatch OperationCost getCostFrom(RelationshipMergeOp op)     { return OperationCost.HIGH_COST_OP          }
  private def dispatch OperationCost getCostFrom(RelationshipDelVarOp op)    { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(RelationshipAdaptOp op)     { return OperationCost.SINGLE_TRAVERSAL_OP   }
  private def dispatch OperationCost getCostFrom(RelationshipUnionOp op)     { return OperationCost.HIGH_COST_OP          }
}
