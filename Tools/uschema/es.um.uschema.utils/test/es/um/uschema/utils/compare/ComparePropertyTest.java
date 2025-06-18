package es.um.uschema.utils.compare;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

import es.um.uschema.USchema.Reference;
import es.um.uschema.USchema.StructuralVariation;
import es.um.uschema.utils.USchemaFactory;

public class ComparePropertyTest
{
  private USchemaFactory f;
  private CompareFeature cFeature;
  private CompareLogicalFeature cLogicalFeat;
  private CompareStructuralFeature cStructuralFeat;
  private CompareAttribute cAttribute;
  private CompareReference cReference;
  private CompareAggregate cAggregate;

  @Before
  public void setUp()
  {
    f = new USchemaFactory();
    cFeature = new CompareFeature();
    cLogicalFeat = new CompareLogicalFeature();
    cStructuralFeat = new CompareStructuralFeature();
    cAggregate = new CompareAggregate();
    cReference = new CompareReference();
    cAttribute = new CompareAttribute();
  }

  /**
   * TestProperty SHOULD check: Name and LogicalFeature/StructuralFeature comparison.
   */
  @Test
  public void testFeature()
  {
    assertFalse(cFeature.compare(null, null));

    assertTrue(cFeature.compare(f.createAttribute("name", f.createNull()), f.createAttribute("name", f.createNull())));
    assertFalse(cFeature.compare(f.createAttribute("name1", f.createNull()), f.createAttribute("name2", f.createNull())));

    assertFalse(cFeature.compare(f.createAttribute("name", f.createPrimitiveType("type1")), f.createAttribute("name", f.createPrimitiveType("type2"))));
    assertFalse(cFeature.compare(f.createAttribute("name", null), f.createAggregate("name", 0, 0)));
  }

  /**
   * TestLogicalFeature SHOULD check: UpperBound, LowerBound and Reference/Aggregate comparison
   * TestLogicalFeature SHOULD NOT check: Name
   */
  @Test
  public void testLogicalFeature()
  {
    assertFalse(cLogicalFeat.compare(null, null));
    //TODO: Test keys

    assertTrue(cLogicalFeat.compare(f.createReference("name", 0, 0, null), f.createReference("name", 0, 0, null)));
    assertTrue(cLogicalFeat.compare(f.createReference("name1", 0, 0, null), f.createReference("name2", 0, 0, null)));
    assertFalse(cLogicalFeat.compare(f.createReference("name", 1, 0, null), f.createReference("name", 0, 0, null)));
    assertFalse(cLogicalFeat.compare(f.createReference("name", 0, 1, null), f.createReference("name", 0, 0, null)));
  }

  /**
   * TestStructuralFeature SHOULD check: UpperBound, LowerBound and Reference/Aggregate comparison
   * TestStructuralFeature SHOULD NOT check: Name
   */
  @Test
  public void testStructuralFeature()
  {
    assertFalse(cStructuralFeat.compare(null, null));

    assertTrue(cStructuralFeat.compare(f.createAggregate("name"), f.createAggregate("name", 0, 0)));
    assertTrue(cStructuralFeat.compare(f.createAggregate("name1"), f.createAggregate("name2", 0, 0)));
    assertFalse(cStructuralFeat.compare(f.createAggregate("name", 0, 1), f.createAggregate("name", 0, 0)));
    assertFalse(cStructuralFeat.compare(f.createAggregate("name", 1, 0), f.createAggregate("name", 0, 0)));

    //TODO: Test attributes
  }

  /**
   * TestReference SHOULD check: LowerBound, UpperBound, Opposite, RefsTo, IsFeaturedBy
   * TestReference SHOULD NOT check: Name
   */
  @Test
  public void testReference()
  {
    assertFalse(cReference.compare(null, null));

    assertTrue(cReference.compare(f.createReference("name1", 1, 1, null), f.createReference("name2", 1, 1, null)));
    assertFalse(cReference.compare(f.createReference("name1", 1, 1, null), f.createReference("name2", 0, 0, null)));

    assertTrue(cReference.compare(f.createReference(null, 0, 0, f.createEntityType("entity")), f.createReference(null, 0, 0, f.createEntityType("entity"))));
    assertFalse(cReference.compare(f.createReference(null, 0, 0, f.createEntityType("entity1")), f.createReference(null, 0, 0, f.createEntityType("entity2"))));

    Reference opp1 = f.createReference("name1");
    Reference opp2 = f.createReference("name2");
    Reference ref1 = f.createReference(null);
    ref1.setOpposite(opp1);
    Reference ref2 = f.createReference(null);
    ref2.setOpposite(opp1);

    assertTrue(cReference.compare(ref1, ref2));
    ref2.setOpposite(opp2);
    assertFalse(cReference.compare(ref1, ref2));

    ref1.setOpposite(null);
    ref2.setOpposite(null);
    StructuralVariation var = f.createStructuralVariation(1);
    ref1.getIsFeaturedBy().add(var);

    assertFalse(cReference.compare(ref1, ref2));
    ref2.getIsFeaturedBy().add(var);
    assertTrue(cReference.compare(ref1, ref2));
  }

  /**
   * TestAggregate SHOULD check: UpperBound, LowerBound, Aggregates
   * TestAggregate SHOULD NOT check: Name
   */
  @Test
  public void testAggregate()
  {
    assertFalse(cAggregate.compare(null, null));

    assertTrue(cAggregate.compare(f.createAggregate("name1", 1, 1), f.createAggregate("name2", 1, 1)));
    assertFalse(cAggregate.compare(f.createAggregate("name1", 1, 1), f.createAggregate("name2", 0, 0)));

    assertTrue(cAggregate.compare(f.createAggregate(null, 0, 0, f.createStructuralVariation(2), f.createStructuralVariation(1), f.createStructuralVariation(3)),
        f.createAggregate(null, 0, 0, f.createStructuralVariation(1), f.createStructuralVariation(1), f.createStructuralVariation(1))));
    assertFalse(cAggregate.compare(f.createAggregate(null, 0, 0, f.createStructuralVariation(1), f.createStructuralVariation(2)),
        f.createAggregate(null, 0, 0, f.createStructuralVariation(3))));
  }

  /**
   * TestAttribute SHOULD check: Type
   * TestAggregate SHOULD NOT check: Name
   */
  @Test
  public void testAttribute()
  {
    assertFalse(cAttribute.compare(null, null));

    assertFalse(cAttribute.compare(f.createAttribute(null, f.createPrimitiveType("string")), null));
    assertFalse(cAttribute.compare(null,f.createAttribute(null, f.createPrimitiveType("string"))));

    assertFalse(cAttribute.compare(f.createAttribute("attr1", f.createPrimitiveType("string")), f.createAttribute("attr2", f.createPrimitiveType("int"))));
    assertTrue(cAttribute.compare(f.createAttribute("attr1", f.createPrimitiveType("string")), f.createAttribute("attr2", f.createPrimitiveType("string"))));
  }
}
