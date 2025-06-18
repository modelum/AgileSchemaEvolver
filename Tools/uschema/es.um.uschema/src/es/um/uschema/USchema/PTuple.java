/**
 */
package es.um.uschema.USchema;

import org.eclipse.emf.common.util.EList;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>PTuple</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link es.um.uschema.USchema.PTuple#getElements <em>Elements</em>}</li>
 * </ul>
 *
 * @see es.um.uschema.USchema.USchemaPackage#getPTuple()
 * @model
 * @generated
 */
public interface PTuple extends DataType {
  /**
   * Returns the value of the '<em><b>Elements</b></em>' containment reference list.
   * The list contents are of type {@link es.um.uschema.USchema.DataType}.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Elements</em>' containment reference list.
   * @see es.um.uschema.USchema.USchemaPackage#getPTuple_Elements()
   * @model containment="true" required="true"
   * @generated
   */
  EList<DataType> getElements();

} // PTuple
