/**
 */
package es.um.uschema.USchema;


/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Structural Feature</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.StructuralFeature#isOptional <em>Optional</em>}</li>
 * </ul>
 *
 * @see es.um.uschema.USchema.USchemaPackage#getStructuralFeature()
 * @model abstract="true"
 * @generated
 */
public interface StructuralFeature extends Feature {
  /**
   * Returns the value of the '<em><b>Optional</b></em>' attribute.
   * The default value is <code>"false"</code>.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Optional</em>' attribute.
   * @see #setOptional(boolean)
   * @see es.um.uschema.USchema.USchemaPackage#getStructuralFeature_Optional()
   * @model default="false"
   * @generated
   */
  boolean isOptional();

  /**
   * Sets the value of the '{@link es.um.uschema.USchema.StructuralFeature#isOptional <em>Optional</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Optional</em>' attribute.
   * @see #isOptional()
   * @generated
   */
  void setOptional(boolean value);

} // StructuralFeature
