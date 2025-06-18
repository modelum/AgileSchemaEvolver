package codeql.template

class Query {
	
	static def generateEntityDeleteOp(String entityName)
	'''
	import java
	import utils
	
	from Class entity, Location usageLoc, string message
	where
	  entity.hasName("«entityName»") and
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
	'''
	
	static def generateEntityRenameOp(String oldEntityName, String newEntityName)
	'''
	import java
	import utils
	
	from Class oldEntity, Location usageLoc, string message, string newName
	where
	  oldEntity.hasName("«oldEntityName»") and // Last entity name
	  isEntity(oldEntity) and
	  newName = "«newEntityName»" and
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
	'''
	
	static def generateFeatureRenameOp(String entityName, String featureOldName, String featureNewName)
	'''
	import java
	import utils
	
	from
	  Class entity, Field featureField, Location usageLoc, string oldName, string newName,
	  string message
	where
	  isEntity(entity) and
	  entity.hasName("«entityName»") and // Name entity with the field
	  featureField = entity.getAField() and
	  featureField.hasName("«featureOldName»") and // Last field name
	
	  oldName = featureField.getName() and
	  newName = "«featureNewName»" and 
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
	'''
	
	static def generateFeatureDeleteOp(String entityName, String featureName)
	'''
	import java
	import utils
	
	from Class entity, Field attributeField, Location usageLoc, string message
	where
	  isEntity(entity) and
	  entity.hasName("«entityName»") and 
	  attributeField = entity.getAField() and
	  attributeField.hasName("«featureName»") and // Last field name
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
	'''
	
	static def generateAttributeCastOp(String entityName, String fieldName, String newFieldType)
	'''
	import java
	import utils
	
	from
	  Class entity, Field attributeField, Location usageLoc, string message, string oldType,
	  string newType
	where
	  isEntity(entity) and
	  entity.hasName("«entityName»") and 
	  attributeField = entity.getAField() and
	  attributeField.hasName("«fieldName»") and 
	  oldType = attributeField.getType().getName() and
	  newType = "«newFieldType»" and // New type to replace the old one
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
	'''
	
	def static generateAttributePromoteOp(String entityName, String newKeyName)
	'''
	import java
	import utils
	
	from Class entity, Field existingIdField, Location usageLoc, string message, string newIdFieldName
	where
	  isEntity(entity) and 
	  entity.hasName("«entityName»") and 
	  existingIdField = entity.getAField() and
	  
	  // field with a @Id annotation
	  exists(Annotation idAnnotation |
	    idAnnotation = existingIdField.getAnAnnotation() and
	    idAnnotation.getType().hasQualifiedName("jakarta.persistence", "Id")
	  ) and
	  
	  // Nombre del nuevo campo que será parte de la clave compuesta
	  newIdFieldName = "«newKeyName»" and
	  
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
	'''
	
	def static generateRelationshipRenameOp(String oldTableName, String newTableName)
	'''
	import java
	import utils
	
	from
	  Class sourceEntity, Field relationshipField, Location usageLoc, string message,
	  string oldTableName, string newTableName
	where
	  isEntity(sourceEntity) and
	  oldTableName = "«oldTableName»" and
	  newTableName = "«newTableName»" and
	
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
	'''
	
	def static generateRelationshipDeleteOp(String deleteTableName)
	'''
	import java
	import utils
	
	from
	  Class sourceEntity, Field relationshipField, Location usageLoc, string message,
	  string relationshipTable
	where
	  isEntity(sourceEntity) and  
	  relationshipTable = "«deleteTableName»" and
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
	'''
	
}