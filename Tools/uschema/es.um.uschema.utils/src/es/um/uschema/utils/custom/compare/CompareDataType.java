package es.um.uschema.utils.custom.compare;

import es.um.uschema.USchema.DataType;
import es.um.uschema.USchema.Null;
import es.um.uschema.USchema.PList;
import es.um.uschema.USchema.PMap;
import es.um.uschema.USchema.PSet;
import es.um.uschema.USchema.PTuple;
import es.um.uschema.USchema.PrimitiveType;

public class CompareDataType extends Comparator<DataType>
{
  @Override
  public boolean compare(DataType t1, DataType t2)
  {
    if (super.checkNulls(t1, t2))
      return false;

    if (super.checkEquals(t1, t2))
      return true;

    if (t1 instanceof Null && t2 instanceof Null)
      return new CompareNull().compare((Null)t1, (Null)t2);

    if (t1 instanceof PrimitiveType && t2 instanceof PrimitiveType)
      return new ComparePrimitiveType().compare((PrimitiveType)t1, (PrimitiveType)t2);

    if (t1 instanceof PMap && t2 instanceof PMap)
      return new ComparePMap().compare((PMap)t1, (PMap)t2);

    if (t1 instanceof PTuple && t2 instanceof PTuple)
      return new ComparePTuple().compare((PTuple)t1, (PTuple)t2);

    if (t1 instanceof PList && t2 instanceof PList)
      return new ComparePList().compare((PList)t1, (PList)t2);

    if (t1 instanceof PSet && t2 instanceof PSet)
      return new ComparePSet().compare((PSet)t1, (PSet)t2);

    return false;
  }
}
