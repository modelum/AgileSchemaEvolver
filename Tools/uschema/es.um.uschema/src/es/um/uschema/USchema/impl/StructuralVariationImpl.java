/**
 */
package es.um.uschema.USchema.impl;

import es.um.uschema.USchema.Feature;
import es.um.uschema.USchema.LogicalFeature;
import es.um.uschema.USchema.SchemaType;
import es.um.uschema.USchema.StructuralFeature;
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

import org.eclipse.emf.ecore.util.EObjectContainmentEList;
import org.eclipse.emf.ecore.util.EObjectResolvingEList;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.util.InternalEList;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Structural Variation</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getVariationId <em>Variation Id</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getFeatures <em>Features</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getCount <em>Count</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getFirstTimestamp <em>First Timestamp</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getLastTimestamp <em>Last Timestamp</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getContainer <em>Container</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getLogicalFeatures <em>Logical Features</em>}</li>
 *   <li>{@link es.um.uschema.USchema.impl.StructuralVariationImpl#getStructuralFeatures <em>Structural Features</em>}</li>
 * </ul>
 *
 * @generated
 */
public class StructuralVariationImpl extends MinimalEObjectImpl.Container implements StructuralVariation {
  /**
   * The default value of the '{@link #getVariationId() <em>Variation Id</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getVariationId()
   * @generated
   * @ordered
   */
  protected static final int VARIATION_ID_EDEFAULT = 0;

  /**
   * The cached value of the '{@link #getVariationId() <em>Variation Id</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getVariationId()
   * @generated
   * @ordered
   */
  protected int variationId = VARIATION_ID_EDEFAULT;

  /**
   * The cached value of the '{@link #getFeatures() <em>Features</em>}' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getFeatures()
   * @generated
   * @ordered
   */
  protected EList<Feature> features;

  /**
   * The default value of the '{@link #getCount() <em>Count</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getCount()
   * @generated
   * @ordered
   */
  protected static final long COUNT_EDEFAULT = 0L;

  /**
   * The cached value of the '{@link #getCount() <em>Count</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getCount()
   * @generated
   * @ordered
   */
  protected long count = COUNT_EDEFAULT;

  /**
   * The default value of the '{@link #getFirstTimestamp() <em>First Timestamp</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getFirstTimestamp()
   * @generated
   * @ordered
   */
  protected static final long FIRST_TIMESTAMP_EDEFAULT = 0L;

  /**
   * The cached value of the '{@link #getFirstTimestamp() <em>First Timestamp</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getFirstTimestamp()
   * @generated
   * @ordered
   */
  protected long firstTimestamp = FIRST_TIMESTAMP_EDEFAULT;

  /**
   * The default value of the '{@link #getLastTimestamp() <em>Last Timestamp</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getLastTimestamp()
   * @generated
   * @ordered
   */
  protected static final long LAST_TIMESTAMP_EDEFAULT = 0L;

  /**
   * The cached value of the '{@link #getLastTimestamp() <em>Last Timestamp</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getLastTimestamp()
   * @generated
   * @ordered
   */
  protected long lastTimestamp = LAST_TIMESTAMP_EDEFAULT;

  /**
   * The cached value of the '{@link #getLogicalFeatures() <em>Logical Features</em>}' reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getLogicalFeatures()
   * @generated
   * @ordered
   */
  protected EList<LogicalFeature> logicalFeatures;

  /**
   * The cached value of the '{@link #getStructuralFeatures() <em>Structural Features</em>}' reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getStructuralFeatures()
   * @generated
   * @ordered
   */
  protected EList<StructuralFeature> structuralFeatures;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected StructuralVariationImpl() {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass() {
    return USchemaPackage.Literals.STRUCTURAL_VARIATION;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public int getVariationId() {
    return variationId;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setVariationId(int newVariationId) {
    int oldVariationId = variationId;
    variationId = newVariationId;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.STRUCTURAL_VARIATION__VARIATION_ID, oldVariationId, variationId));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<Feature> getFeatures() {
    if (features == null) {
      features = new EObjectContainmentEList<Feature>(Feature.class, this, USchemaPackage.STRUCTURAL_VARIATION__FEATURES);
    }
    return features;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public long getCount() {
    return count;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setCount(long newCount) {
    long oldCount = count;
    count = newCount;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.STRUCTURAL_VARIATION__COUNT, oldCount, count));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public long getFirstTimestamp() {
    return firstTimestamp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setFirstTimestamp(long newFirstTimestamp) {
    long oldFirstTimestamp = firstTimestamp;
    firstTimestamp = newFirstTimestamp;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.STRUCTURAL_VARIATION__FIRST_TIMESTAMP, oldFirstTimestamp, firstTimestamp));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public long getLastTimestamp() {
    return lastTimestamp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setLastTimestamp(long newLastTimestamp) {
    long oldLastTimestamp = lastTimestamp;
    lastTimestamp = newLastTimestamp;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.STRUCTURAL_VARIATION__LAST_TIMESTAMP, oldLastTimestamp, lastTimestamp));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public SchemaType getContainer() {
    if (eContainerFeatureID() != USchemaPackage.STRUCTURAL_VARIATION__CONTAINER) return null;
    return (SchemaType)eInternalContainer();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetContainer(SchemaType newContainer, NotificationChain msgs) {
    msgs = eBasicSetContainer((InternalEObject)newContainer, USchemaPackage.STRUCTURAL_VARIATION__CONTAINER, msgs);
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setContainer(SchemaType newContainer) {
    if (newContainer != eInternalContainer() || (eContainerFeatureID() != USchemaPackage.STRUCTURAL_VARIATION__CONTAINER && newContainer != null)) {
      if (EcoreUtil.isAncestor(this, newContainer))
        throw new IllegalArgumentException("Recursive containment not allowed for " + toString());
      NotificationChain msgs = null;
      if (eInternalContainer() != null)
        msgs = eBasicRemoveFromContainer(msgs);
      if (newContainer != null)
        msgs = ((InternalEObject)newContainer).eInverseAdd(this, USchemaPackage.SCHEMA_TYPE__VARIATIONS, SchemaType.class, msgs);
      msgs = basicSetContainer(newContainer, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, USchemaPackage.STRUCTURAL_VARIATION__CONTAINER, newContainer, newContainer));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<LogicalFeature> getLogicalFeatures() {
    if (logicalFeatures == null) {
      logicalFeatures = new EObjectResolvingEList<LogicalFeature>(LogicalFeature.class, this, USchemaPackage.STRUCTURAL_VARIATION__LOGICAL_FEATURES);
    }
    return logicalFeatures;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EList<StructuralFeature> getStructuralFeatures() {
    if (structuralFeatures == null) {
      structuralFeatures = new EObjectResolvingEList<StructuralFeature>(StructuralFeature.class, this, USchemaPackage.STRUCTURAL_VARIATION__STRUCTURAL_FEATURES);
    }
    return structuralFeatures;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eInverseAdd(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
    switch (featureID) {
      case USchemaPackage.STRUCTURAL_VARIATION__CONTAINER:
        if (eInternalContainer() != null)
          msgs = eBasicRemoveFromContainer(msgs);
        return basicSetContainer((SchemaType)otherEnd, msgs);
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
      case USchemaPackage.STRUCTURAL_VARIATION__FEATURES:
        return ((InternalEList<?>)getFeatures()).basicRemove(otherEnd, msgs);
      case USchemaPackage.STRUCTURAL_VARIATION__CONTAINER:
        return basicSetContainer(null, msgs);
    }
    return super.eInverseRemove(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eBasicRemoveFromContainerFeature(NotificationChain msgs) {
    switch (eContainerFeatureID()) {
      case USchemaPackage.STRUCTURAL_VARIATION__CONTAINER:
        return eInternalContainer().eInverseRemove(this, USchemaPackage.SCHEMA_TYPE__VARIATIONS, SchemaType.class, msgs);
    }
    return super.eBasicRemoveFromContainerFeature(msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType) {
    switch (featureID) {
      case USchemaPackage.STRUCTURAL_VARIATION__VARIATION_ID:
        return getVariationId();
      case USchemaPackage.STRUCTURAL_VARIATION__FEATURES:
        return getFeatures();
      case USchemaPackage.STRUCTURAL_VARIATION__COUNT:
        return getCount();
      case USchemaPackage.STRUCTURAL_VARIATION__FIRST_TIMESTAMP:
        return getFirstTimestamp();
      case USchemaPackage.STRUCTURAL_VARIATION__LAST_TIMESTAMP:
        return getLastTimestamp();
      case USchemaPackage.STRUCTURAL_VARIATION__CONTAINER:
        return getContainer();
      case USchemaPackage.STRUCTURAL_VARIATION__LOGICAL_FEATURES:
        return getLogicalFeatures();
      case USchemaPackage.STRUCTURAL_VARIATION__STRUCTURAL_FEATURES:
        return getStructuralFeatures();
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
      case USchemaPackage.STRUCTURAL_VARIATION__VARIATION_ID:
        setVariationId((Integer)newValue);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__FEATURES:
        getFeatures().clear();
        getFeatures().addAll((Collection<? extends Feature>)newValue);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__COUNT:
        setCount((Long)newValue);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__FIRST_TIMESTAMP:
        setFirstTimestamp((Long)newValue);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__LAST_TIMESTAMP:
        setLastTimestamp((Long)newValue);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__CONTAINER:
        setContainer((SchemaType)newValue);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__LOGICAL_FEATURES:
        getLogicalFeatures().clear();
        getLogicalFeatures().addAll((Collection<? extends LogicalFeature>)newValue);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__STRUCTURAL_FEATURES:
        getStructuralFeatures().clear();
        getStructuralFeatures().addAll((Collection<? extends StructuralFeature>)newValue);
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
      case USchemaPackage.STRUCTURAL_VARIATION__VARIATION_ID:
        setVariationId(VARIATION_ID_EDEFAULT);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__FEATURES:
        getFeatures().clear();
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__COUNT:
        setCount(COUNT_EDEFAULT);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__FIRST_TIMESTAMP:
        setFirstTimestamp(FIRST_TIMESTAMP_EDEFAULT);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__LAST_TIMESTAMP:
        setLastTimestamp(LAST_TIMESTAMP_EDEFAULT);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__CONTAINER:
        setContainer((SchemaType)null);
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__LOGICAL_FEATURES:
        getLogicalFeatures().clear();
        return;
      case USchemaPackage.STRUCTURAL_VARIATION__STRUCTURAL_FEATURES:
        getStructuralFeatures().clear();
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
      case USchemaPackage.STRUCTURAL_VARIATION__VARIATION_ID:
        return variationId != VARIATION_ID_EDEFAULT;
      case USchemaPackage.STRUCTURAL_VARIATION__FEATURES:
        return features != null && !features.isEmpty();
      case USchemaPackage.STRUCTURAL_VARIATION__COUNT:
        return count != COUNT_EDEFAULT;
      case USchemaPackage.STRUCTURAL_VARIATION__FIRST_TIMESTAMP:
        return firstTimestamp != FIRST_TIMESTAMP_EDEFAULT;
      case USchemaPackage.STRUCTURAL_VARIATION__LAST_TIMESTAMP:
        return lastTimestamp != LAST_TIMESTAMP_EDEFAULT;
      case USchemaPackage.STRUCTURAL_VARIATION__CONTAINER:
        return getContainer() != null;
      case USchemaPackage.STRUCTURAL_VARIATION__LOGICAL_FEATURES:
        return logicalFeatures != null && !logicalFeatures.isEmpty();
      case USchemaPackage.STRUCTURAL_VARIATION__STRUCTURAL_FEATURES:
        return structuralFeatures != null && !structuralFeatures.isEmpty();
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
    result.append(" (variationId: ");
    result.append(variationId);
    result.append(", count: ");
    result.append(count);
    result.append(", firstTimestamp: ");
    result.append(firstTimestamp);
    result.append(", lastTimestamp: ");
    result.append(lastTimestamp);
    result.append(')');
    return result.toString();
  }

} //StructuralVariationImpl
