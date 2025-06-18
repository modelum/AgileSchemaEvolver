/**
 * This is an automatically generated file
 *
 * @name Feature Deleted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/feature-deleted/3/0
 */
 
import java
import utils

from Class entity, Field attributeField, Location usageLoc, string message
where
  isEntity(entity) and
  entity.hasName("Player1") and 
  attributeField = entity.getAField() and
  attributeField.hasName("inventory") and // Last field name
  (
    // the field will be renamed
    (usageLoc = attributeField.getLocation() and
    message = "Attribute '" + attributeField.getName() + "' in entity '" + entity.getName() + "' will be deleted.")
    
    or
    // use the field in embedded classes
    exists(Class embeddedClass, Field embeddedField, Field containerField |
      isEmbeddable(embeddedClass) and
      embeddedField = embeddedClass.getAField() and
      embeddedField.getName() = attributeField.getName() and
      containerField.getType() = embeddedClass and
      exists(Annotation embedded |
        embedded = containerField.getAnAnnotation() and
        embedded.getType().hasQualifiedName("jakarta.persistence", "Embedded")
      ) and
      usageLoc = embeddedField.getLocation() and
      message = "Embedded field '" + embeddedField.getName() + "' matches attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    // getters y setters
    exists(Method method |
      (isGetter(method, attributeField) or isSetter(method, attributeField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' accesses attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    // direct access to the attribute
    exists(FieldAccess access |
      access.getField() = attributeField and
      usageLoc = access.getLocation() and
      message = "Direct access to attribute '" + attributeField.getName() + "' which will be deleted."
    )

    or
    // query annotations
    exists(Annotation nq, Annotation q |
      (
        // Named queries
        (isQuery(q) and
        isNamedQuery(nq) and
        isEqual(nq.getValue("name"), q.getValue("name")) and
        usesField(nq.getValue("query"), attributeField) and
        usageLoc = q.getTarget().getLocation() and
        message = "Named query uses attribute '" + attributeField.getName() + "' which will be deleted.")

        or
        // Regular queries
        (isQuery(q) and usesField(q.getValue("value"), attributeField)) and
        usageLoc = q.getTarget().getLocation() and
        message = "Query uses attribute '" + attributeField.getName() + "' which will be deleted."
      )
    )

    or
    // createQuery y createNamedQuery
    exists(MethodCall call |
      (
        // agrupa las dos alternativas
        (isCreateQuery(call) and
        exists(StringLiteral queryLiteral |
          queryLiteral = call.getArgument(0) and
          usesField(queryLiteral, attributeField)
        ))

        or
        (isCreateNamedQuery(call) and
        exists(StringLiteral nameArg, Annotation nq |
          nameArg = call.getArgument(0) and
          isNamedQuery(nq) and
          "\"" + nameArg.getValue() + "\"" = nq.getValue("name").toString() and
          usesField(nq.getValue("query"), attributeField)
        ))
      ) and
      usageLoc = call.getLocation() and
      message = "Query uses attribute '" + attributeField.getName() + "' which will be deleted."
    )
  )
select usageLoc, message
