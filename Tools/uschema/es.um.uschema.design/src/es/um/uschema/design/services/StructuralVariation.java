package es.um.uschema.design.services;

import java.util.List;

import es.um.uschema.design.services.util.FeatureCollector;
import es.um.uschema.USchema.Aggregate;
import es.um.uschema.USchema.Attribute;
import es.um.uschema.USchema.Key;
import es.um.uschema.USchema.Reference;

public class StructuralVariation
{
  private FeatureCollector featCollector;

  public StructuralVariation()
  {
    featCollector = new FeatureCollector();
  }

  public List<Attribute> getParticularAttributes(es.um.uschema.USchema.StructuralVariation var)
  {
    return featCollector.getParticularFeatures(var, Attribute.class);
  }

  public List<Key> getParticularKeys(es.um.uschema.USchema.StructuralVariation var)
  {
    return featCollector.getParticularFeatures(var, Key.class);
  }

  public List<Reference> getParticularReferences(es.um.uschema.USchema.StructuralVariation var)
  {
    return featCollector.getParticularFeatures(var, Reference.class);
  }

  public List<Aggregate> getParticularAggregates(es.um.uschema.USchema.StructuralVariation var)
  {
    return featCollector.getParticularFeatures(var, Aggregate.class);
  }
}
