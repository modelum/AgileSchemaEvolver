/**
 * This is an automatically generated file
 *
 * @name Deleted Entity
 * @kind alert
 * @problem.severity warning
 * @id java/orion/entity-deleted/1
 */
 
import java
import utils

from Class entity, Location usageLoc, string message
where
  entity.hasName("Player1") and
  isEntity(entity) and
  (
    (usageLoc = entity.getLocation() and
    message = "Entity '" + entity.getName() + "' is marked for deletion.")

    or
    // Relaciones en otras entidades (@ManyToOne, @OneToOne, etc.)
    exists(Field field |
      field.getType() = entity and hasJpaAssociationTo(field) 
      and usageLoc = field.getLocation() 
      and message = "Field '" + field.getName() + "' references entity '" + entity.getName() + "' which is being deleted."
    )
    or
    // Queries 
    exists(Annotation nq, Annotation q |
      (
        // Search namedQuery actives
        (isQuery(q) and
        isNamedQuery(nq) and
        isEqual(nq.getValue("name"), q.getValue("name")) and
        usesOldEntity(nq.getValue("query"), entity) and
        usageLoc = q.getTarget().getLocation() and
        message = "Named query uses entity '" + entity.getName() + "' which is marked for deletion.")

        or
        // Search queries
        (isQuery(q) and
        usesOldEntity(q.getValue("value"), entity) and
        usageLoc = q.getTarget().getLocation() and
        message = "Query uses entity '" + entity.getName() + "' which is marked for deletion.")

        or
        // Search createQuery
        exists(MethodCall call |
          isCreateQuery(call) and
          exists(StringLiteral queryLiteral |
            queryLiteral = call.getArgument(0) and
            usesOldEntity(queryLiteral, entity)
          ) and
          usageLoc = call.getLocation() and
          message = "Call to createQuery uses entity '" + entity.getName() + "' which is marked for deletion."
        )

        or
        // Search createNamedQuery
        exists(MethodCall call |
          isCreateNamedQuery(call) and
          exists(StringLiteral nameArg |
            nameArg = call.getArgument(0) and
            isNamedQuery(nq) and
            "\"" + nameArg.getValue() + "\"" = nq.getValue("name").toString() and
            usesOldEntity(nq.getValue("query"), entity)
          ) and
          usageLoc = call.getLocation() and
          message = "Call to createNamedQuery uses entity '" + entity.getName() + "' which is marked for deletion."
        )
      )
    )
  )
select usageLoc, message
