/**
 */
package es.um.uschema.USchema.impl;

import es.um.uschema.USchema.SchemaType;
import es.um.uschema.USchema.StructuralVariation;
import es.um.uschema.USchema.USchemaPackage;

import java.util.Collection;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl;

import org.eclipse.emf.ecore.util.EObjectContainmentWithInverseEList;
import org.eclipse.emf.ecore.util.EObjectResolvingEList;
import org.eclipse.emf.ecore.util.InternalEList;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Schema Type</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.impl.SchemaTypeImpl#getName <em>Name</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.SchemaTypeImpl#getParents <em>Parents</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.SchemaTypeImpl#getVariations <em>Variations</em>}</li>
 * </ul>
 *
 * @generated
 */
public abstract class SchemaTypeImpl extends MinimalEObjectImpl.Container implements SchemaType {
  /**
   * The default value of the '{@link #getName() <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getName()
   * @generated
   * @ordered
   */
  protected static final String NAME_EDEFAULT = null;

  /**
   * The cached value of the '{@link #getName() <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getName()
   * @generated
   * @ordered
   */
  protected String name = NAME_EDEFAULT;

  /**
   * The cached value of the '{@link #getParents() <em>Parents</em>}' reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getParents()
   * @generated
   * @ordered
   */
  protected EList<SchemaType> parents;

  /**
   * The cached value of the '{@link #getVariations() <em>Variations</em>}' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getVariations()
   * @generated
   * @ordered
   */
  protected EList<StructuralVariation> variations;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected SchemaTypeImpl() {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass() {
    return USchemaPackage.Literals.SCHEMA_TYPE;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public String getName() {
    return name;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setName(String newName) {
    String oldName = name;
    name = newName;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.SCHEMA_TYPE__NAME, oldName, name));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<SchemaType> getParents() {
    if (parents == null) {
      parents = new EObjectResolvingEList<SchemaType>(SchemaType.class, this, USchemaPackage.SCHEMA_TYPE__PARENTS);
    }
    return parents;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<StructuralVariation> getVariations() {
    if (variations == null) {
      variations = new EObjectContainmentWithInverseEList<StructuralVariation>(StructuralVariation.class, this, USchemaPackage.SCHEMA_TYPE__VARIATIONS, USchemaPackage.STRUCTURAL_VARIATION__CONTAINER);
    }
    return variations;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @SuppressWarnings("unchecked")
  @Override
  public NotificationChain eInverseAdd(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
    switch (featureID) {
      case USchemaPackage.SCHEMA_TYPE__VARIATIONS:
        return ((InternalEList<InternalEObject>)(InternalEList<?>)getVariations()).basicAdd(otherEnd, msgs);
    }
    return super.eInverseAdd(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
    switch (featureID) {
      case USchemaPackage.SCHEMA_TYPE__VARIATIONS:
        return ((InternalEList<?>)getVariations()).basicRemove(otherEnd, msgs);
    }
    return super.eInverseRemove(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType) {
    switch (featureID) {
      case USchemaPackage.SCHEMA_TYPE__NAME:
        return getName();
      case USchemaPackage.SCHEMA_TYPE__PARENTS:
        return getParents();
      case USchemaPackage.SCHEMA_TYPE__VARIATIONS:
        return getVariations();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @SuppressWarnings("unchecked")
  @Override
  public void eSet(int featureID, Object newValue) {
    switch (featureID) {
      case USchemaPackage.SCHEMA_TYPE__NAME:
        setName((String)newValue);
        return;
      case USchemaPackage.SCHEMA_TYPE__PARENTS:
        getParents().clear();
        getParents().addAll((Collection<? extends SchemaType>)newValue);
        return;
      case USchemaPackage.SCHEMA_TYPE__VARIATIONS:
        getVariations().clear();
        getVariations().addAll((Collection<? extends StructuralVariation>)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID) {
    switch (featureID) {
      case USchemaPackage.SCHEMA_TYPE__NAME:
        setName(NAME_EDEFAULT);
        return;
      case USchemaPackage.SCHEMA_TYPE__PARENTS:
        getParents().clear();
        return;
      case USchemaPackage.SCHEMA_TYPE__VARIATIONS:
        getVariations().clear();
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID) {
    switch (featureID) {
      case USchemaPackage.SCHEMA_TYPE__NAME:
        return NAME_EDEFAULT == null ? name != null : !NAME_EDEFAULT.equals(name);
      case USchemaPackage.SCHEMA_TYPE__PARENTS:
        return parents != null && !parents.isEmpty();
      case USchemaPackage.SCHEMA_TYPE__VARIATIONS:
        return variations != null && !variations.isEmpty();
    }
    return super.eIsSet(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public String toString() {
    if (eIsProxy()) return super.toString();

    StringBuilder result = new StringBuilder(super.toString());
    result.append(" (name: ");
    result.append(name);
    result.append(')');
    return result.toString();
  }

} //SchemaTypeImpl
