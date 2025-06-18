/**
 */
package es.um.uschema.USchema;


/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Entity Type</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.EntityType#isRoot <em>Root</em>}</li>
 * </ul>
 *
 * @see es.um.uschema.USchema.USchemaPackage#getEntityType()
 * @model
 * @generated
 */
public interface EntityType extends SchemaType {
  /**
   * Returns the value of the '<em><b>Root</b></em>' attribute.
   * The default value is <code>"false"</code>.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Root</em>' attribute.
   * @see #setRoot(boolean)
   * @see es.um.uschema.USchema.USchemaPackage#getEntityType_Root()
   * @model default="false"
   * @generated
   */
  boolean isRoot();

  /**
   * Sets the value of the '{@link es.um.uschema.USchema.EntityType#isRoot <em>Root</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Root</em>' attribute.
   * @see #isRoot()
   * @generated
   */
  void setRoot(boolean value);

} // EntityType
