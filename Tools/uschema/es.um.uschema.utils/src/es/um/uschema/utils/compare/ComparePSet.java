package es.um.uschema.utils.compare;

import es.um.uschema.USchema.PSet;

public class ComparePSet extends Comparator<PSet>
{
  @Override
  public boolean compare(PSet s1, PSet s2)
  {
    if (super.checkNulls(s1, s2))
      return false;

    if (super.checkEquals(s1, s2))
      return true;

    return (s1.getElementType() == null && s2.getElementType() == null)
        || new CompareDataType().compare(s1.getElementType(), s2.getElementType());
  }
}
