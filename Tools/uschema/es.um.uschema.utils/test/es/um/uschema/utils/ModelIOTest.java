package es.um.uschema.utils;

//import static org.junit.Assert.*;

import java.nio.file.Path;

import org.junit.Before;
import org.junit.Test;

import es.um.uschema.USchema.EntityType;
import es.um.uschema.USchema.StructuralVariation;
import es.um.uschema.USchema.USchema;

public class ModelIOTest
{
  private EcoreModelIO uSchemaIO;
  private Path modelPath = Path.of("../es.um.uschema.models/stackoverflow/stackoverflow.xmi");
  private USchemaSerializer serializer;
  private USchemaFactory factory;

  @Before
  public void setUp()
  {
    uSchemaIO = new EcoreModelIO();
    serializer = new USchemaSerializer();
    factory = new USchemaFactory();
  }

  @Test
  public void testOpenWrite()
  {
    USchema schema = uSchemaIO.load(USchema.class, modelPath);
    System.out.println(serializer.serialize(schema));
    uSchemaIO.write(schema, Path.of("../es.um.uschema.models/test.xmi"));
  }

  @Test
  public void testWrite()
  {
    USchema schema = factory.createUSchema("SchemaName");
    EntityType eType = factory.createEntityType("EntityType", true);
    schema.getEntities().add(eType);
    StructuralVariation var = factory.createStructuralVariation(1);
    eType.getVariations().add(var);
    var.getFeatures().add(factory.createAttribute("Attr1", factory.createPrimitiveType("String")));
    var.getFeatures().add(factory.createAttribute("Attr2", factory.createPrimitiveType("Number")));

    System.out.println(serializer.serialize(schema));
    uSchemaIO.write(schema, Path.of("../es.um.uschema.models/test.xmi"));
  }
}
