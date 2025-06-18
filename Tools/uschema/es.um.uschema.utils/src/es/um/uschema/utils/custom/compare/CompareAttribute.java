package es.um.uschema.utils.custom.compare;

import es.um.uschema.USchema.Attribute;

public class CompareAttribute extends Comparator<Attribute>
{
  @Override
  public boolean compare(Attribute a1, Attribute a2)
  {
    if (super.checkNulls(a1, a2))
      return false;

    if (super.checkEquals(a1, a2))
      return true;

    return (a1.getType() == null && a2.getType() == null)
        || new CompareDataType().compare(a1.getType(), a2.getType());
  }
}
