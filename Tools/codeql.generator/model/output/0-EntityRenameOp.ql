/**
 * This is an automatically generated file
 *
 * @name Renamed Entity
 * @kind alert
 * @problem.severity warning
 * @id java/orion/entity-renamed/0
 */
 
import java
import utils

from Class oldEntity, Location usageLoc, string message, string newName
where
  oldEntity.hasName("Player1") and // Last entity name
  isEntity(oldEntity) and
  newName = "Player2" and
  (
    (usageLoc = oldEntity.getLocation() and
    message = "Entity '" + oldEntity.getName() + "' will be renamed to '" + newName + "'.")

    or
    // Field references in other entities
    exists(Field field |
      field.getType().getName() = oldEntity.getName() and hasJpaAssociationTo(field) and
      usageLoc = field.getLocation() and
      message =
        "Field '" + field.getName() + "' references old entity name '" + oldEntity.getName() +
          "' which will be renamed to '" + newName + "'."
    )
    or
    // JPQL queries
    exists(Annotation nq, Annotation q |
      (
        // Search namedQuery actives
        (isQuery(q) and
        isNamedQuery(nq) and
        isEqual(nq.getValue("name"), q.getValue("name")) and
        usesOldEntity(nq.getValue("query"), oldEntity) and
        usageLoc = q.getTarget().getLocation() and
        message = "Named query uses old entity name '" + oldEntity.getName() + "' which will be renamed to '" + newName + "'.")

        or
        // Search queries
        (isQuery(q) and
        usesOldEntity(q.getValue("value"), oldEntity) and
        usageLoc = q.getTarget().getLocation() and
        message = "Query uses old entity name '" + oldEntity.getName() + "' which will be renamed to '" + newName + "'.")

        or
        // Search createQuery
        exists(MethodCall call |
          isCreateQuery(call) and
          exists(StringLiteral queryLiteral |
            queryLiteral = call.getArgument(0) and
            usesOldEntity(queryLiteral, oldEntity)
          ) and
          usageLoc = call.getLocation() and
          message =
            "Call to createQuery uses old entity name '" + oldEntity.getName() +
              "' which will be renamed to '" + newName + "'."
        )

        or
        // Search createNamedQuery
        exists(MethodCall call |
          isCreateNamedQuery(call) and
          exists(StringLiteral nameArg |
            nameArg = call.getArgument(0) and
            isNamedQuery(nq) and
            "\"" + nameArg.getValue() + "\"" = nq.getValue("name").toString() and
            usesOldEntity(nq.getValue("query"), oldEntity)
          ) and
          usageLoc = call.getLocation() and
          message = "Call to createNamedQuery uses old entity name '" + oldEntity.getName() + "' which will be renamed to '" + newName + "'."
        )
      )
    )
  )
select usageLoc, message
