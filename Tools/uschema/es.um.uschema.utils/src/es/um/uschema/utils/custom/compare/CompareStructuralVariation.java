package es.um.uschema.utils.custom.compare;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import es.um.uschema.USchema.Feature;
import es.um.uschema.USchema.StructuralVariation;

public class CompareStructuralVariation extends Comparator<StructuralVariation>
{
  @Override
  public boolean compare(StructuralVariation v1, StructuralVariation v2)
  {
    if (super.checkNulls(v1, v2))
      return false;

    if (super.checkEquals(v1, v2))
      return true;

    // Please note we do not compare variationId, count nor timestamp.

    if (v1.getFeatures() == null ^ v2.getFeatures() == null)
      return false;

    if (v1.getFeatures() != null && v2.getFeatures() != null)
    {
      if (v1.getFeatures().size() != v2.getFeatures().size())
        return false;

      List<Feature> s2PropertiesCopy = new ArrayList<Feature>(v2.getFeatures());

      for (Feature p1 : v1.getFeatures())
      {
        Optional<Feature> propToErase = s2PropertiesCopy.stream().filter(p2 ->
        {
          return new CompareFeature().compare(p1, p2);
        }).findFirst();

        if (propToErase.isPresent())
          s2PropertiesCopy.remove(propToErase.get());
      }

      if (!s2PropertiesCopy.isEmpty())
        return false;
    }

    return true;
  }
}
