/**
 * This is an automatically generated file
 *
 * @name Attribute Promoted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/attribute-promoted/5
 */
 
import java
import utils

from Class entity, Field existingIdField, Location usageLoc, string message, string newIdFieldName
where
  isEntity(entity) and 
  entity.hasName("EntityToPromote") and 
  existingIdField = entity.getAField() and
  
  // field with a @Id annotation
  exists(Annotation idAnnotation |
    idAnnotation = existingIdField.getAnAnnotation() and
    idAnnotation.getType().hasQualifiedName("jakarta.persistence", "Id")
  ) and
  
  // Nombre del nuevo campo que será parte de la clave compuesta
  newIdFieldName = "id2,id3,id4" and
  
  (
    (usageLoc = existingIdField.getLocation() and
     message = "Field '" + existingIdField.getName() + "' will become part of composite key. " + "A new @EmbeddedId class will be created with this field and '" + newIdFieldName + "'.")
    
    or
    // @Id, @GeneratedValue annotations
    exists(Annotation annotation |
      annotation = existingIdField.getAnAnnotation() and
      (
        annotation.getType().hasQualifiedName("jakarta.persistence", "Id") or
        annotation.getType().hasQualifiedName("jakarta.persistence", "GeneratedValue")
      ) and
      usageLoc = annotation.getLocation() and
      message = "Annotation '" + annotation.getType().getName() + "' will be removed as field becomes part of @EmbeddedId."
    )
    
    or
    // getters y setters
    exists(Method method |
      (isGetter(method, existingIdField) or isSetter(method, existingIdField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' will need to be updated to use the composite key class instead of " +"accessing '" + existingIdField.getName() + "' directly."
    )
    
    or
    // direct access to the field
    exists(FieldAccess access |
      access.getField() = existingIdField and
      usageLoc = access.getLocation() and
      message = "Direct access to field '" + existingIdField.getName() + "' will need to be updated to use the composite key class."
    )
    
    or
    // query annotations
    exists(Annotation nq, Annotation q |
      (
        // Named queries
        (isQuery(q) and
         isNamedQuery(nq) and
         isEqual(nq.getValue("name"), q.getValue("name")) and
         usesField(nq.getValue("query"), existingIdField) and
         usageLoc = q.getLocation() and
         message = "Named query uses field '" + existingIdField.getName() + "' which will become part of a composite key. JPQL needs to be updated.")
        or
        // queries
        (isQuery(q) and
         usesField(q.getValue("value"), existingIdField) and
         usageLoc = q.getLocation() and
         message = "Query uses field '" + existingIdField.getName() + "' which will become part of a composite key. JPQL needs to be updated.")
      )
    )
    
    or
    // createQuery/createNamedQuery
    exists(MethodCall call |
      (
        (isCreateQuery(call) and
         exists(StringLiteral queryLiteral |
           queryLiteral = call.getArgument(0) and
           usesField(queryLiteral, existingIdField)
         ))
        or
        (isCreateNamedQuery(call) and
         exists(StringLiteral nameArg, Annotation nq2 |
           nameArg = call.getArgument(0) and
           isNamedQuery(nq2) and
           "\"" + nameArg.getValue() + "\"" = nq2.getValue("name").toString() and
           usesField(nq2.getValue("query"), existingIdField)
         ))
      ) and
      usageLoc = call.getLocation() and
      message = "Query references field '" + existingIdField.getName() + "' which will become part of a composite key. JPQL needs to be updated."
    )
    
    or
    // foreign key references
    exists(Field foreignField, Class foreignEntity |
      isEntity(foreignEntity) and
      foreignField = foreignEntity.getAField() and
      (
        // joinColumn references 
        exists(Annotation joinColumn |
          joinColumn = foreignField.getAnAnnotation() and
          joinColumn.getType().hasQualifiedName("jakarta.persistence", "JoinColumn") and
          joinColumn.getValue("referencedColumnName").toString().replaceAll("\"", "") = existingIdField.getName()
        )
        or
        // OneToOne/ManyToOne references
        (
          foreignField.getType() = entity and
          (
            foreignField.hasAnnotation("jakarta.persistence", "ManyToOne") or
            foreignField.hasAnnotation("jakarta.persistence", "OneToOne")
          )
        )
      ) and
      usageLoc = foreignField.getLocation() and
      message = "Field '" + foreignField.getName() + "' in entity '" + foreignEntity.getName() + 
               "' references '" + existingIdField.getName() + "' which will become part of a composite key. " +
               "Foreign key relationship must be updated to use the composite key."
    )
  )
select usageLoc, message
