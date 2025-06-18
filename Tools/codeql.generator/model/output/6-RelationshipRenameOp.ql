/**
 * This is an automatically generated file
 *
 * @name Relationship Renamed
 * @kind alert
 * @problem.severity warning
 * @id java/orion/relationship-renamed/6
 */
 
import java
import utils

from
  Class sourceEntity, Field relationshipField, Location usageLoc, string message,
  string oldTableName, string newTableName
where
  isEntity(sourceEntity) and
  oldTableName = "RelationshipAdded3" and
  newTableName = "RelationshipRenamed" and

  // search a field with @JoinTable annotation
  relationshipField = sourceEntity.getAField() and
  exists(Annotation joinTable |
    hasJoinTableAnnotation(relationshipField) and
    joinTable.getValue("name").toString().replaceAll("\"", "") = oldTableName
    and
    usageLoc = joinTable.getLocation() and
    message =
      "Join table name will change from '" + oldTableName + "' to '" + newTableName + "'."
  ) 
select usageLoc, message
