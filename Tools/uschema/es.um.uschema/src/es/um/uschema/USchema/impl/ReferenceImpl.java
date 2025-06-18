/**
 */
package es.um.uschema.USchema.impl;

import es.um.uschema.USchema.Attribute;
import es.um.uschema.USchema.EntityType;
import es.um.uschema.USchema.Reference;
import es.um.uschema.USchema.StructuralVariation;
import es.um.uschema.USchema.USchemaPackage;

import java.util.Collection;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;

import org.eclipse.emf.ecore.util.EObjectResolvingEList;
import org.eclipse.emf.ecore.util.EObjectWithInverseResolvingEList;
import org.eclipse.emf.ecore.util.InternalEList;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Reference</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.impl.ReferenceImpl#getOpposite <em>Opposite</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.ReferenceImpl#getRefsTo <em>Refs To</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.ReferenceImpl#getIsFeaturedBy <em>Is Featured By</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.ReferenceImpl#getAttributes <em>Attributes</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.ReferenceImpl#getUpperBound <em>Upper Bound</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.ReferenceImpl#getLowerBound <em>Lower Bound</em>}</li>
 * </ul>
 *
 * @generated
 */
public class ReferenceImpl extends LogicalFeatureImpl implements Reference {
  /**
   * The cached value of the '{@link #getOpposite() <em>Opposite</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getOpposite()
   * @generated
   * @ordered
   */
  protected Reference opposite;

  /**
   * The cached value of the '{@link #getRefsTo() <em>Refs To</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getRefsTo()
   * @generated
   * @ordered
   */
  protected EntityType refsTo;

  /**
   * The cached value of the '{@link #getIsFeaturedBy() <em>Is Featured By</em>}' reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getIsFeaturedBy()
   * @generated
   * @ordered
   */
  protected EList<StructuralVariation> isFeaturedBy;

  /**
   * The cached value of the '{@link #getAttributes() <em>Attributes</em>}' reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getAttributes()
   * @generated
   * @ordered
   */
  protected EList<Attribute> attributes;

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
  protected ReferenceImpl() {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass() {
    return USchemaPackage.Literals.REFERENCE;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Reference getOpposite() {
    if (opposite != null && opposite.eIsProxy()) {
      InternalEObject oldOpposite = (InternalEObject)opposite;
      opposite = (Reference)eResolveProxy(oldOpposite);
      if (opposite != oldOpposite) {
        if (eNotificationRequired())
          eNotify(new ENotificationImpl(this, Notification.RESOLVE, USchemaPackage.REFERENCE__OPPOSITE, oldOpposite, opposite));
      }
    }
    return opposite;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Reference basicGetOpposite() {
    return opposite;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setOpposite(Reference newOpposite) {
    Reference oldOpposite = opposite;
    opposite = newOpposite;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.REFERENCE__OPPOSITE, oldOpposite, opposite));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EntityType getRefsTo() {
    if (refsTo != null && refsTo.eIsProxy()) {
      InternalEObject oldRefsTo = (InternalEObject)refsTo;
      refsTo = (EntityType)eResolveProxy(oldRefsTo);
      if (refsTo != oldRefsTo) {
        if (eNotificationRequired())
          eNotify(new ENotificationImpl(this, Notification.RESOLVE, USchemaPackage.REFERENCE__REFS_TO, oldRefsTo, refsTo));
      }
    }
    return refsTo;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public EntityType basicGetRefsTo() {
    return refsTo;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setRefsTo(EntityType newRefsTo) {
    EntityType oldRefsTo = refsTo;
    refsTo = newRefsTo;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.REFERENCE__REFS_TO, oldRefsTo, refsTo));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<StructuralVariation> getIsFeaturedBy() {
    if (isFeaturedBy == null) {
      isFeaturedBy = new EObjectResolvingEList<StructuralVariation>(StructuralVariation.class, this, USchemaPackage.REFERENCE__IS_FEATURED_BY);
    }
    return isFeaturedBy;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<Attribute> getAttributes() {
    if (attributes == null) {
      attributes = new EObjectWithInverseResolvingEList.ManyInverse<Attribute>(Attribute.class, this, USchemaPackage.REFERENCE__ATTRIBUTES, USchemaPackage.ATTRIBUTE__REFERENCES);
    }
    return attributes;
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
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.REFERENCE__UPPER_BOUND, oldUpperBound, upperBound));
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
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.REFERENCE__LOWER_BOUND, oldLowerBound, lowerBound));
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
      case USchemaPackage.REFERENCE__ATTRIBUTES:
        return ((InternalEList<InternalEObject>)(InternalEList<?>)getAttributes()).basicAdd(otherEnd, msgs);
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
      case USchemaPackage.REFERENCE__ATTRIBUTES:
        return ((InternalEList<?>)getAttributes()).basicRemove(otherEnd, msgs);
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
      case USchemaPackage.REFERENCE__OPPOSITE:
        if (resolve) return getOpposite();
        return basicGetOpposite();
      case USchemaPackage.REFERENCE__REFS_TO:
        if (resolve) return getRefsTo();
        return basicGetRefsTo();
      case USchemaPackage.REFERENCE__IS_FEATURED_BY:
        return getIsFeaturedBy();
      case USchemaPackage.REFERENCE__ATTRIBUTES:
        return getAttributes();
      case USchemaPackage.REFERENCE__UPPER_BOUND:
        return getUpperBound();
      case USchemaPackage.REFERENCE__LOWER_BOUND:
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
      case USchemaPackage.REFERENCE__OPPOSITE:
        setOpposite((Reference)newValue);
        return;
      case USchemaPackage.REFERENCE__REFS_TO:
        setRefsTo((EntityType)newValue);
        return;
      case USchemaPackage.REFERENCE__IS_FEATURED_BY:
        getIsFeaturedBy().clear();
        getIsFeaturedBy().addAll((Collection<? extends StructuralVariation>)newValue);
        return;
      case USchemaPackage.REFERENCE__ATTRIBUTES:
        getAttributes().clear();
        getAttributes().addAll((Collection<? extends Attribute>)newValue);
        return;
      case USchemaPackage.REFERENCE__UPPER_BOUND:
        setUpperBound((Integer)newValue);
        return;
      case USchemaPackage.REFERENCE__LOWER_BOUND:
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
      case USchemaPackage.REFERENCE__OPPOSITE:
        setOpposite((Reference)null);
        return;
      case USchemaPackage.REFERENCE__REFS_TO:
        setRefsTo((EntityType)null);
        return;
      case USchemaPackage.REFERENCE__IS_FEATURED_BY:
        getIsFeaturedBy().clear();
        return;
      case USchemaPackage.REFERENCE__ATTRIBUTES:
        getAttributes().clear();
        return;
      case USchemaPackage.REFERENCE__UPPER_BOUND:
        setUpperBound(UPPER_BOUND_EDEFAULT);
        return;
      case USchemaPackage.REFERENCE__LOWER_BOUND:
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
      case USchemaPackage.REFERENCE__OPPOSITE:
        return opposite != null;
      case USchemaPackage.REFERENCE__REFS_TO:
        return refsTo != null;
      case USchemaPackage.REFERENCE__IS_FEATURED_BY:
        return isFeaturedBy != null && !isFeaturedBy.isEmpty();
      case USchemaPackage.REFERENCE__ATTRIBUTES:
        return attributes != null && !attributes.isEmpty();
      case USchemaPackage.REFERENCE__UPPER_BOUND:
        return upperBound != UPPER_BOUND_EDEFAULT;
      case USchemaPackage.REFERENCE__LOWER_BOUND:
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

} //ReferenceImpl
