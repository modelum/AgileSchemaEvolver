/**
 * This is an automatically generated file
 *
 * @name Feature Renamed
 * @kind alert
 * @problem.severity warning
 * @id java/orion/feature-renamed/2
 */
 
import java
import utils

from
  Class entity, Field featureField, Location usageLoc, string oldName, string newName,
  string message
where
  isEntity(entity) and
  entity.hasName("Player1") and // Name entity with the field
  featureField = entity.getAField() and
  featureField.hasName("username") and // Last field name

  oldName = featureField.getName() and
  newName = "user" and 
  (
    // the field will be renamed
    (usageLoc = featureField.getLocation() and
    message = "Feature '" + oldName + "' in entity '" + entity.getName() + "' will be renamed to '" + newName + "'.")

    or
    // use the field in embedded classes
    exists(Class embeddedClass, Field embeddedField, Field containerField |
      isEmbeddable(embeddedClass) and
      embeddedField = embeddedClass.getAField() and
      embeddedField.getName() = oldName and
      containerField.getType() = embeddedClass and
      exists(Annotation embedded |
        embedded = containerField.getAnAnnotation() and
        embedded.getType().hasQualifiedName("jakarta.persistence", "Embedded")
      ) and
      usageLoc = embeddedField.getLocation() and
      message = "Embedded field '" + oldName + "' matches feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // getters y setters
    exists(Method method |
      (isGetter(method, featureField) or isSetter(method, featureField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' accesses feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // direct access to the feature
    exists(FieldAccess access |
      access.getField() = featureField and
      usageLoc = access.getLocation() and
      message = "Direct access to feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )

    or
    // query annotations
    exists(Annotation nq, Annotation q |
      (
        // NamedQuery
        (isQuery(q) and
        isNamedQuery(nq) and
        isEqual(nq.getValue("name"), q.getValue("name")) and
        usesField(nq.getValue("query"), featureField) and
        usageLoc = q.getLocation() and
        message = "Named query uses feature '" + oldName + "' which will be renamed to '" + newName + "'.")
        or

        // Query
        (isQuery(q) and
        usesField(q.getValue("value"), featureField) and
        usageLoc = q.getLocation() and
        message = "Query uses feature '" + oldName + "' which will be renamed to '" + newName + "'.")
      )
    )

    or
    // createQuery y createNamedQuery
    exists(MethodCall call |
      (
        (isCreateQuery(call) and
        exists(StringLiteral queryLiteral |
          queryLiteral = call.getArgument(0) and
          usesField(queryLiteral, featureField)
        ))

        or
        (isCreateNamedQuery(call) and
        exists(StringLiteral nameArg, Annotation nq2 |
          nameArg = call.getArgument(0) and
          isNamedQuery(nq2) and
          "\"" + nameArg.getValue() + "\"" = nq2.getValue("name").toString() and
          usesField(nq2.getValue("query"), featureField)
        ))
      ) and
      usageLoc = call.getLocation() and
      message = "Query uses feature '" + oldName + "' which will be renamed to '" + newName + "'."
    )
  )
select usageLoc, message
