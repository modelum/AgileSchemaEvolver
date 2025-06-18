package es.um.uschema.xtext.orion.validation.m2t

import java.util.ArrayList
import es.um.uschema.xtext.orion.orion.BasicOperation
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.orion.orion.EntityAddOp
import org.eclipse.emf.ecore.EObject
import es.um.uschema.xtext.orion.orion.SimpleDataFeature
import es.um.uschema.xtext.athena.athena.DataType
import es.um.uschema.xtext.athena.athena.Set
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.athena.athena.Null
import es.um.uschema.xtext.orion.utils.OrionFactory
import es.um.uschema.xtext.athena.athena.Tuple
import es.um.uschema.xtext.athena.athena.Map
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType

class Neo4jValidator
{
  val errorLog = new ArrayList()
  val warningLog = new ArrayList()
  val orionIO = new OrionIO()
  val factory = new OrionFactory()

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
      if (op.spec.features.exists[f | f.isKey])
        registerWarningMessage("EntityAddOp", "New entities in Neo4j cannot have keys defined. Keys will be ignored: ", op)

      for(feat : op.spec.features)
        checkSimpleDataFeature(feat)
    }
  }

  private def checkSimpleDataFeature(SimpleDataFeature feat)
  {
    feat.type = checkDataType(feat.type)
  }

  private def checkDataType(DataType theType)
  {
    if (theType === null)
    {
      registerWarningMessage("SimpleDataFeature", "In Neo4j any feature needs to have a non-null type. Replacing by String: ", theType)
      return factory.createPrimitiveType("String")
    }
    else
      switch (theType)
      {
        case theType instanceof SinglePrimitiveType && (theType as SinglePrimitiveType).typename.toLowerCase.equals("identifier"):
        {
          registerWarningMessage("SimpleDataFeature", "In Neo4j a feature of type Identifier cannot be created. Replacing by String: ", theType.eContainer)
          return factory.createPrimitiveType("String")
        }
        case theType instanceof Null:
        {
          registerWarningMessage("SimpleDataFeature", "In Neo4j a feature of type Null cannot be created. Replacing by String: ", theType.eContainer)
          return factory.createPrimitiveType("String")
        }
        case theType instanceof Map:
        {
          val type = factory.createList((theType as Map).valueType)
          registerWarningMessage("SimpleDataFeature", "In Neo4j Maps are not available. Replacing by List: ", theType.eContainer)

          return type
        }
        case theType instanceof Set:
        {
          val type = factory.createList((theType as Set).elementType)
          registerWarningMessage("SimpleDataFeature", "In Neo4j Sets are not available. Replacing by List: ", theType.eContainer)

          return type
        }
        case theType instanceof Tuple:
        {
          val type = factory.createList((theType as Tuple).elements.head)
          registerWarningMessage("SimpleDataFeature", "In Neo4j Tuples are not available. Replacing by List: ", theType.eContainer)

          return type
        }
      }

    return theType
  }

  private def registerErrorMessage(String opName, String message, EObject obj)
  {
    errorLog.add("Neo4j> " + opName + "> " + message + (obj !== null ? orionIO.serialize(obj)))
  }

  private def registerWarningMessage(String opName, String message, EObject obj)
  {
    warningLog.add("Neo4j> " + opName + "> " + message + (obj !== null ? orionIO.serialize(obj)))
  }

}
