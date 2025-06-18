package es.um.uschema.utils.custom.compare;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import es.um.uschema.USchema.Attribute;
import es.um.uschema.USchema.Reference;

public class CompareReference extends Comparator<Reference>
{
  @Override
  public boolean compare(Reference r1, Reference r2)
  {
    if (super.checkNulls(r1, r2))
      return false;

    if (super.checkEquals(r1, r2))
      return true;

    if (r1.getUpperBound() != r2.getUpperBound() || r1.getLowerBound() != r2.getLowerBound())
      return false;

    if (r1.getOpposite() == null ^ r2.getOpposite() == null)
      return false;

    if (r1.getOpposite() != null && !new CompareFeature().compare(r1.getOpposite(), r2.getOpposite()))
      return false;

    if (r1.getIsFeaturedBy().isEmpty() ^ r2.getIsFeaturedBy().isEmpty())
      return false;

    if (!r1.getIsFeaturedBy().isEmpty() && !r2.getIsFeaturedBy().isEmpty())
    {
      if (r1.getIsFeaturedBy().size() != r2.getIsFeaturedBy().size())
        return false;

      if (r1.getIsFeaturedBy().get(0).getContainer() != null ^ r2.getIsFeaturedBy().get(0).getContainer() != null)
        return false;

      if (r1.getIsFeaturedBy().get(0).getContainer() != null && !CompareSchemaType.compareNames(r1.getIsFeaturedBy().get(0).getContainer(), r2.getIsFeaturedBy().get(0).getContainer()))
        return false;
    }

    if (r1.getAttributes() != null && r2.getAttributes() != null)
    {
      if (r1.getAttributes().size() != r2.getAttributes().size())
        return false;

      List<Attribute> r2AttributesCopy = new ArrayList<Attribute>(r2.getAttributes());

      for (Attribute attr1 : r1.getAttributes())
      {
        Optional<Attribute> attrToErase = r2AttributesCopy.stream().filter(attr2 ->
        {
          return new CompareFeature().compare(attr1, attr2);
        }).findFirst();

        if (attrToErase.isPresent())
          r2AttributesCopy.remove(attrToErase.get());
      }

      if (!r2AttributesCopy.isEmpty())
        return false;
    }

    if (r1.getRefsTo() == null ^ r2.getRefsTo() == null)
      return false;

    return r1.getRefsTo() == null || CompareSchemaType.compareNames(r1.getRefsTo(), r2.getRefsTo());
  }
}
