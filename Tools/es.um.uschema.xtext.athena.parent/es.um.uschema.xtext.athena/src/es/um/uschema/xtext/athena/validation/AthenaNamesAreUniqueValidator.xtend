package es.um.uschema.xtext.athena.validation

import org.eclipse.xtext.validation.NamesAreUniqueValidationHelper
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import es.um.uschema.xtext.athena.athena.InnerStructureLiteralArray
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.INamesAreUniqueValidationHelper.Context
import org.eclipse.xtext.EcoreUtil2

class AthenaNamesAreUniqueValidator extends NamesAreUniqueValidationHelper
{
  // This is overriding a method with the old implementation. We might need to change it on later releases.
  override void checkUniqueNames(Context context, ValidationMessageAcceptor acceptor)
  {
    super.doCheckUniqueNames(context, acceptor)
  }

  override void doCheckUniqueIn(IEObjectDescription description, Context context, ValidationMessageAcceptor acceptor)
  {
    if (isInnerStructureLiteralArray(description.EObjectOrProxy))
      return;

    super.doCheckUniqueIn(description, context, acceptor)
  }

  // Unique names should not collide when they are declared inside an array structure:
  // [ { a1, a2, a3}, {a1, a2, a4} ]
  private def boolean isInnerStructureLiteralArray(EObject obj)
  {
    return EcoreUtil2.getAllContainers(obj).exists[c | c instanceof InnerStructureLiteralArray]
  }
}
