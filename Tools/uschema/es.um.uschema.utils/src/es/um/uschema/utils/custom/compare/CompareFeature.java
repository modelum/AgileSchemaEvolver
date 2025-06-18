package es.um.uschema.utils.custom.compare;

import es.um.uschema.USchema.Feature;
import es.um.uschema.USchema.LogicalFeature;
import es.um.uschema.USchema.StructuralFeature;

public class CompareFeature extends Comparator<Feature>
{
  @Override
  public boolean compare(Feature p1, Feature p2)
  {
    if (super.checkNulls(p1, p2))
      return false;

    if (super.checkEquals(p1, p2))
      return true;

    if (p1.getName() == null ^ p2.getName() == null)
      return false;

    if (p1.getName() != null && !p1.getName().equals(p2.getName()))
      return false;

    if (p1 instanceof LogicalFeature && p2 instanceof LogicalFeature)
      return new CompareLogicalFeature().compare((LogicalFeature)p1, (LogicalFeature)p2);

    if (p1 instanceof StructuralFeature && p2 instanceof StructuralFeature)
      return new CompareStructuralFeature().compare((StructuralFeature)p1, (StructuralFeature)p2);

    return false;
  }

  public boolean compareName(Feature p1, Feature p2)
  {
    if (super.checkNulls(p1, p2))
      return false;

    if (super.checkEquals(p1, p2))
      return true;

    if (p1.getName() == null ^ p2.getName() == null)
      return false;

    return p1.getName() != null && p1.getName().equals(p2.getName());
  }

  public boolean compareType(Feature p1, Feature p2)
  {
    if (super.checkNulls(p1, p2))
      return false;

    if (super.checkEquals(p1, p2))
      return true;

    if (p1 instanceof LogicalFeature && p2 instanceof LogicalFeature)
      return new CompareLogicalFeature().compare((LogicalFeature)p1, (LogicalFeature)p2);

    if (p1 instanceof StructuralFeature && p2 instanceof StructuralFeature)
      return new CompareStructuralFeature().compare((StructuralFeature)p1, (StructuralFeature)p2);

    return false;
  }
}
