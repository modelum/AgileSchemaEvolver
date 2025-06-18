/**
 */
package es.um.uschema.USchema;


/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>PList</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.PList#getElementType <em>Element Type</em>}</li>
 * </ul>
 *
 * @see es.um.uschema.USchema.USchemaPackage#getPList()
 * @model
 * @generated
 */
public interface PList extends DataType {
  /**
   * Returns the value of the '<em><b>Element Type</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Element Type</em>' containment reference.
   * @see #setElementType(DataType)
   * @see es.um.uschema.USchema.USchemaPackage#getPList_ElementType()
   * @model containment="true" required="true"
   * @generated
   */
  DataType getElementType();

  /**
   * Sets the value of the '{@link es.um.uschema.USchema.PList#getElementType <em>Element Type</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Element Type</em>' containment reference.
   * @see #getElementType()
   * @generated
   */
  void setElementType(DataType value);

} // PList
