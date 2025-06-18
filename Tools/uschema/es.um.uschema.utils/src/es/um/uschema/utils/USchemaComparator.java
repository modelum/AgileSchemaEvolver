package es.um.uschema.utils;

import java.nio.file.Path;

import es.um.uschema.USchema.USchemaPackage;
import es.um.uschema.USchema.USchema;
import es.um.uschema.utils.compare.CompareUSchema;

public class USchemaComparator
{
  public boolean compare(Path model1Path, Path model2Path)
  {
    EcoreModelIO uSchemaIO = new EcoreModelIO(USchemaPackage.eINSTANCE);
    USchema schema1 = uSchemaIO.load(USchema.class, model1Path);
    USchema schema2 = uSchemaIO.load(USchema.class, model2Path);

    return compare(schema1, schema2);
  }

  public boolean compare(USchema schema1, USchema schema2)
  {
    return new CompareUSchema().compare(schema1, schema2);
  }
}
