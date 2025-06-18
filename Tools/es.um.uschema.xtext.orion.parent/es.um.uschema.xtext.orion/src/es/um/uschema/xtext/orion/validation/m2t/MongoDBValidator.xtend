package es.um.uschema.xtext.orion.validation.m2t

import java.util.ArrayList

import es.um.uschema.xtext.orion.orion.BasicOperation

import es.um.uschema.xtext.athena.athena.AthenaSchema
import org.eclipse.emf.ecore.EObject
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.orion.orion.RelationshipOp
import es.um.uschema.xtext.orion.orion.AttributePromoteOp
import es.um.uschema.xtext.orion.orion.AttributeDemoteOp

class MongoDBValidator
{
  val errorLog = new ArrayList
  val warningLog = new ArrayList
  val orionIO = new OrionIO()

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

  def dispatch checkBasicOperation(AthenaSchema schema, RelationshipOp op)
  {
    registerWarningMessage("RelationshipOp", "Relationship operations are not supported on this database and will be ignored: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, AttributePromoteOp op)
  {
    registerWarningMessage("AttributePromoteOp", "Attribute promotion operations are not supported on this database and will be ignored: ", op)
  }

  def dispatch checkBasicOperation(AthenaSchema schema, AttributeDemoteOp op)
  {
    registerWarningMessage("AttributeDemoteOp", "Attribute demotion operations are not supported on this database and will be ignored: ", op)
  }

/*
  private def registerErrorMessage(String opName, String message, EObject obj)
  {
    errorLog.add("MongoDB> " + opName + "> " + message + orionIO.serialize(obj))
  }
*/
  private def registerWarningMessage(String opName, String message, EObject obj)
  {
    warningLog.add("MongoDB> " + opName + "> " + message + orionIO.serialize(obj))
  }
}
