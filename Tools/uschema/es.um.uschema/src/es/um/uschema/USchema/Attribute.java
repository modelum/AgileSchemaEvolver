/**
 */
package es.um.uschema.USchema;

import org.eclipse.emf.common.util.EList;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Attribute</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.Attribute#getType <em>Type</em>}</li>
 *   <li>{@link es.um.uschema.USchema.Attribute#getKey <em>Key</em>}</li>
 *   <li>{@link es.um.uschema.USchema.Attribute#getReferences <em>References</em>}</li>
 * </ul>
 *
 * @see es.um.uschema.USchema.USchemaPackage#getAttribute()
 * @model
 * @generated
 */
public interface Attribute extends StructuralFeature {
  /**
   * Returns the value of the '<em><b>Type</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Type</em>' containment reference.
   * @see #setType(DataType)
   * @see es.um.uschema.USchema.USchemaPackage#getAttribute_Type()
   * @model containment="true" required="true"
   * @generated
   */
  DataType getType();

  /**
   * Sets the value of the '{@link es.um.uschema.USchema.Attribute#getType <em>Type</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Type</em>' containment reference.
   * @see #getType()
   * @generated
   */
  void setType(DataType value);

  /**
   * Returns the value of the '<em><b>Key</b></em>' reference.
   * It is bidirectional and its opposite is '{@link es.um.uschema.USchema.Key#getAttributes <em>Attributes</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Key</em>' reference.
   * @see #setKey(Key)
   * @see es.um.uschema.USchema.USchemaPackage#getAttribute_Key()
   * @see es.um.uschema.USchema.Key#getAttributes
   * @model opposite="attributes"
   * @generated
   */
  Key getKey();

  /**
   * Sets the value of the '{@link es.um.uschema.USchema.Attribute#getKey <em>Key</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Key</em>' reference.
   * @see #getKey()
   * @generated
   */
  void setKey(Key value);

  /**
   * Returns the value of the '<em><b>References</b></em>' reference list.
   * The list contents are of type {@link es.um.uschema.USchema.Reference}.
   * It is bidirectional and its opposite is '{@link es.um.uschema.USchema.Reference#getAttributes <em>Attributes</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>References</em>' reference list.
   * @see es.um.uschema.USchema.USchemaPackage#getAttribute_References()
   * @see es.um.uschema.USchema.Reference#getAttributes
   * @model opposite="attributes"
   * @generated
   */
  EList<Reference> getReferences();

} // Attribute
