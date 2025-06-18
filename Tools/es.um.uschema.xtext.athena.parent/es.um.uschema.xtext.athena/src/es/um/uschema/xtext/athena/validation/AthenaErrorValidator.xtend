package es.um.uschema.xtext.athena.validation

import org.eclipse.xtext.validation.Check
import es.um.uschema.xtext.athena.athena.AthenaPackage.Literals
import es.um.uschema.xtext.athena.athena.SchemaTypeDecl
import es.um.uschema.xtext.athena.athena.RelationshipDecl
import es.um.uschema.xtext.athena.athena.EntityDecl
import es.um.uschema.xtext.athena.athena.SimpleReferenceTarget
import es.um.uschema.xtext.athena.athena.AthenaSchema
import es.um.uschema.xtext.athena.athena.VariationDecl
import es.um.uschema.xtext.athena.athena.SimpleFeature
import es.um.uschema.xtext.athena.athena.SinglePrimitiveType
import es.um.uschema.xtext.athena.utils.ExpressionSimplifier
import es.um.uschema.xtext.athena.athena.Feature
import es.um.uschema.xtext.athena.utils.FeatureUtils
import es.um.uschema.xtext.athena.athena.TopLevelStructureDefiningElementDeclRef
import org.eclipse.xtext.EcoreUtil2
import es.um.uschema.xtext.athena.athena.VariationDeclRef
import java.util.ArrayList
import es.um.uschema.xtext.athena.athena.SQLReferenceTarget
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject
import es.um.uschema.xtext.athena.athena.SimpleAggregateTarget

class AthenaErrorValidator extends AbstractAthenaValidator
{
  @Inject
  IQualifiedNameProvider nameProvider

  val simplifier = new ExpressionSimplifier(false)

  /**
   * @Check: A schema is not empty.
   */
  @Check
  def checkNoEmptySchema(AthenaSchema schema)
  {
    if (schema.featureSets.empty && schema.entities.empty && schema.relationships.empty)
      error("Empty schema: \""+ schema.id.name + "\"", Literals.ATHENA_SCHEMA__ID)
  }

  /**
   * @Check: A crossreference is correctly solved.
   */
  @Check
  def checkKnownCrossreference(TopLevelStructureDefiningElementDeclRef ref)
  {
    val rootElement = EcoreUtil2.getRootContainer(ref) as AthenaSchema
    val qualifiedRoots = new ArrayList<String>()
    qualifiedRoots.addAll(rootElement.imports.map[imported | nameProvider.getFullyQualifiedName(imported.importedNamespace).toString])
    qualifiedRoots.add(nameProvider.getFullyQualifiedName(rootElement).toString)
    val rootRef = EcoreUtil2.getRootContainer(ref.ref)

    if (!qualifiedRoots.contains(nameProvider.getFullyQualifiedName(rootRef).toString))
      error("Could not solve reference to \"" + ref.ref.name + "\"", Literals.TOP_LEVEL_STRUCTURE_DEFINING_ELEMENT_DECL_REF__REF)
  }

  /**
   * @Check: A crossreference is correctly solved.
   */
  @Check
  def checkKnownCrossreference(VariationDeclRef ref)
  {
    val rootElement = EcoreUtil2.getRootContainer(ref) as AthenaSchema
    val qualifiedRoots = new ArrayList<String>()
    qualifiedRoots.addAll(rootElement.imports.map[imported | nameProvider.getFullyQualifiedName(imported.importedNamespace).toString])
    qualifiedRoots.add(nameProvider.getFullyQualifiedName(rootElement).toString)
    val rootRef = EcoreUtil2.getRootContainer(ref.ref)

    if (!qualifiedRoots.contains(nameProvider.getFullyQualifiedName(rootRef).toString))
      error("Could not solve reference to \"" + ref.ref.name + "\"", Literals.VARIATION_DECL_REF__REF)
  }

  /**
   * @Check: A crossreference is correctly solved.
   */
  @Check
  def checkKnownCrossreference(SQLReferenceTarget ref)
  {
    val rootElement = EcoreUtil2.getRootContainer(ref) as AthenaSchema
    val qualifiedRoots = new ArrayList<String>()
    qualifiedRoots.addAll(rootElement.imports.map[imported | nameProvider.getFullyQualifiedName(imported.importedNamespace).toString])
    qualifiedRoots.add(nameProvider.getFullyQualifiedName(rootElement).toString)
    val rootRef = EcoreUtil2.getRootContainer(ref.ref)

    if (!qualifiedRoots.contains(nameProvider.getFullyQualifiedName(rootRef).toString))
      error("Could not solve reference to \"" + ref.ref.name + "\"", Literals.SQL_REFERENCE_TARGET__REF)
  }

  /**
   * @Check: If a key feature has a type, it must be a single primitive type.
   * Example: +myKey: Reference
   */
  @Check
  def checkKeyIsSinglePrimitiveType(SimpleFeature sFeat)
  {
    if (sFeat.isKey && sFeat.type !== null && !(sFeat.type instanceof SinglePrimitiveType))
      error("Key feature \"" + sFeat.name + "\" can only be of a single primitive type", Literals.SIMPLE_FEATURE__NAME)
  }

  /**
   * @Check: An Entity does not have any Relationship parents.
   * Example: relationship r1; entity e1 :: r1
   */
  @Check
  def checkNoDifferentTypeParents(EntityDecl sType)
  {
    val SchemaTypeDecl t = sType.parents.findFirst[parent | parent instanceof RelationshipDecl]
    if (t !== null)
      error("\"" + sType.name + "\" cannot have Relationship parents", Literals.SCHEMA_TYPE_DECL__PARENTS, sType.parents.indexOf(t)
      )
  }

  /**
   * @Check: A Relationship does not have any Entity parents.
   * Example: entity e1; relationship r1 :: e1
   */
  @Check
  def checkNoDifferentTypeParents(RelationshipDecl sType)
  {
    val SchemaTypeDecl t = sType.parents.findFirst[parent | parent instanceof EntityDecl]
    if(t !== null)
      error("\"" + sType.name + "\" cannot have Entity parents", Literals.SCHEMA_TYPE_DECL__PARENTS, sType.parents.indexOf(t)
      )
  }

  /**
   * @Check: A reference is not featured by any Entity, but a Relationship.
   * Example: myRef: ref<Entity1 feat Entity1.1>
   */
  @Check
  def checkNoReferenceIsFeaturedByEntityType(SimpleReferenceTarget ref)
  {
    if (ref.featuredBy !== null && ref.featuredBy.exists[o | o instanceof EntityDecl || (o instanceof VariationDecl && (o as VariationDecl).eContainer instanceof EntityDecl)])
      error("\"" + (ref.eContainer as SimpleFeature).name + "\" cannot be featured by an Entity or Entity variation", Literals.SIMPLE_REFERENCE_TARGET__FEATURED_BY)
  }

  /**
   * @Check: There are two features with the same name on a variation and its parent.
   * Example: entity e1 { common ${a: String} variation 1 ${a: Number}}
   */
  @Check
  def checkNoDuplicatedFeature(VariationDecl variation)
  {
    if (variation.structure === null)
      return

    val featsInVariation = simplifier.simplify(variation).features
    val featsInParent = simplifier.simplify(variation.eContainer as SchemaTypeDecl).features

    for (Feature feat : featsInVariation)
    {
      val featName = FeatureUtils.getName(feat)
      if (featsInParent.exists[feat2 | featName.equals(FeatureUtils.getName(feat2))])
        error("Duplicated feature in parent: \"" + featName+ "\"", Literals.VARIATION_DECL__NAME)
    }
  }

  /**
   * @Check: A key is not optional nor unique.
   * Example: +_id: String?
   */
  @Check
  def checkNoOptionalUniqueKey(SimpleFeature sFeature)
  {
    if (sFeature.isKey && (sFeature.optional || sFeature.unique))
      error("A key cannot be marked as optional or unique", Literals.SIMPLE_FEATURE__NAME)
  }

  /**
   * @Check: An aggregate with variations does only contain variations of the same schema type.
   * Example: myAggr: Aggr<Aggr1.1, Aggr2.33>+
   */
  @Check
  def checkAggregateConsistency(SimpleAggregateTarget aggr)
  {
    if (aggr.aggr !== null && aggr.aggr.size > 1
      && aggr.aggr.forall[v | v instanceof VariationDecl]
      && aggr.aggr.map[v | (v.eContainer as SchemaTypeDecl).name].toSet.size != 1)
      error("Aggregate variations must belong to the same entity", Literals.SIMPLE_AGGREGATE_TARGET__AGGR)
  }
}
