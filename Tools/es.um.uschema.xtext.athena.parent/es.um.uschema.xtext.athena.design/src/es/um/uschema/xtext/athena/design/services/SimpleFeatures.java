package es.um.uschema.xtext.athena.design.services;

import es.um.uschema.xtext.athena.athena.Null;
import es.um.uschema.xtext.athena.athena.SimpleFeature;
import es.um.uschema.xtext.athena.athena.UnrestrictedPrimitiveType;

public class SimpleFeatures
{
  public String getSimpleFeatureLabel(SimpleFeature feature)
  {
    StringBuilder result = new StringBuilder();

    if (feature.isKey())
      result.append("+");

    if (feature.isUnique())
      result.append("!");

    result.append(feature.getName() + ": ");

    if (feature.getType() instanceof Null)
      result.append("Null");

    if (feature.getType() instanceof UnrestrictedPrimitiveType)
      result.append(((UnrestrictedPrimitiveType)feature.getType()).getTypename());

    return result.toString();
  }

  public String getLabelReference(SimpleFeature feature)
  {
    return feature.getName() + ": " + "ref";
  }

  public String getLabelAggregate(SimpleFeature feature)
  {
    return feature.getName() + ": " + "aggr";
  }
}
