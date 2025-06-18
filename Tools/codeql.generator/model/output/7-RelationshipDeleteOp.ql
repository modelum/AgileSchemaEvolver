/**
 * This is an automatically generated file
 *
 * @name Relationship Deleted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/relationship-deleted/7
 */
 
import java
import utils

from
  Class sourceEntity, Field relationshipField, Location usageLoc, string message,
  string relationshipTable
where
  isEntity(sourceEntity) and  
  relationshipTable = "RelationshipAdded2" and
  relationshipField = getRelationshipField(sourceEntity, relationshipTable) and
  
  (
    // the relationship field 
    (usageLoc = relationshipField.getLocation() and
     message = "Relationship field '" + relationshipField.getName() + "' with database table '" +
        relationshipTable + "' will be deleted. " + "Remove all references to this relationship."
    )
    
    or
    // Mappings on the other side of the relationship (mappedBy)
    exists(Field mappedField, Annotation mappedBy |
      mappedBy = mappedField.getAnAnnotation() and
      isRelationshipField(mappedField) and
      mappedBy.getValue("mappedBy").toString().replaceAll("\"", "") = relationshipField.getName() and
      usageLoc = mappedBy.getLocation() and
      message =
        "Field '" + mappedField.getName() + "' references relationship '" +
          relationshipField.getName() + "' which will be deleted. " +
          "Remove this mapping configuration."
    )
    
    or    
    // JPQL queries directly referencing the relationship (any side)
    exists(Annotation nq, Annotation q |
      (
        // Named queries
        (isQuery(q) and
         isNamedQuery(nq) and
         isEqual(nq.getValue("name"), q.getValue("name")) and
         usesRelationship(nq.getValue("query"), relationshipField) and
         usageLoc = q.getLocation() and
         message =
          "Named query references relationship table '" + relationshipTable +
            "' which will be deleted. Update query to remove this reference."
        )
        or
        // Queries
        (isQuery(q) and
         usesRelationship(q.getValue("value"), relationshipField) and
         usageLoc = q.getLocation() and
         message =
          "Query references relationship table '" + relationshipTable +
            "' which will be deleted. Update query to remove this reference."
        )
      )
    )
    
    or
    // EntityManager createQuery/createNamedQuery
    exists(MethodCall call |
      (
        (
          isCreateQuery(call) and
          exists(StringLiteral queryLiteral |
            queryLiteral = call.getArgument(0) and
            usesRelationship(queryLiteral, relationshipField)
          )
        )
        or
        (
          isCreateNamedQuery(call) and
          exists(StringLiteral nameArg, Annotation nq2 |
            nameArg = call.getArgument(0) and
            isNamedQuery(nq2) and
            "\"" + nameArg.getValue() + "\"" = nq2.getValue("name").toString() and
            usesRelationship(nq2.getValue("query"), relationshipField)
          )
        )
      ) and
      usageLoc = call.getLocation() and
      message =
        "Query references relationship '" + relationshipField.getName() +
          "' which will be deleted. Update or remove this query."
    )
  )
select usageLoc, message
