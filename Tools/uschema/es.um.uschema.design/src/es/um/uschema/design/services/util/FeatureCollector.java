package es.um.uschema.design.services.util;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import es.um.uschema.USchema.Feature;
import es.um.uschema.USchema.SchemaType;
import es.um.uschema.USchema.StructuralVariation;
import es.um.uschema.utils.compare.CompareFeature;

public class FeatureCollector
{
  private CompareFeature featComparer;

  public FeatureCollector()
  {
    featComparer = new CompareFeature();
  }
/*
  public <T extends Property> List<T> getUnionProperties(SchemaType schemaT, Class<T> theClass)
  {
    List<T> result = new ArrayList<T>();

    schemaT.getVariations().forEach(var ->
    {
      var.getProperties().stream().filter(prop -> theClass.isInstance(prop)).forEach(prop ->
      {
        if (result.stream().noneMatch(prop2 -> propComparer.compare(prop, prop2)))
          result.add(theClass.cast(prop));
      });
    });

    result.sort((prop1, prop2) -> prop1.getName().compareTo(prop2.getName()));

    return result;
  }
*/
  public <T extends Feature> List<T> getCommonFeatures(SchemaType schemaT, Class<T> theClass)
  {
    List<T> result = new ArrayList<T>();

    if (!schemaT.getVariations().isEmpty())
    {
      result.addAll(schemaT.getVariations().get(0).getFeatures().stream()
          .filter(feat -> theClass.isInstance(feat))
          .map(feat -> theClass.cast(feat))
          .collect(Collectors.toList()));

      if (schemaT.getVariations().size() > 1)
      {
        result = result.stream().filter(feat1 ->
        {
          return schemaT.getVariations().stream().skip(1).allMatch(var ->
          {
            return var.getFeatures().stream().anyMatch(feat2 -> featComparer.compare(feat1, feat2));
          });
        }).collect(Collectors.toList());
      }
    }

    try
    {
      result.sort((feat1, feat2) -> feat1.getName().compareTo(feat2.getName()));
    } catch (NullPointerException e)
    {
      // It tried ordering references/keys without names. It's ok.
    }

    return result;
  }

  public <T extends Feature> List<T> getOptionalFeatures(SchemaType schemaT, Class<T> theClass)
  {
    List<T> result = new ArrayList<T>();
    List<T> theCommons = getCommonFeatures(schemaT, theClass);

    if (!schemaT.getVariations().isEmpty())
    {
      schemaT.getVariations().forEach(var ->
      {
        var.getFeatures().stream().filter(feat1 -> theClass.isInstance(feat1) && theCommons.stream().noneMatch(feat2 -> featComparer.compare(feat1, feat2))).forEach(feat1 ->
        {
          if (result.stream().noneMatch(feat2 -> featComparer.compare(feat1, feat2)))
            result.add(theClass.cast(feat1));
        });
      });
      /*schemaT.getVariations().forEach(var ->
      {
        // Watch out we are modifying the list as we iterate, so do not try to put that condition on a filter...
        var.getFeatures().stream().filter(prop -> theClass.isInstance(prop) && prop.isOptional()).forEach(prop ->
        {
          if (result.stream().noneMatch(prop2 -> propComparer.compare(prop, prop2)))
            result.add(theClass.cast(prop));
        });
      });*/
    }

    try
    {
      result.sort((feat1, feat2) -> feat1.getName().compareTo(feat2.getName()));
    } catch (NullPointerException e)
    {
      // It tried ordering references/keys without names. It's ok.
    }

    return result;
  }

  public <T extends Feature> List<T> getParticularFeatures(StructuralVariation var, Class<T> theClass)
  {
    List<T> result = new ArrayList<T>();
    List<T> commonFeats = getCommonFeatures(var.getContainer(), theClass);

    for (Feature feat : var.getFeatures())
      if (theClass.isInstance(feat))
        result.add(theClass.cast(feat));

    result = result.stream().filter(feat1 ->
    {
      return commonFeats.stream().noneMatch(feat2 ->
      {
        return featComparer.compare(feat1, feat2);
      });
    }).collect(Collectors.toList());

    try
    {
      result.sort((feat1, feat2) -> feat1.getName().compareTo(feat2.getName()));
    } catch (NullPointerException e)
    {
      // It tried ordering references/keys without names. It's ok.
    }

    return result;
  }
}
