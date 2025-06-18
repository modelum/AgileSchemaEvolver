/**
 * This is an automatically generated file
 *
 * @name Reference Casted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/reference-casted/9/0
 */
 
import java
import utils

from
  Class entity, Field attributeField, Location usageLoc, string message, string oldType,
  string newType
where
  isEntity(entity) and
  entity.hasName("VideoPost") and 
  attributeField = entity.getAField() and
  attributeField.hasName("id") and 
  oldType = attributeField.getType().getName() and
  newType = "int" and // New type to replace the old one
  (
    // the attribute will be casted
    (usageLoc = attributeField.getLocation() and
    message = "Attribute '" + attributeField.getName() + "' in entity '" + entity.getName() + "' will change type from '" + oldType + "' to '" + newType + "'.")

    or
    // getters y setters
    exists(Method method |
      (isGetter(method, attributeField) or isSetter(method, attributeField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' uses attribute '" + attributeField.getName() + "' with type '" + oldType + "' which will be changed to '" + newType + "'."
    )

    or
    // direct access to the attribute
    exists(Expr expr |
      usesFieldWithTypeDependency(expr, attributeField) and
      usageLoc = expr.getLocation() and
      message = "Code depends on attribute '" + attributeField.getName() + "' having type '" + oldType + "' which will be changed to '" + newType + "'."
    )

    or
    // variable declarations with used attribute
    exists(LocalVariableDeclExpr varDecl |
      exists(FieldAccess access |
        access.getField() = attributeField and
        varDecl.getInit() = access and
        varDecl.getType().getName() = oldType
      ) and
      usageLoc = varDecl.getLocation() and
      message = "Variable declaration uses attribute '" + attributeField.getName() + "' with type '" + oldType + "' which will be changed to '" + newType + "'."
    )

    or
    // 5. Field is passed to a method expecting the specific type
    exists(MethodCall call, FieldAccess access |
      access.getField() = attributeField and
      call.getAnArgument() = access and
      exists(int i |
        call.getArgument(i) = access and
        call.getMethod().getParameterType(i).getName() = oldType
      ) and
      usageLoc = call.getLocation() and
      message = "Method call passes attribute '" + attributeField.getName() + "' of type '" + oldType + "' which will be changed to '" + newType + "'."
    )
  )
select usageLoc, message
