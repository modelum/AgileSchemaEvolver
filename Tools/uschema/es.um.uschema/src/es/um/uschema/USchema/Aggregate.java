/**
 */
package es.um.uschema.USchema;

import org.eclipse.emf.common.util.EList;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Aggregate</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.Aggregate#getAggregates <em>Aggregates</em>}</li>
 *   <li>{@link es.um.uschema.USchema.Aggregate#getUpperBound <em>Upper Bound</em>}</li>
 *   <li>{@link es.um.uschema.USchema.Aggregate#getLowerBound <em>Lower Bound</em>}</li>
 * </ul>
 *
 * @see es.um.uschema.USchema.USchemaPackage#getAggregate()
 * @model
 * @generated
 */
public interface Aggregate extends StructuralFeature {
  /**
   * Returns the value of the '<em><b>Aggregates</b></em>' reference list.
   * The list contents are of type {@link es.um.uschema.USchema.StructuralVariation}.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Aggregates</em>' reference list.
   * @see es.um.uschema.USchema.USchemaPackage#getAggregate_Aggregates()
   * @model required="true"
   * @generated
   */
  EList<StructuralVariation> getAggregates();

  /**
   * Returns the value of the '<em><b>Upper Bound</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Upper Bound</em>' attribute.
   * @see #setUpperBound(int)
   * @see es.um.uschema.USchema.USchemaPackage#getAggregate_UpperBound()
   * @model
   * @generated
   */
  int getUpperBound();

  /**
   * Sets the value of the '{@link es.um.uschema.USchema.Aggregate#getUpperBound <em>Upper Bound</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Upper Bound</em>' attribute.
   * @see #getUpperBound()
   * @generated
   */
  void setUpperBound(int value);

  /**
   * Returns the value of the '<em><b>Lower Bound</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Lower Bound</em>' attribute.
   * @see #setLowerBound(int)
   * @see es.um.uschema.USchema.USchemaPackage#getAggregate_LowerBound()
   * @model
   * @generated
   */
  int getLowerBound();

  /**
   * Sets the value of the '{@link es.um.uschema.USchema.Aggregate#getLowerBound <em>Lower Bound</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Lower Bound</em>' attribute.
   * @see #getLowerBound()
   * @generated
   */
  void setLowerBound(int value);

} // Aggregate
