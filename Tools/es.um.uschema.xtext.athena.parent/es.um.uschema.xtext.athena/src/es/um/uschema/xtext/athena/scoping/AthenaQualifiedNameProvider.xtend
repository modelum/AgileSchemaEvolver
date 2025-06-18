package es.um.uschema.xtext.athena.scoping

import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import es.um.uschema.xtext.athena.athena.AthenaSchema
import org.eclipse.xtext.naming.QualifiedName

class AthenaQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider
{
  def QualifiedName qualifiedName(AthenaSchema schema)
  {
    return QualifiedName.create(schema.id.name + ":" + Integer.toString(schema.id.version))
  }
}
