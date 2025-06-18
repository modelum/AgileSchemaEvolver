package es.um.uschema.utils.custom.compare;

import es.um.uschema.USchema.Key;
import es.um.uschema.USchema.LogicalFeature;
import es.um.uschema.USchema.Reference;

public class CompareLogicalFeature extends Comparator<LogicalFeature>
{
  @Override
  public boolean compare(LogicalFeature f1, LogicalFeature f2)
  {
    if (super.checkNulls(f1, f2))
      return false;

    if (super.checkEquals(f1, f2))
      return true;

    if (f1 instanceof Key && f2 instanceof Key)
      return new CompareKey().compare((Key)f1, (Key)f2);

    if (f1 instanceof Reference && f2 instanceof Reference)
      return new CompareReference().compare((Reference)f1, (Reference)f2);

    return false;
  }
}
