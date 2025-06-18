package es.um.uschema.utils.compare;

import es.um.uschema.USchema.EntityType;

public class CompareEntityType extends Comparator<EntityType>
{
  @Override
  public boolean compare(EntityType e1, EntityType e2)
  {
    if (super.checkNulls(e1, e2))
      return false;

    if (super.checkEquals(e1, e2))
      return true;

    return e1.isRoot() == e2.isRoot();
  }
}
