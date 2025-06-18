/**
 */
package es.um.uschema.USchema;

import org.eclipse.emf.common.util.EList;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Key</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.Key#getAttributes <em>Attributes</em>}</li>
 * </ul>
 *
 * @see es.um.uschema.USchema.USchemaPackage#getKey()
 * @model
 * @generated
 */
public interface Key extends LogicalFeature {
  /**
   * Returns the value of the '<em><b>Attributes</b></em>' reference list.
   * The list contents are of type {@link es.um.uschema.USchema.Attribute}.
   * It is bidirectional and its opposite is '{@link es.um.uschema.USchema.Attribute#getKey <em>Key</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Attributes</em>' reference list.
   * @see es.um.uschema.USchema.USchemaPackage#getKey_Attributes()
   * @see es.um.uschema.USchema.Attribute#getKey
   * @model opposite="key"
   * @generated
   */
  EList<Attribute> getAttributes();

} // Key
