/**
 */
package es.um.uschema.USchema.util;

import es.um.uschema.USchema.*;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;

import org.eclipse.emf.ecore.util.Switch;

/**
 * <!-- begin-user-doc -->
 * The <b>Switch</b> for the model's inheritance hierarchy.
 * It supports the call {@link #doSwitch(EObject) doSwitch(object)}
 * to invoke the <code>caseXXX</code> method for each class of the model,
 * starting with the actual class of the object
 * and proceeding up the inheritance hierarchy
 * until a non-null result is returned,
 * which is the result of the switch.
 * <!-- end-user-doc -->
 * @see es.um.uschema.USchema.USchemaPackage
 * @generated
 */
public class USchemaSwitch<T> extends Switch<T> {
  /**
   * The cached model package
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected static USchemaPackage modelPackage;

  /**
   * Creates an instance of the switch.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public USchemaSwitch() {
    if (modelPackage == null) {
      modelPackage = USchemaPackage.eINSTANCE;
    }
  }

  /**
   * Checks whether this is a switch for the given package.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param ePackage the package in question.
   * @return whether this is a switch for the given package.
   * @generated
   */
  @Override
  protected boolean isSwitchFor(EPackage ePackage) {
    return ePackage == modelPackage;
  }

  /**
   * Calls <code>caseXXX</code> for each class of the model until one returns a non null result; it yields that result.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the first non-null result returned by a <code>caseXXX</code> call.
   * @generated
   */
  @Override
  protected T doSwitch(int classifierID, EObject theEObject) {
    switch (classifierID) {
      case USchemaPackage.USCHEMA: {
        USchema uSchema = (USchema)theEObject;
        T result = caseUSchema(uSchema);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.ENTITY_TYPE: {
        EntityType entityType = (EntityType)theEObject;
        T result = caseEntityType(entityType);
        if (result == null) result = caseSchemaType(entityType);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.STRUCTURAL_VARIATION: {
        StructuralVariation structuralVariation = (StructuralVariation)theEObject;
        T result = caseStructuralVariation(structuralVariation);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.FEATURE: {
        Feature feature = (Feature)theEObject;
        T result = caseFeature(feature);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.ATTRIBUTE: {
        Attribute attribute = (Attribute)theEObject;
        T result = caseAttribute(attribute);
        if (result == null) result = caseStructuralFeature(attribute);
        if (result == null) result = caseFeature(attribute);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.DATA_TYPE: {
        DataType dataType = (DataType)theEObject;
        T result = caseDataType(dataType);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.PLIST: {
        PList pList = (PList)theEObject;
        T result = casePList(pList);
        if (result == null) result = caseDataType(pList);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.REFERENCE: {
        Reference reference = (Reference)theEObject;
        T result = caseReference(reference);
        if (result == null) result = caseLogicalFeature(reference);
        if (result == null) result = caseFeature(reference);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.AGGREGATE: {
        Aggregate aggregate = (Aggregate)theEObject;
        T result = caseAggregate(aggregate);
        if (result == null) result = caseStructuralFeature(aggregate);
        if (result == null) result = caseFeature(aggregate);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.PRIMITIVE_TYPE: {
        PrimitiveType primitiveType = (PrimitiveType)theEObject;
        T result = casePrimitiveType(primitiveType);
        if (result == null) result = caseDataType(primitiveType);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.NULL: {
        Null null_ = (Null)theEObject;
        T result = caseNull(null_);
        if (result == null) result = caseDataType(null_);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.RELATIONSHIP_TYPE: {
        RelationshipType relationshipType = (RelationshipType)theEObject;
        T result = caseRelationshipType(relationshipType);
        if (result == null) result = caseSchemaType(relationshipType);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.SCHEMA_TYPE: {
        SchemaType schemaType = (SchemaType)theEObject;
        T result = caseSchemaType(schemaType);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.PMAP: {
        PMap pMap = (PMap)theEObject;
        T result = casePMap(pMap);
        if (result == null) result = caseDataType(pMap);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.PSET: {
        PSet pSet = (PSet)theEObject;
        T result = casePSet(pSet);
        if (result == null) result = caseDataType(pSet);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.PTUPLE: {
        PTuple pTuple = (PTuple)theEObject;
        T result = casePTuple(pTuple);
        if (result == null) result = caseDataType(pTuple);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.LOGICAL_FEATURE: {
        LogicalFeature logicalFeature = (LogicalFeature)theEObject;
        T result = caseLogicalFeature(logicalFeature);
        if (result == null) result = caseFeature(logicalFeature);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.KEY: {
        Key key = (Key)theEObject;
        T result = caseKey(key);
        if (result == null) result = caseLogicalFeature(key);
        if (result == null) result = caseFeature(key);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      case USchemaPackage.STRUCTURAL_FEATURE: {
        StructuralFeature structuralFeature = (StructuralFeature)theEObject;
        T result = caseStructuralFeature(structuralFeature);
        if (result == null) result = caseFeature(structuralFeature);
        if (result == null) result = defaultCase(theEObject);
        return result;
      }
      default: return defaultCase(theEObject);
    }
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>USchema</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>USchema</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseUSchema(USchema object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Entity Type</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Entity Type</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseEntityType(EntityType object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Structural Variation</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Structural Variation</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseStructuralVariation(StructuralVariation object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Feature</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Feature</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseFeature(Feature object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Attribute</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Attribute</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseAttribute(Attribute object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Data Type</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Data Type</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseDataType(DataType object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>PList</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>PList</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T casePList(PList object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Reference</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Reference</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseReference(Reference object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Aggregate</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Aggregate</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseAggregate(Aggregate object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Primitive Type</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Primitive Type</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T casePrimitiveType(PrimitiveType object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Null</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Null</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseNull(Null object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Relationship Type</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Relationship Type</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseRelationshipType(RelationshipType object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Schema Type</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Schema Type</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseSchemaType(SchemaType object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>PMap</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>PMap</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T casePMap(PMap object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>PSet</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>PSet</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T casePSet(PSet object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>PTuple</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>PTuple</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T casePTuple(PTuple object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Logical Feature</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Logical Feature</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseLogicalFeature(LogicalFeature object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Key</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Key</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseKey(Key object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>Structural Feature</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>Structural Feature</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject) doSwitch(EObject)
   * @generated
   */
  public T caseStructuralFeature(StructuralFeature object) {
    return null;
  }

  /**
   * Returns the result of interpreting the object as an instance of '<em>EObject</em>'.
   * <!-- begin-user-doc -->
   * This implementation returns null;
   * returning a non-null result will terminate the switch, but this is the last case anyway.
   * <!-- end-user-doc -->
   * @param object the target of the switch.
   * @return the result of interpreting the object as an instance of '<em>EObject</em>'.
   * @see #doSwitch(org.eclipse.emf.ecore.EObject)
   * @generated
   */
  @Override
  public T defaultCase(EObject object) {
    return null;
  }

} //USchemaSwitch
