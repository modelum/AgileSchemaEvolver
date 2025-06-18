/**
 */
package es.um.uschema.USchema.impl;

import es.um.uschema.USchema.*;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;

import org.eclipse.emf.ecore.impl.EFactoryImpl;

import org.eclipse.emf.ecore.plugin.EcorePlugin;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model <b>Factory</b>.
 * <!-- end-user-doc -->
 * @generated
 */
public class USchemaFactoryImpl extends EFactoryImpl implements USchemaFactory {
  /**
   * Creates the default factory implementation.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public static USchemaFactory init() {
    try {
      USchemaFactory theUSchemaFactory = (USchemaFactory)EPackage.Registry.INSTANCE.getEFactory(USchemaPackage.eNS_URI);
      if (theUSchemaFactory != null) {
        return theUSchemaFactory;
      }
    }
    catch (Exception exception) {
      EcorePlugin.INSTANCE.log(exception);
    }
    return new USchemaFactoryImpl();
  }

  /**
   * Creates an instance of the factory.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public USchemaFactoryImpl() {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EObject create(EClass eClass) {
    switch (eClass.getClassifierID()) {
      case USchemaPackage.USCHEMA: return createUSchema();
      case USchemaPackage.ENTITY_TYPE: return createEntityType();
      case USchemaPackage.STRUCTURAL_VARIATION: return createStructuralVariation();
      case USchemaPackage.ATTRIBUTE: return createAttribute();
      case USchemaPackage.PLIST: return createPList();
      case USchemaPackage.REFERENCE: return createReference();
      case USchemaPackage.AGGREGATE: return createAggregate();
      case USchemaPackage.PRIMITIVE_TYPE: return createPrimitiveType();
      case USchemaPackage.NULL: return createNull();
      case USchemaPackage.RELATIONSHIP_TYPE: return createRelationshipType();
      case USchemaPackage.PMAP: return createPMap();
      case USchemaPackage.PSET: return createPSet();
      case USchemaPackage.PTUPLE: return createPTuple();
      case USchemaPackage.KEY: return createKey();
      default:
        throw new IllegalArgumentException("The class '" + eClass.getName() + "' is not a valid classifier");
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public USchema createUSchema() {
    USchemaImpl uSchema = new USchemaImpl();
    return uSchema;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EntityType createEntityType() {
    EntityTypeImpl entityType = new EntityTypeImpl();
    return entityType;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public StructuralVariation createStructuralVariation() {
    StructuralVariationImpl structuralVariation = new StructuralVariationImpl();
    return structuralVariation;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Attribute createAttribute() {
    AttributeImpl attribute = new AttributeImpl();
    return attribute;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public PList createPList() {
    PListImpl pList = new PListImpl();
    return pList;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Reference createReference() {
    ReferenceImpl reference = new ReferenceImpl();
    return reference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Aggregate createAggregate() {
    AggregateImpl aggregate = new AggregateImpl();
    return aggregate;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public PrimitiveType createPrimitiveType() {
    PrimitiveTypeImpl primitiveType = new PrimitiveTypeImpl();
    return primitiveType;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Null createNull() {
    NullImpl null_ = new NullImpl();
    return null_;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public RelationshipType createRelationshipType() {
    RelationshipTypeImpl relationshipType = new RelationshipTypeImpl();
    return relationshipType;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public PMap createPMap() {
    PMapImpl pMap = new PMapImpl();
    return pMap;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public PSet createPSet() {
    PSetImpl pSet = new PSetImpl();
    return pSet;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public PTuple createPTuple() {
    PTupleImpl pTuple = new PTupleImpl();
    return pTuple;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Key createKey() {
    KeyImpl key = new KeyImpl();
    return key;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public USchemaPackage getUSchemaPackage() {
    return (USchemaPackage)getEPackage();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @deprecated
   * @generated
   */
  @Deprecated
  public static USchemaPackage getPackage() {
    return USchemaPackage.eINSTANCE;
  }

} //USchemaFactoryImpl
