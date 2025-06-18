package es.um.uschema.utils.custom.compare;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import es.um.uschema.USchema.Attribute;
import es.um.uschema.USchema.Key;

public class CompareKey extends Comparator<Key>
{
  @Override
  public boolean compare(Key k1, Key k2)
  {
    if (super.checkNulls(k1, k2))
      return false;

    if (super.checkEquals(k1, k2))
      return true;

    if (k1.getAttributes() != null && k2.getAttributes() != null)
    {
      if (k1.getAttributes().size() != k2.getAttributes().size())
        return false;

      List<Attribute> k2AttributesCopy = new ArrayList<Attribute>(k2.getAttributes());

      for (Attribute attr1 : k1.getAttributes())
      {
        Optional<Attribute> attrToErase = k2AttributesCopy.stream().filter(attr2 ->
        {
          return new CompareFeature().compare(attr1, attr2);
        }).findFirst();

        if (attrToErase.isPresent())
          k2AttributesCopy.remove(attrToErase.get());
      }

      if (!k2AttributesCopy.isEmpty())
        return false;
    }

    return true;
  }
}
