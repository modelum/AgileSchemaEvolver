package es.um.uschema.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.util.EcoreUtil;

import es.um.uschema.USchema.Aggregate;
import es.um.uschema.USchema.Attribute;
import es.um.uschema.USchema.DataType;
import es.um.uschema.USchema.EntityType;
import es.um.uschema.USchema.Feature;
import es.um.uschema.USchema.Key;
import es.um.uschema.USchema.LogicalFeature;
import es.um.uschema.USchema.Null;
import es.um.uschema.USchema.PList;
import es.um.uschema.USchema.PSet;
import es.um.uschema.USchema.PTuple;
import es.um.uschema.USchema.PrimitiveType;
import es.um.uschema.USchema.Reference;
import es.um.uschema.USchema.SchemaType;
import es.um.uschema.USchema.StructuralFeature;
import es.um.uschema.USchema.StructuralVariation;
import es.um.uschema.USchema.USchema;

public class USchemaHandler
{
  private USchemaFactory factory = new USchemaFactory();

  public EntityType getEntityType(USchema schema, String name)
  {
    return schema.getEntities().stream().filter(e -> e.getName().equals(name)).findFirst().get();
  }

  public <T extends Feature> Optional<Feature> getFirstFeatureNameIn(EntityType entity, Class<T> theClass, String featName)
  {
    switch (theClass.getSimpleName())
    {
      case "Feature":   { return entity.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f.getName() != null && f.getName().equals(featName)).findFirst(); }
      case "Attribute": { return entity.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f instanceof Attribute && f.getName().equals(featName)).findFirst(); }
      case "Key":       { return entity.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f instanceof Key &&
                            ((((Key)f).getAttributes().stream().anyMatch(attr -> attr.getName().equals(featName)) || (f.getName() != null && f.getName().equals(featName))))).findFirst(); }
      case "Reference": {
        return entity.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f instanceof Reference &&
            ((((Reference)f).getAttributes().stream().anyMatch(attr -> attr.getName().equals(featName)) || (f.getName() != null && f.getName().equals(featName))))).findFirst(); }
      case "Aggregate": { return entity.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f instanceof Aggregate && f.getName().equals(featName)).findFirst(); }

      default:          { throw new IllegalArgumentException("HasFeatureNameIn - Provided invalid class: " + theClass.getName()); }
    }
  }

  public <T extends Feature> boolean hasFeatureNameIn(List<EntityType> entities, Class<T> theClass, String featName)
  {
    return entities.stream().anyMatch(e -> hasFeatureNameIn(e, theClass, featName));
  }

  public <T extends Feature> boolean hasFeatureNameIn(EntityType entity, Class<T> theClass, String featName)
  {
    return getFirstFeatureNameIn(entity, theClass, featName).isPresent();
  }

  public void duplicateAndAddFeature(StructuralVariation variation, Feature feature)
  {
    Feature newFeature = EcoreUtil.copy(feature);
    addFeatureToVariation(variation, newFeature);

    if (feature instanceof Attribute)
    {
      Attribute attr = (Attribute)feature;
      if (attr.getKey() != null)
        addKeyToVariation(variation, (Attribute)newFeature);
      if (!attr.getReferences().isEmpty())
        for (Reference r : attr.getReferences())
        {
          Reference ref = factory.createReference(r.getName(), r.getLowerBound(), r.getUpperBound(), r.getRefsTo());
          ref.getAttributes().add((Attribute)newFeature);
          ((Attribute)newFeature).getReferences().add(ref);

          addFeatureToVariation(variation, ref);
        }
    }
  }

  public void addFeatureToVariation(StructuralVariation variation, Feature feature)
  {
    variation.getFeatures().add(feature);
    if (feature instanceof LogicalFeature)
      variation.getLogicalFeatures().add((LogicalFeature)feature);
    else
      variation.getStructuralFeatures().add((StructuralFeature)feature);
  }

  public void addKeyToVariation(StructuralVariation variation, Attribute attr)
  {
    Key key = factory.createKey(null);
    key.getAttributes().add(attr);
    attr.setKey(key);

    addFeatureToVariation(variation, key);
  }

  public void removeFeatureFromEntity(EntityType entity, String name)
  {
    for (StructuralVariation var : entity.getVariations())
      removeFeatureFromVariation(var, name);
  }

  public void removeFeatureFromVariation(StructuralVariation variation, String name)
  {
    Optional<Feature> key = variation.getFeatures().stream().filter(f -> f instanceof Key &&
        ((f.getName() != null && f.getName().equals(name)) ||
        ((Key)f).getAttributes().stream().anyMatch(attr -> attr.getName().equals(name))))
        .findFirst();

    if (key.isPresent())
      removeFeatureFromVariation(variation, key.get());

    Optional<Feature> ref = variation.getFeatures().stream().filter(f -> f instanceof Reference &&
        ((f.getName() != null && f.getName().equals(name)) ||
        ((Reference)f).getAttributes().stream().anyMatch(attr -> attr.getName().equals(name))))
        .findFirst();

    if (ref.isPresent())
      removeFeatureFromVariation(variation, ref.get());

    Optional<Feature> aggr = variation.getFeatures().stream().filter(f -> f instanceof Aggregate &&
        f.getName().equals(name))
        .findFirst();

    if (aggr.isPresent())
      removeFeatureFromVariation(variation, aggr.get());

    Optional<Feature> attr = variation.getFeatures().stream().filter(f -> f instanceof Attribute &&
        f.getName().equals(name))
        .findFirst();

    if (attr.isPresent())
    {
      if (((Attribute)attr.get()).getKey() != null)
        removeFeatureFromVariation(variation, ((Attribute)attr.get()).getKey());

      if (!((Attribute)attr.get()).getReferences().isEmpty())
        for (Reference r : ((Attribute)attr.get()).getReferences())
        removeFeatureFromVariation(variation, r);

      removeFeatureFromVariation(variation, attr.get());
    }
  }

  private void removeFeatureFromVariation(StructuralVariation variation, Feature feature)
  {
    if (feature instanceof LogicalFeature)
      variation.getLogicalFeatures().remove((LogicalFeature)feature);
    else
      variation.getStructuralFeatures().remove((StructuralFeature)feature);
    variation.getFeatures().remove(feature);
  }

  public int getReferenceUpperBound(EntityType entity, String refName)
  {
    return ((Reference)getFirstFeatureNameIn(entity, Reference.class, refName).get()).getUpperBound();
  }

  public int getAggregateUpperBound(EntityType entity, String aggrName)
  {
    return ((Aggregate)getFirstFeatureNameIn(entity, Aggregate.class, aggrName).get()).getUpperBound();
  }

  public String getDefaultIdName(USchema schema)
  {
    return schema.getEntities().stream().flatMap(e -> e.getVariations().stream()).flatMap(v -> v.getFeatures().stream())
        .filter(f -> f instanceof Key).map(f -> (Key)f).findFirst().get().getAttributes().get(0).getName();
  }

  public Key getFirstKey(EntityType entity)
  {
    return (Key)entity.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f instanceof Key).findFirst().get();
  }

  public List<Feature> getFeatureNamesFrom(EntityType entity1, EntityType entity2)
  {
    Map<String, Feature> features = new HashMap<String, Feature>();
    for (Feature feat : entity2.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f instanceof Attribute || f instanceof Aggregate).collect(Collectors.toList()))
      features.put(feat.getName(), feat);
    for (Feature feat : entity1.getVariations().stream().flatMap(v -> v.getFeatures().stream()).filter(f -> f instanceof Attribute || f instanceof Aggregate).collect(Collectors.toList()))
      features.put(feat.getName(), feat);

    return new ArrayList<Feature>(features.values());
  }

  public DataType getInnerDataType(DataType dType)
  {
    if (dType instanceof PList)
      return ((PList)dType).getElementType();
    if (dType instanceof PSet)
      return ((PSet)dType).getElementType();
    if (dType instanceof PTuple)
      return ((PTuple)dType).getElements().get(0);
    if (dType instanceof PrimitiveType || dType instanceof Null)
      return dType;

    throw new IllegalArgumentException("Can't get inner data type of a PMap");
  }

  /**
   * Method used to get the Union feature set from a Schema Type.
   * To do so for each variation each attribute and aggregate are added if there was not a feature with the same name introduced.
   * For each attribute also its references and keys are added.
   * @param sType The Schema type whose Union feature set is extracted.
   * @return A list of features representing the Union set of the schema type.
   */
  public List<Feature> getUnionFeaturesInSchemaType(SchemaType sType)
  {
    List<Feature> features = new ArrayList<Feature>();

    for (StructuralVariation var : sType.getVariations())
    {
      for (Attribute attr : var.getFeatures().stream().filter(f -> f instanceof Attribute).map(f -> (Attribute)f).collect(Collectors.toList()))
        if (!features.stream().anyMatch(f -> f.getName() != null && f.getName().equals(attr.getName())))
        {
          features.add(attr);

          if (!attr.getReferences().isEmpty())
            features.addAll(attr.getReferences());

          if (attr.getKey() != null)
            features.add(attr.getKey());
        }

      for (Aggregate aggr : var.getFeatures().stream().filter(f -> f instanceof Aggregate).map(f -> (Aggregate)f).collect(Collectors.toList()))
        if (!features.stream().anyMatch(f -> f.getName() != null && f.getName().equals(aggr.getName())))
          features.add(aggr);
    }

    return features;
  }
}
