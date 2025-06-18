/**
 */
package es.um.uschema.USchema.impl;

import es.um.uschema.USchema.Aggregate;
import es.um.uschema.USchema.StructuralVariation;
import es.um.uschema.USchema.USchemaPackage;

import java.util.Collection;

import org.eclipse.emf.common.notify.Notification;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;

import org.eclipse.emf.ecore.impl.ENotificationImpl;

import org.eclipse.emf.ecore.util.EObjectResolvingEList;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Aggregate</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.impl.AggregateImpl#getAggregates <em>Aggregates</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.AggregateImpl#getUpperBound <em>Upper Bound</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.AggregateImpl#getLowerBound <em>Lower Bound</em>}</li>
 * </ul>
 *
 * @generated
 */
public class AggregateImpl extends StructuralFeatureImpl implements Aggregate {
  /**
   * The cached value of the '{@link #getAggregates() <em>Aggregates</em>}' reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getAggregates()
   * @generated
   * @ordered
   */
  protected EList<StructuralVariation> aggregates;

  /**
   * The default value of the '{@link #getUpperBound() <em>Upper Bound</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getUpperBound()
   * @generated
   * @ordered
   */
  protected static final int UPPER_BOUND_EDEFAULT = 0;

  /**
   * The cached value of the '{@link #getUpperBound() <em>Upper Bound</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getUpperBound()
   * @generated
   * @ordered
   */
  protected int upperBound = UPPER_BOUND_EDEFAULT;

  /**
   * The default value of the '{@link #getLowerBound() <em>Lower Bound</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getLowerBound()
   * @generated
   * @ordered
   */
  protected static final int LOWER_BOUND_EDEFAULT = 0;

  /**
   * The cached value of the '{@link #getLowerBound() <em>Lower Bound</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getLowerBound()
   * @generated
   * @ordered
   */
  protected int lowerBound = LOWER_BOUND_EDEFAULT;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected AggregateImpl() {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass() {
    return USchemaPackage.Literals.AGGREGATE;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<StructuralVariation> getAggregates() {
    if (aggregates == null) {
      aggregates = new EObjectResolvingEList<StructuralVariation>(StructuralVariation.class, this, USchemaPackage.AGGREGATE__AGGREGATES);
    }
    return aggregates;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public int getUpperBound() {
    return upperBound;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setUpperBound(int newUpperBound) {
    int oldUpperBound = upperBound;
    upperBound = newUpperBound;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.AGGREGATE__UPPER_BOUND, oldUpperBound, upperBound));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public int getLowerBound() {
    return lowerBound;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setLowerBound(int newLowerBound) {
    int oldLowerBound = lowerBound;
    lowerBound = newLowerBound;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.AGGREGATE__LOWER_BOUND, oldLowerBound, lowerBound));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType) {
    switch (featureID) {
      case USchemaPackage.AGGREGATE__AGGREGATES:
        return getAggregates();
      case USchemaPackage.AGGREGATE__UPPER_BOUND:
        return getUpperBound();
      case USchemaPackage.AGGREGATE__LOWER_BOUND:
        return getLowerBound();
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
      case USchemaPackage.AGGREGATE__AGGREGATES:
        getAggregates().clear();
        getAggregates().addAll((Collection<? extends StructuralVariation>)newValue);
        return;
      case USchemaPackage.AGGREGATE__UPPER_BOUND:
        setUpperBound((Integer)newValue);
        return;
      case USchemaPackage.AGGREGATE__LOWER_BOUND:
        setLowerBound((Integer)newValue);
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
      case USchemaPackage.AGGREGATE__AGGREGATES:
        getAggregates().clear();
        return;
      case USchemaPackage.AGGREGATE__UPPER_BOUND:
        setUpperBound(UPPER_BOUND_EDEFAULT);
        return;
      case USchemaPackage.AGGREGATE__LOWER_BOUND:
        setLowerBound(LOWER_BOUND_EDEFAULT);
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
      case USchemaPackage.AGGREGATE__AGGREGATES:
        return aggregates != null && !aggregates.isEmpty();
      case USchemaPackage.AGGREGATE__UPPER_BOUND:
        return upperBound != UPPER_BOUND_EDEFAULT;
      case USchemaPackage.AGGREGATE__LOWER_BOUND:
        return lowerBound != LOWER_BOUND_EDEFAULT;
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
    result.append(" (upperBound: ");
    result.append(upperBound);
    result.append(", lowerBound: ");
    result.append(lowerBound);
    result.append(')');
    return result.toString();
  }

} //AggregateImpl
