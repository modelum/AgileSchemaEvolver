package es.um.uschema.design.services;

import java.util.List;

import es.um.uschema.design.services.util.FeatureCollector;
import es.um.uschema.USchema.Aggregate;
import es.um.uschema.USchema.Attribute;
import es.um.uschema.USchema.Key;
import es.um.uschema.USchema.Reference;

public class SchemaType
{
  private FeatureCollector featCollector;

  public SchemaType()
  {
    featCollector = new FeatureCollector();
  }

  public boolean hasCommonFeatures(es.um.uschema.USchema.SchemaType schemaT)
  {
    return schemaT.getVariations().stream() .anyMatch(var ->
      var.getLogicalFeatures().stream().anyMatch(
          lFeat -> (lFeat instanceof Key && ((Key)lFeat).getAttributes().isEmpty())
          || (lFeat instanceof Reference && ((Reference)lFeat).getAttributes().isEmpty()))
      || var.getStructuralFeatures().stream().anyMatch(sFeat -> !sFeat.isOptional()));
  }

  public boolean hasOptionalFeatures(es.um.uschema.USchema.SchemaType schemaT)
  {
    return schemaT.getVariations().stream().anyMatch(var ->
      var.getStructuralFeatures().stream().anyMatch(sFeat -> sFeat.isOptional()));
  }

  public List<Attribute> getCommonAttributes(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getCommonFeatures(schemaT, Attribute.class);
  }

  public List<Aggregate> getCommonAggregates(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getCommonFeatures(schemaT, Aggregate.class);
  }

  public List<Reference> getCommonReferences(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getCommonFeatures(schemaT, Reference.class);
  }

  public List<Key> getCommonKeys(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getCommonFeatures(schemaT, Key.class);
  }

  public List<Attribute> getOptionalAttributes(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getOptionalFeatures(schemaT, Attribute.class);
  }

  public List<Aggregate> getOptionalAggregates(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getOptionalFeatures(schemaT, Aggregate.class);
  }

  public List<Reference> getOptionalReferences(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getOptionalFeatures(schemaT, Reference.class);
  }

  public List<Key> getOptionalKeys(es.um.uschema.USchema.SchemaType schemaT)
  {
    return featCollector.getOptionalFeatures(schemaT, Key.class);
  }
}
