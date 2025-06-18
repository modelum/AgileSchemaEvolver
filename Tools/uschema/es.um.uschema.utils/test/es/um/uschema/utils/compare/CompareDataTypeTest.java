package es.um.uschema.utils.compare;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

import es.um.uschema.utils.USchemaFactory;

public class CompareDataTypeTest
{
  private USchemaFactory f;
  private ComparePrimitiveType cPrimitiveType;
  private ComparePMap cPMap;
  private ComparePTuple cPTuple;
  private ComparePList cPList;
  private ComparePSet cPSet;
  private CompareNull cNull;

  @Before
  public void setUp()
  {
    f = new USchemaFactory();
    cPrimitiveType = new ComparePrimitiveType();
    cPMap = new ComparePMap();
    cPTuple = new ComparePTuple();
    cPList = new ComparePList();
    cPSet = new ComparePSet();
    cNull = new CompareNull();
  }

  @Test
  public void testPrimitiveType()
  {
    assertFalse(cPrimitiveType.compare(null, null));

    assertFalse(cPrimitiveType.compare(f.createPrimitiveType("string"), null));
    assertFalse(cPrimitiveType.compare(null, f.createPrimitiveType("string")));

    assertFalse(cPrimitiveType.compare(f.createPrimitiveType(null), f.createPrimitiveType("string")));
    assertFalse(cPrimitiveType.compare(f.createPrimitiveType("string"), f.createPrimitiveType(null)));

    assertTrue(cPrimitiveType.compare(f.createPrimitiveType("null"), f.createPrimitiveType("null")));
    assertTrue(cPrimitiveType.compare(f.createPrimitiveType("string"), f.createPrimitiveType("string")));
  }

  @Test
  public void testNull()
  {
    assertFalse(cNull.compare(null, null));
    assertFalse(cNull.compare(f.createNull(), null));
    assertTrue(cNull.compare(f.createNull(), f.createNull()));
  }

  @Test
  public void testPMap()
  {
    assertFalse(cPMap.compare(null, null));

    assertFalse(cPMap.compare(f.createPMap(null, null), null));
    assertFalse(cPMap.compare(null, f.createPMap(null, null)));

    assertFalse(cPMap.compare(f.createPMap(f.createPrimitiveType("string"), null), f.createPMap(f.createPrimitiveType("int"), null)));
    assertTrue(cPMap.compare(f.createPMap(f.createPrimitiveType("bool"), null), f.createPMap(f.createPrimitiveType("bool"), null)));

    assertFalse(cPMap.compare(f.createPMap(null, f.createPSet(f.createPrimitiveType("string"))), f.createPMap(null, f.createPSet(f.createPrimitiveType("int")))));
    assertTrue(cPMap.compare(f.createPMap(null, f.createPSet(f.createPrimitiveType("bool"))), f.createPMap(null, f.createPSet(f.createPrimitiveType("bool")))));

    assertFalse(cPMap.compare(f.createPMap(f.createPrimitiveType("bool"), f.createPSet(f.createPrimitiveType("string"))), f.createPMap(f.createPrimitiveType("bool"), f.createPSet(f.createPrimitiveType("int")))));
    assertTrue(cPMap.compare(f.createPMap(f.createPrimitiveType("int"), f.createPSet(f.createPrimitiveType("bool"))), f.createPMap(f.createPrimitiveType("int"), f.createPSet(f.createPrimitiveType("bool")))));
  }

  @Test
  public void testPTuple()
  {
    assertFalse(cPTuple.compare(null, null));

    assertFalse(cPTuple.compare(f.createPTuple(f.createPrimitiveType("string")), null));
    assertFalse(cPTuple.compare(null, f.createPTuple(f.createPrimitiveType("string"))));

    assertFalse(cPTuple.compare(f.createPTuple(f.createPrimitiveType("string")), f.createPTuple(f.createPrimitiveType("string"), f.createPrimitiveType("string"))));
    assertTrue(cPTuple.compare(f.createPTuple(f.createPrimitiveType("string")), f.createPTuple(f.createPrimitiveType("string"))));

    assertTrue(cPTuple.compare(f.createPTuple(f.createPrimitiveType("string"), f.createPrimitiveType("int")), f.createPTuple(f.createPrimitiveType("string"), f.createPrimitiveType("int"))));
    assertTrue(cPTuple.compare(f.createPTuple(f.createPrimitiveType("string"), f.createPrimitiveType("int")), f.createPTuple(f.createPrimitiveType("int"), f.createPrimitiveType("string"))));

    assertFalse(cPTuple.compare(f.createPTuple(f.createPSet(f.createPList(f.createPrimitiveType("bool"))), f.createPTuple(f.createPrimitiveType("string"))),
        f.createPTuple(f.createPrimitiveType("int"), f.createPSet(f.createPList(f.createPrimitiveType("bool"))), f.createPrimitiveType("string"))));
    assertFalse(cPTuple.compare(f.createPTuple(f.createPSet(f.createPList(f.createPrimitiveType("bool")))), f.createPTuple(f.createPList(f.createPSet(f.createPrimitiveType("bool"))))));
    assertTrue(cPTuple.compare(f.createPTuple(f.createPSet(f.createPList(f.createPrimitiveType("bool")))), f.createPTuple(f.createPSet(f.createPList(f.createPrimitiveType("bool"))))));
  }

  @Test
  public void testPList()
  {
    assertFalse(cPList.compare(null, null));

    assertFalse(cPList.compare(f.createPList(f.createPrimitiveType("string")), null));
    assertFalse(cPList.compare(null, f.createPList(f.createPrimitiveType("string"))));

    assertFalse(cPList.compare(f.createPList(null), f.createPList(f.createPrimitiveType("string"))));
    assertFalse(cPList.compare(f.createPList(f.createPrimitiveType("string")), f.createPList(null)));

    assertFalse(cPList.compare(f.createPList(f.createPrimitiveType(null)), f.createPList(f.createPrimitiveType("string"))));
    assertFalse(cPList.compare(f.createPList(f.createPrimitiveType("string")), f.createPList(f.createPrimitiveType(null))));

    assertTrue(cPList.compare(f.createPList(f.createPrimitiveType("null")), f.createPList(f.createPrimitiveType("null"))));
    assertTrue(cPList.compare(f.createPList(f.createPrimitiveType("string")), f.createPList(f.createPrimitiveType("string"))));

    assertTrue(cPList.compare(f.createPList(f.createPSet(f.createPrimitiveType("null"))), f.createPList(f.createPSet(f.createPrimitiveType("null")))));
    assertTrue(cPList.compare(f.createPList(f.createPSet(f.createPrimitiveType("string"))), f.createPList(f.createPSet(f.createPrimitiveType("string")))));
  }

  @Test
  public void testPSet()
  {
    assertFalse(cPSet.compare(null, null));

    assertFalse(cPSet.compare(f.createPSet(f.createPrimitiveType("string")), null));
    assertFalse(cPSet.compare(null, f.createPSet(f.createPrimitiveType("string"))));

    assertFalse(cPSet.compare(f.createPSet(null), f.createPSet(f.createPrimitiveType("string"))));
    assertFalse(cPSet.compare(f.createPSet(f.createPrimitiveType("string")), f.createPSet(null)));

    assertFalse(cPSet.compare(f.createPSet(f.createPrimitiveType(null)), f.createPSet(f.createPrimitiveType("string"))));
    assertFalse(cPSet.compare(f.createPSet(f.createPrimitiveType("string")), f.createPSet(f.createPrimitiveType(null))));

    assertTrue(cPSet.compare(f.createPSet(f.createPrimitiveType("null")), f.createPSet(f.createPrimitiveType("null"))));
    assertTrue(cPSet.compare(f.createPSet(f.createPrimitiveType("string")), f.createPSet(f.createPrimitiveType("string"))));

    assertTrue(cPSet.compare(f.createPSet(f.createPList(f.createPrimitiveType("null"))), f.createPSet(f.createPList(f.createPrimitiveType("null")))));
    assertTrue(cPSet.compare(f.createPSet(f.createPList(f.createPrimitiveType("string"))), f.createPSet(f.createPList(f.createPrimitiveType("string")))));
  }
}
