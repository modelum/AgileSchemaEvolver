package codeql.template

class Library {
	def static CharSequence generateUtils()
	'''
	import java
	
	/** 
	 *Check if two expressions are equal 
	 */
	predicate isEqual(Expr a, Expr b) {
	    a.toString() = b.toString()
	}
	
	/**
	 * Check if an annotation is a Query annotation
	 */
	predicate isQuery(Annotation a) {
	    a.getType().hasQualifiedName("org.springframework.data.jpa.repository", "Query")
	}
	
	/**
	 * Check if an annotation is a NamedQuery annotation
	 */
	predicate isNamedQuery(Annotation a) {
	    a.getType().hasQualifiedName("jakarta.persistence", "NamedQuery")
	}
	
	/*
	 * Check if an annotation is a Entity annotation
	 */
	predicate isEntity(Class entity) {
	  exists(Annotation annotation | annotation = entity.getAnAnnotation() and
	    annotation.getType().hasQualifiedName("jakarta.persistence", "Entity")
	  )
	}
	
	/**
	 * Check if an annotation is a Embeddable annotation
	 */
	predicate isEmbeddable(Class cls) {
	  exists(Annotation annotation | annotation = cls.getAnAnnotation() and
	    annotation.getType().hasQualifiedName("jakarta.persistence", "Embeddable")
	  )
	}
	
	/**
	 * Check if a field is used
	 */
	predicate usesField(Expr queryValue, Field field) {
	  exists(Class entity |
	    entity = field.getDeclaringType() and
	    (
	      // Case 1: Reference using the fully qualified entity name
	      queryValue.toString().regexpMatch("(?i).*\\b" + entity.getName() + "\\s*\\.\\s*" + field.getName() + "\\b.*")
	      or
	      // Case 2: Reference using an alias defined in the query
	      exists(string alias | 
	        // Look for patterns like "FROM Entity alias" or "JOIN Entity alias"
	        queryValue.toString().regexpMatch("(?i).*(FROM|JOIN)\\s+" + entity.getName() + "\\s+([a-zA-Z0-9_]+).*") and
	        // Capture the alias
	        alias = queryValue.toString().regexpCapture("(?i).*(FROM|JOIN)\\s+" + entity.getName() + "\\s+([a-zA-Z0-9_]+).*", 2) and
	        // Match usage of the alias with the field
	        queryValue.toString().regexpMatch("(?i).*\\b" + alias + "\\s*\\.\\s*" + field.getName() + "\\b.*")
	      )
	      or
	      // Case 3: Implicit reference in WHERE clauses without qualifier
	      exists(string whereQuery |
	        whereQuery = queryValue.toString() and
	        whereQuery.regexpMatch("(?i).*FROM\\s+" + entity.getName() + "\\b.*") and
	        whereQuery.regexpMatch("(?i).*\\bWHERE\\b.*\\b" + field.getName() + "\\b.*") and
	        // Ensure it's a standalone field name, not part of another identifier
	        whereQuery.regexpMatch("(?i).*\\b" + field.getName() + "\\b.*")
	      )
	    )
	  )
	}
	
	/** 
	 * Check if a entity is used in a JPQL query
	 */
	predicate usesOldEntity(Expr queryValue, Class parent) {
	  queryValue.toString().regexpMatch(
	    "(?i).*\\b(FROM|UPDATE|DELETE\\s+FROM)\\s+" + parent.getName() + "\\b.*"
	  )
	  or
	  queryValue.toString().regexpMatch(
	    "(?i).*\\bJOIN\\s+(?:FETCH\\s+)?" + parent.getName() + "\\b.*"
	  )
	}
	
	/**
	 * Check if a parent entity is used in a JPQL query
	 */
	predicate usesParentEntity(Expr queryValue, Class parent) {
	  queryValue.toString().regexpMatch(
	    "(?i).*\\bSELECT\\b.*\\bFROM\\s+" + parent.getName() + "\\b.*"
	  )
	  or
	  queryValue.toString().regexpMatch(
	    "(?i).*\\bJOIN\\s+(?:FETCH\\s+)?" + parent.getName() + "\\b.*"
	  )
	}
	
	/** 
	  * Check if the class have the @Inheritance annotation
	  */
	class InheritanceStrategyJOINED extends Annotation {
	  InheritanceStrategyJOINED() {
	    this.getType().hasQualifiedName("jakarta.persistence", "Inheritance") and
	    this.getValue("strategy").toString() = "InheritanceType.JOINED"
	  }
	}
	
	/**
	 * Check if the child class has a parent with the @Inheritance(strategy = InheritanceType.JOINED) annotation
	 */
	predicate childParentInheritanceWithStrategyJOINED(Class child, Class parent) {
	  child.hasName("VideoPost") and parent = child.getASupertype().(Class)
	  and parent.getAnAnnotation() instanceof InheritanceStrategyJOINED
	}
	
	/**
	 * Check if a field is used in a context that depends on its type
	 */
	predicate usesFieldWithTypeDependency(Expr expr, Field field) {
	  // Field is used in a cast expression
	  exists(CastExpr cast | cast.getExpr().(FieldAccess).getField() = field) and
	  expr = any(CastExpr c | c.getExpr().(FieldAccess).getField() = field)
	}
	
	/**
	 * Check if a field is a getter
	 */
	predicate isGetter(Method method, Field field) {
	  method.getName() = "get" + field.getName().substring(0, 1).toUpperCase() + 
	                    field.getName().substring(1, field.getName().length()) and
	  method.getDeclaringType() = field.getDeclaringType()
	}
	
	/**
	 * Check if a field is a setter
	 */
	predicate isSetter(Method method, Field field) {
	  method.getName() = "set" + field.getName().substring(0, 1).toUpperCase() + 
	                    field.getName().substring(1, field.getName().length()) and
	  method.getDeclaringType() = field.getDeclaringType() and
	  method.getNumberOfParameters() = 1
	}
	
	/**
	 * Check if a method call is an EntityManager query call
	 */
	predicate isCreateQuery(MethodCall call) {
	  call.getMethod().hasQualifiedName("jakarta.persistence", "EntityManager", "createQuery")
	}
	
	/**
	 * Check if a method call is an EntityManager named query call
	 */
	predicate isCreateNamedQuery(MethodCall call) {
	  call.getMethod().hasQualifiedName("jakarta.persistence", "EntityManager", "createNamedQuery")
	}
	
	/**
	 * Check if has a JPA association: OneToOne, OneToMany, ManyToOne, ManyToMany
	 */
	predicate hasJpaAssociationTo(Field field) {
	  field.hasAnnotation("jakarta.persistence", "ManyToOne") or
	  field.hasAnnotation("jakarta.persistence", "OneToOne") or
	  field.hasAnnotation("jakarta.persistence", "OneToMany") or
	  field.hasAnnotation("jakarta.persistence", "ManyToMany")
	}
	
	/**
	 * Determine if a field represents a JPA relationship
	 */
	predicate isRelationshipField(Field field) {
	  field.hasAnnotation("jakarta.persistence", "ManyToMany") 
	}
	
	/**
	 * EN: Detects if a field is related to another field through mappedBy
	 */
	predicate isRelatedField(Field relationshipField, Field mappedField) {
	  exists(Annotation mappedBy |
	    mappedBy = mappedField.getAnAnnotation() and
	    mappedBy.getType().hasQualifiedName("jakarta.persistence", "ManyToMany") and
	    mappedBy.getValue("mappedBy").toString().replaceAll("\"", "") = relationshipField.getName()
	  )
	}
	
	/**
	 * Detects if a field is referenced in a JPQL query
	 */
	private predicate fieldReferencedInQuery(Expr queryValue, Class entity, Field field) {
	  // with fully qualified entity name
	  queryValue.toString().regexpMatch("(?i).*\\b" + entity.getName() + "\\s*\\.\\s*" + field.getName() + "\\b.*")
	  or
	  // with alias
	  exists(string alias | 
	    queryValue.toString().regexpMatch("(?i).*(FROM|JOIN)\\s+" + entity.getName() + "\\s+([a-zA-Z0-9_]+).*") and
	    alias = queryValue.toString().regexpCapture("(?i).*(FROM|JOIN)\\s+" + entity.getName() + "\\s+([a-zA-Z0-9_]+).*", 2) and
	    queryValue.toString().regexpMatch("(?i).*\\b" + alias + "\\s*\\.\\s*" + field.getName() + "\\b.*")
	  )
	  or
	  // with where
	  exists(string whereQuery |
	    whereQuery = queryValue.toString() and
	    whereQuery.regexpMatch("(?i).*FROM\\s+" + entity.getName() + "\\b.*") and
	    whereQuery.regexpMatch("(?i).*\\bWHERE\\b.*\\b" + field.getName() + "\\b.*") and
	    whereQuery.regexpMatch("(?i).*\\b" + field.getName() + "\\b.*")
	  )
	}
	
	/**
	 * Detects if a relationship is used in a JPQL query
	 */
	predicate usesRelationship(Expr queryValue, Field relationshipField) {
	  // Direct reference to the main field
	  exists(Class entity |
	    entity = relationshipField.getDeclaringType() and
	    fieldReferencedInQuery(queryValue, entity, relationshipField)
	  )
	  or
	  // References to related fields through mappedBy (in any entity)
	  exists(Class entity, Field mappedField |
	    isRelatedField(relationshipField, mappedField) and
	    entity = mappedField.getDeclaringType() and
	    fieldReferencedInQuery(queryValue, entity, mappedField)
	  )
	}
	
	/**
	 * Improve the relationship field detection to include both sides of the relationship
	 */
	Field getRelationshipField(Class sourceEntity, string relationshipTableName) {
	    result = sourceEntity.getAField() and
	    isRelationshipField(result) and
	    exists(Annotation joinTable |
	      hasJoinTableAnnotation(result) and
	      joinTable.getValue("name").toString().replaceAll("\"", "") = relationshipTableName
	    )
	}
	
	/**
	 * Check if a field have the @JoinTable annotation
	 */
	predicate hasJoinTableAnnotation(Field field) {
	  exists(Annotation joinTable |
	    joinTable = field.getAnAnnotation() and
	    joinTable.getType().hasQualifiedName("jakarta.persistence", "JoinTable")
	  )
	}
	'''
}