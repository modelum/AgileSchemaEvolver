package es.um.uschema.xtext.orion.validation.m2t

import java.util.ArrayList
import es.um.uschema.xtext.orion.orion.EntityAddOp
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp
import es.um.uschema.xtext.orion.orion.AttributeAddOp
import es.um.uschema.xtext.orion.orion.FeatureNestOp
import es.um.uschema.xtext.orion.orion.FeatureMoveOp
import es.um.uschema.xtext.orion.orion.FeatureCopyOp
import es.um.uschema.xtext.orion.orion.FeatureUnnestOp
import es.um.uschema.xtext.orion.orion.ReferenceAddOp
import es.um.uschema.xtext.orion.orion.ReferenceMorphOp
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.orion.utils.OrionFactory
import es.um.uschema.xtext.orion.orion.FeatureRenameOp
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.athena.athena.Null
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.List
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.orion.orion.SimpleDataFeature
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.utils.AthenaHandler
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.orion.orion.AggregateAddOp
import es.um.uschema.xtext.orion.orion.RelationshipOp
import org.eclipse.emf.ecore.EObject

class CassandraValidator
{
  val errorLog = new ArrayList()
  val warningLog = new ArrayList()
  val orionIO = new OrionIO()
  val factory = new OrionFactory()
  val aHandler = new AthenaHandler()

  def getSummary()
  {
    if (!warningLog.empty)
      System.err.println("Some warnings were detected on this Orion file:\n" + warningLog.join("\n"))

    if (!errorLog.empty)
      throw new IllegalArgumentException("Some errors were detected on this Orion file:\n" + errorLog.join("\n"))
  }

  def dispatch checkBasicOperation(AthenaSchema schema, BasicOperation op)
  {
    // This method is used for operations where a validation does not apply...
  }

  def dispatch checkBasicOperation(AthenaSchema schema, EntityAddOp op)
  {
    if (op.spec.features.empty)
      registerErrorMessage("EntityAddOp", "A new Entity should define fields: ", op)
    else
    {
      if (!op.spec.features.exists[f | f.isKey])
        registerErrorMessage("EntityAddOp", "A new Entity should have at least one key field: ", op)

      for(feat : op.spec.features)
        checkSimpleDataFeature(feat)

      if (op.spec.features.exists[f | f.defaultValue !== null] && op.spec.features.exists[f | f.key && f.defaultValue === null])
        registerErrorMessage("EntityAddOp", "When defining an initial value to features, key fields need to be given an initial value too: ", op)
    }
  }

  def dispatch checkBasicOperation(AthenaSchema schema, RelationshipOp op)
  {
    registerWarningMessage("RelationshipOp", "Relationship operations are not supported on Cassandra and will be ignored: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, FeatureDeleteOp op)
  {
    /*if (op.spec.selector.targets.map[t | aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schema, op.spec.selector.ref), t)].exists[f | f.isKey])
      registerErrorMessage("FeatureDeleteOp", "A key attribute cannot be deleted: ", op)*/
  }

  def dispatch checkBasicOperation(AthenaSchema schema, FeatureRenameOp op)
  {
    if (op.spec.selector.ref.contains("."))
      registerErrorMessage("FeatureRenameOp", "Cannot rename features with dot notation: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, FeatureCopyOp op)
  {
    val featName = op.spec.condition.c2.contains(".") ? op.spec.condition.c2.substring(op.spec.condition.c2.indexOf(".") + 1) : op.spec.condition.c2
    val feature = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schema, op.spec.targetSelector.ref), featName)

    if (feature === null || !feature.key)
      registerErrorMessage("FeatureCopyOp", "Cannot Copy without a key on the target condition: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, FeatureMoveOp op)
  {
    val featName = op.spec.condition.c2.contains(".") ? op.spec.condition.c2.substring(op.spec.condition.c2.indexOf(".") + 1) : op.spec.condition.c2
    val feature = aHandler.getSimpleFeatureInSchemaType(aHandler.getEntityDecl(schema, op.spec.targetSelector.ref), featName)

    if (feature === null || !feature.key)
      registerErrorMessage("FeatureMoveOp", "Cannot Move without a key on the target condition: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, FeatureNestOp op)
  {
    registerWarningMessage("FeatureNestOp", "Fields will be removed and nested but cannot be populated: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, FeatureUnnestOp op)
  {
    registerWarningMessage("FeatureUnnestOp", "Fields will be unnested but will not be removed from the nest nor populated: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, AttributeAddOp op)
  {
    if (op.spec.isKey)
      registerWarningMessage("AttributeAddOp", "A new key column cannot be added. Ignoring key: ", op)

    if (op.spec.selector.target.startsWith("_"))
    {
      registerWarningMessage("AttributeAddOp", "In Cassandra a field cannot start with \"_\". Removing that character: ", op)
      op.spec.selector.target = op.spec.selector.target.substring(1)
    }

    op.spec.type = checkDataType(op.spec.type)

    if (op.spec.defaultValue !== null)
      registerWarningMessage("AttributeAddOp", "When adding a new column the default value is ignored: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, ReferenceAddOp op)
  {
    checkDataType(op.spec.type)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, ReferenceMorphOp op)
  {
    if (op.spec.deleteId)
      registerWarningMessage("ReferenceMorphOp", "cannot delete Id from a user-defined type. Ignoring option: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, AggregateAddOp op)
  {
    if (op.spec.features.empty)
      registerErrorMessage("AggregateAddOp", "In Cassandra an User-defined type should have fields: ", op)
    else
      for(feat : op.spec.features)
        checkSimpleDataFeature(feat)

    if (op.spec.features.exists[f | f.defaultValue !== null])
      registerWarningMessage("AggregateAddOp", "When adding a new column the default value is ignored: ", op)
  }

  private def checkSimpleDataFeature(SimpleDataFeature feat)
  {
    if (feat.name.startsWith("_"))
    {
      registerWarningMessage("SimpleDataFeature", "In Cassandra a field cannot start with \"_\". Removing that character: ", feat)
      feat.name = feat.name.substring(1)
    }

    feat.type = checkDataType(feat.type)
  }

  private def checkDataType(DataType theType)
  {
    if (theType === null)
    {
      registerWarningMessage("SimpleDataFeature", "In Cassandra any column needs to have a non-null type. Replacing by String: ", theType)
      return factory.createPrimitiveType("String")
    }
    else
      switch (theType)
      {
        case theType instanceof Null:
        {
          registerWarningMessage("SimpleDataFeature", "In Cassandra a column of type Null cannot be created. Replacing by String: ", theType.eContainer)
          return factory.createPrimitiveType("String")
        }
        case theType instanceof Map:
        {
          val type = theType as Map
          if (type.keyType === null)
          {
            registerWarningMessage("SimpleDataFeature", "In Cassandra a Map has to define a primitive Key type. Replacing by String: ", theType.eContainer)
            type.keyType = factory.createPrimitiveType("String")
          }
          if (type.valueType === null || (type.valueType instanceof Null))
          {
            registerWarningMessage("SimpleDataFeature", "In Cassandra a Map cannot be of Null values. Replacing by String: ", theType.eContainer)
            type.valueType = factory.createPrimitiveType("String")
          }

          return type
        }
        case theType instanceof List:
        {
          val type = theType as List
          if (type.elementType === null || (type.elementType instanceof Null))
          {
            registerWarningMessage("SimpleDataFeature", "In Cassandra a List cannot be of Nulls. Replacing by String: ", theType.eContainer)
            type.elementType = factory.createPrimitiveType("String")
          }

          return type
        }
        case theType instanceof Set:
        {
          val type = theType as Set
          if (type.elementType === null || (type.elementType instanceof Null))
          {
            registerWarningMessage("SimpleDataFeature", "In Cassandra a Set cannot be of Nulls. Replacing by String: ", theType.eContainer)
            type.elementType = factory.createPrimitiveType("String")
          }

          return type
        }
        case theType instanceof Tuple:
        {
          val type = theType as Tuple
          if (type.elements.empty || type.elements.exists[e | (e instanceof Null)])
          {
            registerWarningMessage("SimpleDataFeature", "In Cassandra a Tuple cannot be of Nulls. Replacing by String: ", theType.eContainer)
            type.elements.clear
            type.elements.add(factory.createPrimitiveType("String"))
          }

          return type
        }
      }

    return theType
  }

  private def registerErrorMessage(String opName, String message, EObject obj)
  {
    errorLog.add("Cassandra> " + opName + "> " + message + (obj !== null ? orionIO.serialize(obj)))
  }

  private def registerWarningMessage(String opName, String message, EObject obj)
  {
    warningLog.add("Cassandra> " + opName + "> " + message + (obj !== null ? orionIO.serialize(obj)))
  }
}
